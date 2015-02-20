#!/usr/bin/env ruby
# encoding: utf-8



if ENV['APP_ENV']
  # require 'pry'
  
  require_relative 'config/config'
  $config = Configuration.load_config

  require 'logger'
  current_logger = Logger.new(STDOUT)
  current_logger.info "Started"
  

  require_relative 'lib/single_redis'
  require_relative 'lib/db'
 
  require 'active_record'
  ActiveRecord::Base.establish_connection(
        :adapter  => $config['database']['adapter'],
        :database => $config['database']['database'],
        :username => $config['database']['username'],
        :password => $config['database']['password'],
        :host     => $config['database']['host'])
  
  require 'redis'
  $redis = Redis.new(host: $config['redis_cache']['host'], port: $config['redis_cache']['port'], db: $config['redis_cache']['db'])
  
  # разовая задача на внесение информации
  SingleRedis::Custom.perform

else
  puts 'Error: not found "APP_ENV"!'
end