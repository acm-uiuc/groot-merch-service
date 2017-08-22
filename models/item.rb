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
  property :price, Integer
  property :name, String, required: true
  property :image, Text
  property :created_on, Date

  has n, :transactions, through: Resource, constraint: :destroy
  has n, :locations, constraint: :skip

  def self.validate(params, attributes)
    attributes.each do |attr|
      return [400, "Missing #{attr}"] unless params[attr] && !params[attr].empty?
    end

    [200, nil]
  end

  def total_stock
    locations.map(&:quantity).reduce(:+)
  end

  def in_stock
    total_stock != 0
  end

  def vend
    return false unless in_stock
    # find first location that has some quantity available
    location = locations.detect { |l| l.quantity > 0 }

    merch_access_key = Config.load_config('merch_pi')['access_key']
    ip_address = Config.load_config('merch_pi')['ip_address']

    # Make request to pi
    uri = URI.parse("http://#{ip_address}:5000/vend?item=#{location.pretty_location}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request['TOKEN'] = merch_access_key
    response = http.request(request)

    return unless response.code == '200'

    location.quantity -= 1
    location.save
  end

  def serialize
    {
      id: id,
      price: price,
      name: name,
      image: image,
      created_on: created_on,
      vending: locations.map(&:serialize),
      in_stock: in_stock,
      total_stock: total_stock
    }
  end
end
