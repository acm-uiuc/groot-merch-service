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
  SERVICES_URL = 'http://localhost:8000'
  CREDITS_URL = "/credits/users/"
  CREATE_TRANSACTION = "/credits/transactions"

  def self.get_balance(netid)
    groot_access_key = Config.load_config("groot")["access_key"]
    
    uri = URI.parse("#{SERVICES_URL}#{CREDITS_URL}#{netid}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    request['Authorization'] = groot_access_key
    
    response = http.request(request)

    return 0 unless response.code == "200"
    JSON.parse(response.body)["balance"]
  end

  def self.update_balance(netid, new_diff, description)
    groot_access_key = Config.load_config("groot")["access_key"]

    uri = URI.parse("#{SERVICES_URL}#{CREATE_TRANSACTION}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request['Authorization'] = groot_access_key
    request.body = {
      netid: netid,
      amount: new_diff,
      description: description
    }.to_json
    
    response = http.request(request)
    binding.pry
    response.code == "200"
  end
end