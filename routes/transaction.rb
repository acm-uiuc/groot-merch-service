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
        status, error = User.validate(params, [:items, :pin, :quantities])
        halt status, ResponseFormat.error(error) if error
        
        user = User.first(pin: params[:pin]) || halt(404, Errors::INVALID_PIN)
        begin
          user.balance
        rescue
          halt 500, Errors::BALANCE_ERROR
        end

        total_credits_needed = 0
        params[:items].zip(params[:quantities]).each do |item_id, quantity|
          item = Item.get(item_id) || halt(404, Errors::ITEM_NOT_FOUND)
          total_credits_needed += item.price * quantity
          halt(400, Errors::INSUFFICIENT_QUANTITY) if item.quantity < quantity
        end

        halt(400, Errors::INSUFFICENT_CREDITS) if user.balance < total_credits_needed
        transaction = Transaction.create(
          user_id: user.id,
          items: params[:items],
          quantities: params[:quantities],
          confirmed: false
        )

        ResponseFormat.data(transaction)
      end
      
      app.put '/merch/transactions' do
        params = ResponseFormat.get_params(request.body.read)
        
        status, error = User.validate(params, [:items, :transaction_id, :pin, :quantities, :confirmed])
        user = User.first(pin: params[:pin]) || halt(404, Errors::INVALID_PIN)

        begin
          user.balance
        rescue
          halt 500, Errors::BALANCE_ERROR
        end

        transaction = Transaction.first(
          id: params[:transaction_id],
          items: params[:items],
          quantities: params[:quantities],
          user_id: user.id
        ) || halt(404, Errors::USER_NOT_FOUND)
        transaction.destroy unless params[:confirmed]
        
        old_balance = user.balance
        total_credits_needed = 0
        params[:items].zip(params[:quantities]).each do |item_id, quantity|
          item = Item.get(item_id) || halt(404, Errors::ITEM_NOT_FOUND)
          total_credits_needed += item.price * quantity
        end
        new_balance = user.balance - total_credits_needed
        user.set_balance(new_balance, "Merch Transaction")
        if user.balance == old_balance # transaction failed
          transaction.destroy
          halt 500, ResponseFormat.error("Error updating credits balance.")
        end

        transaction.update(confirmed: true)
        params[:items].zip(params[:quantities]).each do |item_id, quantity|
          item = Item.get(item_id) || halt(404, Errors::ITEM_NOT_FOUND)
          item.update(quantity: item.quantity - quantity)
        end

        ResponseFormat.data(user)
      end
    end
  end

  register TransactionsRoutes
end