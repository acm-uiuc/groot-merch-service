# Copyright © 2017, ACM@UIUC
#
# This file is part of the Groot Project.  
# 
# The Groot Project is open source software, released under the University of
# Illinois/NCSA Open Source License. You should have received a copy of
# this license in a file with the distribution.
# encoding: UTF-8

module Sinatra
  module ItemsRoutes
    def self.registered(app)
      app.get '/merch/items' do
        ResponseFormat.data(Item.all)
      end

      app.get '/merch/items/available' do
        ResponseFormat.data(Item.all.select { |e| e.in_stock })
      end

      app.get '/merch/items/:id' do
        item = Item.get(params[:id]) || halt(404, Errors::ITEM_NOT_FOUND)
        ResponseFormat.data(item)
      end

      # Assign location to item
      app.post '/merch/items' do
        params = ResponseFormat.get_params(request.body.read)
        status, error = Item.validate(params, [:name, :price, :image_url, :quantity, :location])
        halt status, ResponseFormat.error(error) if error

        item = Item.get(name: params[:name])
        if item.nil?
          item = Item.new(
            name: params[:name],
            price: params[:price],
            image: params[:image_url],
          )
          halt 400, ResponseFormat.error(item.errors.to_a.join("\n")) if item.errors.any?
        end

        row, column = params[:location][0], params[:location][1..-1].to_i
        loc = Location.first(row: row, column: column) || halt(404, Errors::INVALID_LOCATION)

        item.save
        loc.update(
          item: item,
          quantity: params[:quantity]
        )

        ResponseFormat.message("Assigned #{params[:location]} to #{item.name}")
      end

      app.put '/merch/items/:id' do
        item_id = params[:id]

        params = ResponseFormat.get_params(request.body.read)
        status, error = Item.validate(params, [:name, :price, :image_url, :quantity, :location])
        halt status, ResponseFormat.error(error) if error

        item = Item.get(item_id) || halt(404, Errors::ITEM_NOT_FOUND)
        item.update(
          name: params[:name],
          price: params[:price],
          image: params[:image_url]
        )

        row, column = params[:location][0], params[:location][1..-1].to_i
        loc = Location.first(item: item, row: row, column: column) || halt(404, Errors::INVALID_LOCATION)
        loc.update(quantity: params[:quantity].to_i) unless loc.quantity == params[:quantity].to_i

        ResponseFormat.message("Item updated successfully!")
      end
      
      app.delete '/merch/items/:id' do
        item_id = params[:id]
        item = Item.get(item_id) || halt(404, Errors::ITEM_NOT_FOUND)

        # would prefer to have a before :destroy on Ruby model but not allowed
        item.locations.each do |loc|
          loc.update(item: nil, quantity: 0)
        end
        item.destroy || halt(500, ResponseFormat.error("Error destroying item"))
        ResponseFormat.message("Item destroyed successfully!")
      end
    end
  end

  register ItemsRoutes
end