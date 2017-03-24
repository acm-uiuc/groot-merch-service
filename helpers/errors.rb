# Copyright © 2017, ACM@UIUC
#
# This file is part of the Groot Project.  
# 
# The Groot Project is open source software, released under the University of
# Illinois/NCSA Open Source License. You should have received a copy of
# this license in a file with the distribution.
require_relative 'response_format'

module Errors
  VERIFY_GROOT = ResponseFormat.error "Request did not originate from groot"
  VERIFY_ADMIN = ResponseFormat.error "User does not have appropriate credentials"
  USER_NOT_FOUND = ResponseFormat.error "User not found"
  ITEM_NOT_FOUND = ResponseFormat.error "Item not found"
  INSUFFICENT_CREDITS = ResponseFormat.error "User does not have sufficient credits"
  INSUFFICIENT_QUANTITY = ResponseFormat.error "Item does not have sufficient quantity"
  INVALID_PIN = ResponseFormat.error "No such user exists with that pin"
  BALANCE_ERROR = ResponseFormat.error "Error fetching balance. Please check the credits service."
end