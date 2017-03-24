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
    property :netid, String, required: true, unique_index: true, length: 1...9
    property :pin, Integer, min: 10000000, max: 99999999, unique: true, required: true
    property :created_on, Date

    has n, :transactions, constraint: :destroy

    def self.validate(params, attributes)
      attributes.each do |attr|
        return [400, "Missing #{attr}"] unless params[attr] && !params[attr].empty?
        
        case attr
          when :items
            return [400, "Items should be specified in an array"] unless params[attr].kind_of?(Array)
          when :netid
            return [404, "User netid was not found in users service"] unless Auth.verify_netid(params[:netid])
        end
      end
      [200, nil]
    end

    def balance
      unless @balance
        @balance = Creditor.get_balance(self.netid)
      end
      
      @balance
    end

    def set_balance(new_balance, description = "Merch Transaction")
      successful = Creditor.update_balance(self.netid, new_balance - @balance, description)
      @balance = new_balance if successful
    end

    def self.generate_pin
      loop do
        pin = Random.new.rand(10000000..99999999)
        return pin unless User.first(pin: pin) # break if we found a pin not given to any user
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