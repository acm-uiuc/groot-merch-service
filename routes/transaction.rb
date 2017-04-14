# Copyright © 2017, ACM@UIUC
#
# This file is part of the Groot Project.  
# 
# The Groot Project is open source software, released under the University of
# Illinois/NCSA Open Source License. You should have received a copy of
# this license in a file with the distribution.
# encoding: UTF-8

# semaphore = Mutex.new

module Sinatra
  module TransactionsRoutes
    def self.registered(app)
      app.get '/merch/transactions/:id' do
        transaction = Transaction.get(params[:id]) || halt(404, Errors::INVALID_TRANSACTION)
        ResponseFormat.data(transaction)
      end

      app.post '/merch/transactions' do
        params = ResponseFormat.get_params(request.body.read)
        status, error = User.validate(params, [:items, :pin])
        halt status, ResponseFormat.error(error) if error
        
        user = User.first(pin: params[:pin]) || halt(404, Errors::INVALID_PIN)
        begin
          user.balance
          halt 500, Errors::BALANCE_ERROR unless user.balance
        rescue
          halt 500, Errors::BALANCE_ERROR
        end

        items = params[:items].collect { |e| Item.get(e) }
        halt(404, Errors::ITEM_NOT_FOUND) if items.any? { |x| x.nil? }

        items.each do |item|
          unless item.in_stock
            halt(400, ResponseFormat.error("#{item.name} is out of stock. Please ask someone to refill this item."))
          end
        end

        total_credits_needed = items.map(&:price).inject(0, &:+)
        halt(400, Errors::INSUFFICENT_CREDITS) if user.balance < total_credits_needed

        transaction = Transaction.create(
          user_id: user.id,
          items: items
        )

        # Vend in the background, client requests status of transaction
        Thread.new {
          begin
            # Vending a transaction will remove items that could not be vended so that user
            # could be billed for correct amount according to what was actually bought

            # Ensure only one request to the pi at a time
            # semaphore.synchronize {
              error_message = transaction.vend
            # }
            user = transaction.user
            
            old_balance = user.balance
            new_balance = user.balance - transaction.amount
            # Update balance in credits service
            user.set_balance(new_balance, transaction.name)
              
            if user.balance == old_balance
              # Updating the balance failed, so entire transaction has to fail too
              transaction.update(status: :failed)
              transaction.set_status(JSON.parse(Errors::BALANCE_ERROR)['error'])
            else
              # Attach transaction which contains successful items only + error_message for failed items
              transaction.update(status: :completed)
              transaction.set_status(error_message)
            end
          rescue Exception => e
            # For any uncaught exception, report it as failed
            transaction.update(status: :failed)
            transaction.set_status("Unknown Error: #{e.message}")
          end
        }

        ResponseFormat.data(transaction)
      end
    end
  end

  register TransactionsRoutes
end