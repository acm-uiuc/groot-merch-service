require_relative 'response_format'

module Errors
  VERIFY_GROOT = ResponseFormat.error "Request did not originate from groot"
  VERIFY_ADMIN = ResponseFormat.error "User does not have appropriate credentials"
  USER_NOT_FOUND = ResponseFormat.error "User not found"
  ITEM_NOT_FOUND = ResponseFormat.error "Item not found"
  INSUFFICENT_CREDITS = ResponseFormat.error "User does not have sufficient credits"
end