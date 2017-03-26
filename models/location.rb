# Copyright © 2017, ACM@UIUC
#
# This file is part of the Groot Project.  
# 
# The Groot Project is open source software, released under the University of
# Illinois/NCSA Open Source License. You should have received a copy of
# this license in a file with the distribution.

class Location
    include DataMapper::Resource
    property :id, Serial

    property :row, String, required: true, length: 1
    property :column, Integer, required: true, max: 99
    property :quantity, Integer, required: true

    belongs_to :item

    def self.validate(params, attributes)
      attributes.each do |attr|
        return [400, "Missing #{attr}"] unless params[attr] && !params[attr].empty?
      end

      [200, nil]
    end
    
    def serialize
      {
        row: self.row,
        column: self.column,
        location: "#{self.row}#{self.column}",
        quantity: self.quantity
      }
    end
end