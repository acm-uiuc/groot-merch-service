require 'json'
require 'net/http'
require 'logger'

require_relative '../helpers/init'

class Jobs
  logger = Logger.new STDOUT
  logger.level = Logger::DEBUG
  logger.datetime_format = '%Y-%m-%d %H:%M:%S '

  def restock
    slack_message = 'These items need to be restocked: \n '
    Item.all.each do |i|
      slack_message += i.name + ' \n ' if i.total_stock < 5
    end
    groot = Config.load_config('groot')
    uri = URI(groot['host'] + '/notification')
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body = {
      services:
        [
          {
            name: 'slack',
            recipients: ['#merch-status']
          }
        ],
      message: slack_message
    }.to_json

    http = Net::HTTP.new(uri.host, uri.port)
    res = http.request(req)
    logger.error('HTTP Error: ' + res.code) if res.code != '200'
    logger.info(res.code)
    puts res.body
    puts slack_message
  end
end
