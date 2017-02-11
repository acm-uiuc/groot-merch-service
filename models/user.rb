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

    def self.validate(params, attributes)
      attributes.each do |attr|
        return [400, "Missing #{attr}"] unless params[attr] && !params[attr].empty?
      end

      [200, nil]
    end

    def balance
      # TODO get balance from credits service
      @balance || = 0
    end

    def balance=(new_balance)
      # TODO make request to credits service to update balance
      @balance = new_balance
    end

    def self.generate_pin
      loop do
        pin = Random.new.rand(10000000..99999999)
        
        break unless User.first(pin: pin) # break if we found a pin not given to any user
      end
    end

    def serialize
      {
        id: self.id,
        netid: self.netid,
        pin: self.pin,
        created_on: self.created_on,
        balance: @balance
      }
    end
end