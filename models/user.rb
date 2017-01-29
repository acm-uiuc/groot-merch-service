# Copyright © 2017, ACM@UIUC
#
# This file is part of the Groot Project.  
# 
# The Groot Project is open source software, released under the University of
# Illinois/NCSA Open Source License. You should have received a copy of
# this license in a file with the distribution.

class User
    include DataMapper::Resource

    property :id, Serial
    property :netid, String, required: true, key: true, unique_index: true, length: 1...9
    property :pin, Integer, min: 10000000, max: 99999999, unique: true, required: true
    property :created_on, Date

    has n, :transactions
    has n, :items, through: :transactions

    def serialize
      {
        id: self.id,
        netid: self.netid,
        pin: self.pin,
        created_on: self.created_on
      }
    end
end