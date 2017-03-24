# Copyright © 2017, ACM@UIUC
#
# This file is part of the Groot Project.  
# 
# The Groot Project is open source software, released under the University of
# Illinois/NCSA Open Source License. You should have received a copy of
# this license in a file with the distribution.

class Transaction
    include DataMapper::Resource

    property :id, Serial
    property :created_on, Date
    property :confirmed, Boolean, default: false
    property :quantities, Integer
    property :items, Integer
    belongs_to :user

    def serialize
      {
        id: self.id,
        user: self.user,
        quantity: self.quantity,
        created_on: self.created_on
      }
    end
end