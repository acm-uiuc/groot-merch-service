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

      app.get '/merch/locations/:location' do
        row, column = params[:location][0], params[:location][1..-1].to_i
        location = Location.first(row: row, column: column) || halt(404, Errors::INVALID_LOCATION)
        ResponseFormat.data(location)
      end

      # Clears item at location
      app.put '/merch/locations/:location' do
        row, column = params[:location][0], params[:location][1..-1].to_i
        location = Location.first(row: row, column: column) || halt(404, Errors::INVALID_LOCATION)
        halt(400, Errors::ITEM_NOT_FOUND) if location.item.nil?
        
        item_name = location.item.name
        location.update(
          item: nil,
          quantity: 0
        )

        ResponseFormat.message("Clear #{item_name} at #{location.pretty_location}")
      end
    end
  end
  register LocationsRoutes
end