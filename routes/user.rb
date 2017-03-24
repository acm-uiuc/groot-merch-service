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
        halt(401, ERRORS::VERIFY_ADMIN) unless Auth.verify_admin(env) || GrootMerchService.unsecure

        ResponseFormat.data(User.all)
      end
      
      app.get '/merch/users/:netid' do
        status, error = User.validate(params, [:netid])
        halt status, ResponseFormat.error(error) if error

        user = User.first(netid: params[:netid])
        unless user
          user = User.create(
            netid: params[:netid],
            pin: User.generate_pin
          )
          user.save
        end
        begin
          user.balance
        rescue
          puts "An error fetching credits"
        ensure
          return ResponseFormat.data(user)
        end
      end

      app.get '/merch/users/pins/:pin' do
        user = User.first(pin: params[:pin]) || halt(404, ERRORS::INVALID_PIN)
        begin
          user.balance
        rescue
          puts "An error fetching credits"
        ensure
          return ResponseFormat.data(user)
        end
      end
    end
  end

  register UsersRoutes
end