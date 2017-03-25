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

        halt(400, ResponseFormat.error("Item #{item.name} has #{item.quantity} left according to our database. Please ask someone to refill this item.")) if items.map(&:quantity).any? { |e| e < 0 }

        total_credits_needed = items.map(&:price).inject(0, &:+)
        halt(400, Errors::INSUFFICENT_CREDITS) if user.balance < total_credits_needed

        transaction = Transaction.create(
          user_id: user.id,
          items: items,
          confirmed: false
        )
        ResponseFormat.data(transaction)
      end
      
      app.put '/merch/transactions' do
        params = ResponseFormat.get_params(request.body.read)
        
        status, error = User.validate(params, [:transaction_id, :pin, :confirmed])
        user = User.first(pin: params[:pin]) || halt(404, Errors::INVALID_PIN)

        begin
          user.balance
        rescue
          halt 500, Errors::BALANCE_ERROR
        end

        transaction = Transaction.first(
          id: params[:transaction_id],
          user_id: user.id
        ) || halt(404, Errors::USER_NOT_FOUND)
        transaction.destroy unless params[:confirmed]
        items = transaction.items
        
        old_balance = user.balance
        total_credits_needed = items.map(&:price).inject(0, &:+)
        new_balance = user.balance - total_credits_needed

        user.set_balance(new_balance, "Merch Transaction: #{items.map(&:name).join(", ")}")
        if user.balance == old_balance # transaction failed
          transaction.destroy
          halt 500, Errors::BALANCE_ERROR
        end

        transaction.update(confirmed: true)
        items.each do |item|
          item.update(quantity: item.quantity - 1)
        end

        ResponseFormat.data(user)
      end
    end
  end

  register TransactionsRoutes
end