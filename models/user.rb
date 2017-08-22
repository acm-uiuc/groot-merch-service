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
  property :pin, Integer, min: 10_000_000, max: 99_999_999, unique: true, required: true
  property :created_on, Date

  has n, :transactions, constraint: :destroy

  def self.validate(params, attributes)
    attributes.each do |attr|
      return [400, "Missing #{attr}"] unless params[attr] && !params[attr].empty?

      case attr
      when :items
        return [400, 'Items should be specified in an array'] unless params[attr].is_a?(Array)
      when :netid
        return [404, 'User netid was not found in users service'] unless Auth.verify_netid(params[:netid])
      end
    end
    [200, nil]
  end

  def balance
    return @balance if @balance

    @balance = Creditor.get_balance(netid)
    @balance
  end

  def set_balance(new_balance, description = 'Merch Transaction')
    successful = Creditor.update_balance(netid, new_balance - @balance, description)
    @balance = new_balance if successful
  end

  def self.generate_pin
    loop do
      pin = Random.new.rand(10_000_000..99_999_999)
      return pin unless User.first(pin: pin) # break if we found a pin not given to any user
    end
  end

  def serialize
    {
      id: id,
      netid: netid,
      pin: pin,
      created_on: created_on,
      balance: balance
    }
  end
end
