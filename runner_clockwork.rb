#!/usr/bin/env ruby
# encoding: utf-8

##
# Run: export APP_ENV=development && bundle exec clockwork ./runner_clockwork.rb
# Run: export APP_ENV=production && bundle exec clockwork ./runner_clockwork.rb > /dev/null 2>&1 &
##

require 'redis'
$redis = Redis.new(host: $config['redis_alarm']['host'], port: $config['redis_alarm']['port'])

begin
  $redis.ping
rescue
  puts "error: Redis server unavailable."
  exit 1
end

require 'json'
require 'clockwork'

require 'sidekiq'

require_relative 'lib/workers'

module Clockwork

  every(1.minute, 'SidekiqJobs.set_comanies_in_redis') do
    RedisWorkers::Jobs.perform_async
  end   

end
