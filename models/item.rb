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
    property :price, Decimal
    property :name, String, required: true
    # property :location
    property :created_on, Date

    has n, :transactions
    has n, :users, through: :transactions

    def serialize
      {
        id: self.id,
        price: self.price,
        name: self.name,
        created_on: self.created_on
      }
    end
end