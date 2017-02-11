# Copyright © 2017, ACM@UIUC
#
# This file is part of the Groot Project.  
# 
# The Groot Project is open source software, released under the University of
# Illinois/NCSA Open Source License. You should have received a copy of
# this license in a file with the distribution.
# encoding: UTF-8

module Sinatra
  module UsersRoutes
    def self.registered(app)
      app.get '/caffeine/transactions/:netid/' do
        # Return all transactions for a user, maybe allow only user or admin or something, or maybe require pin for users
        halt(401, Errors::VERIFY_ADMIN) unless Auth.verify_admin(env) || settings.unsecure || (Auth.verify_session(env) && env['HTTP_NETID'] == params[:netid])

        user = User.first(netid: netid) || halt(404, ERRORS::USER_NOT_FOUND)
        ResponseFormat.data(user.transactions)
      end

      app.post '/caffeine/transactions/:netid/' do
        netid = params[:netid]
        params = ResponseFormat.get_params(request.body.read)
        status, error = User.validate!(params, [:netid, :item_id, :pin])

        user = User.first(netid: netid) || halt(404, ERRORS::USER_NOT_FOUND)
        user.balance

        halt (400, ERRORS::INVALID_PIN) if user.pin == params[:pin]

        item = Item.get(params[:item_id]) || halt(404, ERRORS::ITEM_NOT_FOUND)

        halt (400, ERRORS::INSUFFICENT_CREDITS) if user.balance < item.price

        transaction = Transaction.create(
          user_id: user.id,
          item_id: item.id,
          confirmed: false
        )

        ResponseFormat.data(transaction)
      end
      
      app.put '/caffeine/transactions/:netid/' do
        netid = params[:netid]
        params = ResponseFormat.get_params(request.body.read)
        status, error = User.validate!(params, [:item_id, :transaction_id, :pin, :confirmed])

        user = User.first(netid: netid) || halt(404, ERRORS::USER_NOT_FOUND)
        item = Item.get(params[:item_id]) || halt(404, ERRORS::ITEM_NOT_FOUND)

        transaction = Transaction.first(
          id: params[:transaction_id],
          item_id: params[:item_id],
          user_id: user.id
        ) || halt(404, ERRORS::USER_NOT_FOUND)

        transaction.destroy unless confirmed

        transaction.update(confirmed: true)

        # updates in credit service
        user.balance -= item.price 

        ResponseFormat.data(user)
      end
    end
  end

  register UsersRoutes
end