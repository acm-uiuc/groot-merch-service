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
      app.get '/merch/users' do
        # Return all users w/ pins, admin only route
        halt(401, Errors::VERIFY_ADMIN) unless Auth.verify_admin(env) || GrootMerchService.unsecure

        ResponseFormat.data(User.all)
      end
      
      app.get '/merch/users/:netid' do
        # find or create user by their netid, initialize and create pin
        status, error = User.validate(params, [:netid])
        halt status, ResponseFormat.error(error) if error

        user = User.first_or_new({netid: params[:netid]})
        unless user.pin
          user.pin = User.generate_pin
          user.save
        end
        user.balance

        ResponseFormat.data(user)
      end
    end
  end

  register UsersRoutes
end