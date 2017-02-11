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
      app.get '/caffeine/users' do
        # Return all users w/ pins, admin only route
        halt(401, Errors::VERIFY_ADMIN) unless Auth.verify_admin(env) || settings.unsecure

        ResponseFormat.data(User.all)
      end
      
      app.post '/caffeine/users' do
        # find or create user by their netid, initialize and create pin
        params = ResponseFormat.get_params(request.body.read)
        status, error = User.validate!(params, [:netid])
        halt status, error if error

        user = User.find_or_create(
          {
            netid: params[:netid]
          },
          {
            pin: User.generate_pin
          }
        )
        user.balance

        ResponseFormat.data(user)
      end
    end
  end

  register UsersRoutes
end