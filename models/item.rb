# Copyright © 2017, ACM@UIUC
#
# This file is part of the Groot Project.  
# 
# The Groot Project is open source software, released under the University of
# Illinois/NCSA Open Source License. You should have received a copy of
# this license in a file with the distribution.

class Item
    include DataMapper::Resource

    property :id, Serial
    property :price, Integer
    property :name, String, required: true
    property :image, Text
    property :created_on, Date

    has n, :transactions, through: Resource, constraint: :destroy
    has n, :locations, constraint: :skip

    def self.validate(params, attributes)
      attributes.each do |attr|
        return [400, "Missing #{attr}"] unless params[attr] && !params[attr].empty?
      end

      [200, nil]
    end

    def total_stock
      self.locations.map(&:quantity).reduce(:+)
    end

    def in_stock
       self.total_stock != 0
    end

    def serialize
      {
        id: self.id,
        price: self.price,
        name: self.name,
        image: self.image,
        created_on: self.created_on,
        vending: self.locations.map(&:serialize),
        in_stock: self.in_stock,
        total_stock: self.total_stock
      }
    end
end