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
    property :column, Integer, required: true, min: 1, max: 9
    property :quantity, Integer, required: false, default: 0
    belongs_to :item, required: false

    validates_with_method :row, method: :correct_row?

    def correct_row?
      if ("A".."E").to_a.include? @row
        return true
      else
        return [false, "row must be a valid string in the interval A - E"]
      end
    end

    def self.validate(params, attributes)
      attributes.each do |attr|
        return [400, "Missing #{attr}"] unless params[attr] && !params[attr].empty?
      end

      [200, nil]
    end

    def pretty_location
      "#{self.row}#{self.column}"
    end
    
    def serialize
      item_json = (self.item.nil?) ? nil : {
        id: self.item.id,
        name: self.item.name,
        price: self.item.price,
        image: self.item.image
      }
      
      {
        id: self.id,
        row: self.row,
        column: self.column,
        location: self.pretty_location,
        quantity: self.quantity,
        item: item_json
      }
    end
end