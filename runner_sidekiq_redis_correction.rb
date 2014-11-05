#!/usr/bin/env ruby
# encoding: utf-8

## Достаточно запуска только sidekiq
# Run: export APP_ENV=development && bundle exec sidekiq -C ./config/sidekiq.yml -r ./runner_sidekiq_redis_correction.rb
# Run: export APP_ENV=production && bundle exec sidekiq -C ./config/sidekiq.yml -r ./runner_sidekiq_redis_correction.rb
# Run: export APP_ENV=production && bundle exec sidekiq -d -C ./config/sidekiq.yml -r ./runner_sidekiq_redis_correction.rb --logfile log/redis_correction_jobs_production.log --pidfile tmp/sidekiq_redis_correction.pid


if ENV['APP_ENV']
  # require 'pry'
  
  require_relative 'config/config'
  $config = Configuration.load_config

  require 'logger'
  current_logger = Logger.new(STDOUT)
  current_logger.info "Started"
  

  require_relative 'lib/workers'
  require_relative 'lib/db'
  
  require 'redis'
  $redis = Redis.new(host: $config['redis_cache']['host'], port: $config['redis_cache']['port'])
  
  # Обновление редиса при обновлении грузовиков и устройств
  RedisCorrectionWorkers::Jobs.perform_async
else
  puts 'Error: not found "APP_ENV"!'
end