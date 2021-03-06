# Copyright © 2017, ACM@UIUC
#
# This file is part of the Groot Project.
#
# The Groot Project is open source software, released under the University of
# Illinois/NCSA Open Source License. You should have received a copy of
# this license in a file with the distribution.

require 'json'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/cross_origin'
require 'data_mapper'
require 'dm-migrations'
require 'dm_noisy_failures'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-mysql-adapter'
require 'better_errors'
require 'json'
require 'rufus-scheduler'

require_relative 'helpers/init'
require_relative 'routes/init'
require_relative 'models/init'
require_relative 'lib/jobs'

class GrootMerchService < Sinatra::Base
  register Sinatra::AuthsRoutes
  register Sinatra::UsersRoutes
  register Sinatra::TransactionsRoutes
  register Sinatra::ItemsRoutes
  register Sinatra::LocationsRoutes
  register Sinatra::CrossOrigin

  configure do
    enable :cross_origin
    enable :logging
  end

  configure :development, :production do
    db = Config.load_config('database')
    DataMapper.setup(:default, 'mysql://' + db['user'] + ':' + db['password'] + '@' + db['hostname'] + '/' + db['name'])
  end

  configure :development do
    enable :unsecure
    register Sinatra::Reloader

    DataMapper::Logger.new($stdout, :debug)
    use BetterErrors::Middleware

    BetterErrors.application_root = File.expand_path('..', __FILE__)
    DataMapper.auto_upgrade!
  end

  configure :test do
    db = Config.load_config('test_database')
    DataMapper.setup(:default, 'mysql://' + db['user'] + ':' + db['password'] + '@' + db['hostname'] + '/' + db['name'])
    DataMapper.auto_upgrade!
  end

  configure :production do
    disable :unsecure
  end

  configure do
    scheduler = Rufus::Scheduler.new
    jobs = Jobs.new
    scheduler.every '8h' do
      jobs.restock
    end
  end
  DataMapper.finalize
end
