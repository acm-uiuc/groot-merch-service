# Copyright © 2017, ACM@UIUC
#
# This file is part of the Groot Project.  
# 
# The Groot Project is open source software, released under the University of
# Illinois/NCSA Open Source License. You should have received a copy of
# this license in a file with the distribution.
# encoding: UTF-8

module Sinatra
  module TransactionsRoutes
    def self.registered(app)
      app.post '/merch/transactions' do
        params = ResponseFormat.get_params(request.body.read)
        status, error = User.validate(params, [:items, :pin])
        halt status, ResponseFormat.error(error) if error
        
        user = User.first(pin: params[:pin]) || halt(404, Errors::INVALID_PIN)
        begin
          user.balance
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
        
        begin
          # Vending a transaction will remove items that could not be vended so that user
          # could be billed for correct amount according to what was actually bought
          error_message = transaction.vend
          
          old_balance = user.balance
          transaction_name = "Merch Transaction: #{items.map(&:name).join(", ")}"
          user.set_balance(user.balance - transaction.amount, transaction_name)
            
          # Transaction failed (quietly)
          if user.balance == old_balance
            transaction.destroy
            halt 500, Errors::BALANCE_ERROR
          end
          
          # Attach transaction which contains successful items only + error_message for failed items
          response = ResponseFormat.data(transaction)
          JSON.parse(response)['error'] = error_message

          response
        rescue Exception => e
          halt 500, ResponseFormat.error(e.message)
        end
      end
    end
  end

  register TransactionsRoutes
end