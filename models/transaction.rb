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
    
    belongs_to :user
    has n, :items, through: Resource
    
    def amount
      self.items.map(&:price).reduce(:+)
    end

    def vend
      merch_access_key = Config.load_config("merch_pi")["access_key"]
      ip_address = Config.load_config("merch_pi")["ip_address"]

      # Make request to pi
      uri = URI.parse("http://#{ip_address}:5000/vend")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request['Authorization'] = merch_access_key

      items_locations = self.items.map(&:vend_location)
      request.body = {
        transaction_id: self.id,
        items: item_locations
      }.to_json
      response = http.request(request)

      if response.code == "200"
        result = JSON.parse(response.body)
        errors = ""
        result["items"].each do |item_json|
          if item_json['error']
            errors += "#{item_json['location']}: #{item_json['error']}\n"
          else
            item_idx=items_locations.index(item_json['location'])
            self.items[item_idx].location.quantity -= 1
            self.items[item_idx].location.save
          end
        end

        return errors == "" ? nil : errors
      else
        "Could not vend"
      end
    end

    def serialize
      {
        id: self.id,
        user: self.user.serialize,
        items: self.items.map(&:serialize),
        cost: self.amount,
        created_on: self.created_on
      }
    end
end