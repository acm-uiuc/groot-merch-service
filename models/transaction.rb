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
    property :status, Enum[:vending, :completed, :failed, :new], default: :new
    
    belongs_to :user
    has n, :items, through: Resource
    
    def amount
      self.items.map(&:price).reduce(:+)
    end

    def name
      "Merch Transaction: #{self.items.map(&:name).join(', ')}"
    end

    def vend
      merch_access_key = Config.load_config("merch_pi")["access_key"]
      merch_address = Config.load_config("merch_pi")["ip_address"]

      errors = ""
      # Retrieve the location to vend based on the item
      item_locations = self.items.map(&:vend_location)

      item_locations.each do |loc|
        ready_to_vend = false
        10.times do
          uri = URI.parse("http://#{merch_address}:5000/status")
          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Get.new(uri.request_uri)
          request['Authorization'] = merch_access_key
          request['Accept'] = 'application/json'
          request['Content-Type'] = 'application/json'

          response = http.request(request)
          ready_to_vend = response.status == "200"
          break if ready_to_vend
          sleep 2
        end
        return "The request to merch failed" unless ready_to_vend

        # Make request to pi
        uri = URI.parse("http://#{merch_address}:5000/vend")
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.request_uri)
        request['Authorization'] = merch_access_key
        request['Accept'] = 'application/json'
        request['Content-Type'] = 'application/json'
        request.body = {
          transaction_id: self.id,
          items: [loc]
        }.to_json

        response = http.request(request)
        if response.code == "200"
          result = JSON.parse(response.body)
          result["items"].each do |item_json|
            if item_json['error']
              errors += "#{item_json['location']}: #{item_json['error']}\n"
              # Remove item from transaction model
              items_except_error = self.items.reject { |i| i.vend_location.pretty_location == item_json['location'] }
              self.update(items: items_except_error)
            else
              item_idx = item_locations.index(item_json['location'])
              self.items[item_idx].location.quantity -= 1
              self.items[item_idx].location.save
            end
          end
        else
          return "The request to merch failed and could not vend the items."
        end
      end
      # Return any errors
      errors
    end

    def set_status(message)
      @status = message
    end

    def serialize
      # To be used when a transaction's status has not been set
      vending_status = case self.status
        when :new
          "Transaction has been created."
        when :vending
          "Transaction is still processing"
        when :completed
          "Transaction completed successfully"
        when :failed
          "Transaction has failed"
        end

      {
        id: self.id,
        user: self.user.serialize,
        items: self.items.map(&:serialize),
        cost: self.amount,
        created_on: self.created_on,
        status: self.status,
        message: "#{vending_status}: #{@status}"
      }
    end
end