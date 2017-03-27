# Copyright © 2017, ACM@UIUC
#
# This file is part of the Groot Project.  
# 
# The Groot Project is open source software, released under the University of
# Illinois/NCSA Open Source License. You should have received a copy of
# this license in a file with the distribution.
# encoding: UTF-8

module Sinatra
  module LocationsRoutes
    def self.registered(app)
      app.get '/merch/locations' do
        ResponseFormat.data(Location.all)
      end
    end
  end
  register LocationsRoutes
end