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
      app.post '/merch/transactions/' do
        params = ResponseFormat.get_params(request.body.read)
        status, error = User.validate(params, [:item_id, :pin, :quantity])
        halt status, ResponseFormat.error(error) if error
        
        user = User.first(pin: params[:pin]) || halt(404, Errors::INVALID_PIN)
        item = Item.get(params[:item_id]) || halt(404, Errors::ITEM_NOT_FOUND)
        halt(400, Errors::INSUFFICENT_CREDITS) if user.balance < item.price
        halt(400, Errors::INSUFFICIENT_QUANTITY) if item.quantity < params[:quantity].to_i

        transaction = Transaction.create(
          user_id: user.id,
          item_id: item.id,
          quantity: params[:quantity].to_i,
          confirmed: false
        )

        ResponseFormat.data(transaction)
      end
      
      app.put '/merch/transactions/' do
        params = ResponseFormat.get_params(request.body.read)
        # Must also send a confirmed value
        status, error = User.validate(params, [:item_id, :transaction_id, :pin, :quantity]) 

        user = User.first(pin: params[:pin]) || halt(404, Errors::INVALID_PIN)
        item = Item.get(params[:item_id]) || halt(404, Errors::ITEM_NOT_FOUND)

        transaction = Transaction.first(
          id: params[:transaction_id],
          item_id: params[:item_id],
          user_id: user.id  
        ) || halt(404, Errors::USER_NOT_FOUND)

        transaction.destroy unless params[:confirmed] == "true" # because it is a string in the JSON request
        item.update(quantity: item.quantity - params[:quantity].to_i)

        # updates in credit service, TODO add description
        user.balance -= item.price

        transaction.update(confirmed: true)

        ResponseFormat.data(user)
      end
    end
  end

  register TransactionsRoutes
end