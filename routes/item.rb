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

      app.get '/merch/items/:id' do
        item = Item.get(params[:id]) || halt(404, Errors::ITEM_NOT_FOUND)
        ResponseFormat.data(item)
      end

      app.post '/merch/items' do
        params = ResponseFormat.get_params(request.body.read)
        status, error = Item.validate(params, [:name, :price, :image_url, :quantity])
        halt status, ResponseFormat.error(error) if error

        item = Item.create(
          name: params[:name],
          price: params[:price],
          image: params[:image_url],
          quantity: params[:quantity]
        )

        ResponseFormat.message("Item added successfully")
      end

      app.put '/merch/items/:id' do
        item_id = params[:id]

        params = ResponseFormat.get_params(request.body.read)
        status, error = Item.validate(params, [:name, :price, :image_url, :quantity])
        halt status, ResponseFormat.error(error) if error

        item = Item.get(item_id) || halt(404, Errors::ITEM_NOT_FOUND)

        item.update(
          name: params[:name],
          price: params[:price],
          image: params[:image_url],
          quantity: params[:quantity]
        )
        
        ResponseFormat.message("Item updated successfully!")
      end
      
      app.delete '/merch/items/:id' do
        item_id = params[:id]

        item = Item.get(item_id) || halt(404, Errors::ITEM_NOT_FOUND)

        item.destroy || halt(500, ResponseFormat.error("Error destroying item"))

        ResponseFormat.message("Item destroyed successfully!")
      end
    end
  end

  register ItemsRoutes
end