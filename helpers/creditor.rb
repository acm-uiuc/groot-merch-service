# Copyright © 2017, ACM@UIUC
#
# This file is part of the Groot Project.
#
# The Groot Project is open source software, released under the University of
# Illinois/NCSA Open Source License. You should have received a copy of
# this license in a file with the distribution.
require 'net/http'
require 'uri'
require 'pry'

module Creditor
  CREDITS_URL = '/credits/users/'.freeze
  CREATE_TRANSACTION = '/credits/transactions'.freeze

  def self.get_balance(netid)
    uri = URI.parse("#{Auth.services_url}#{CREDITS_URL}#{netid}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    request['Authorization'] = Auth.groot_access_key

    response = http.request(request)

    return 0 unless response.code == '200'
    JSON.parse(response.body)['balance']
  end

  def self.update_balance(netid, new_diff, description)
    uri = URI.parse("#{Auth.services_url}#{CREATE_TRANSACTION}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request['Authorization'] = Auth.groot_access_key
    request['Accept'] = 'application/json'
    request['Content-Type'] = 'application/json'
    request.body = {
      netid: netid,
      amount: new_diff,
      description: description
    }.to_json

    response = http.request(request)
    response.code == '200'
  end
end
