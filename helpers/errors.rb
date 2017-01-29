require_relative 'response_format'

module Errors
  VERIFY_GROOT = ResponseFormat.error "Request did not originate from groot"
end