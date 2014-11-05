require 'socket'
require 'json'
require 'bunny'

module RedisCorrectionWorkers
  class Jobs
    include Sidekiq::Worker
    sidekiq_options queue: :redis_correction

    def perform
      @current_logger = CustomLogger.new
      @current_logger.info "NOTIFICATIONS: Started"

      @bunny = Bunny.new(host: $config['rabbit']['host'], 
        port: $config['rabbit']['port'], 
        user: $config['rabbit']['user'], 
        password: $config['rabbit']['password'],
        vhost: $config['rabbit']['vhost'])

      begin
        @current_logger.info " [*] RUBY Waiting for messages. To exit press CTRL+C"
        @bunny.start
        @ch   = @bunny.create_channel

        run
      rescue Interrupt => _
        @bunny.close
        @current_logger.info "NOTIFICATIONS: Stopped"
        @current_logger.close_syslog
        exit(0)
      end 
    end

    def run
      @current_logger.info "NOTIFICATIONS: worked"
      @current_logger.info "Выполняем run, ждем информацию из АРМ. input_queue #{$config['runner']['input_correction_queue']}"  
      q    = @ch.queue($config['runner']['input_correction_queue'], :durable => true) 
      q.subscribe(:block => true, :manual_ack => true) do |delivery_info, properties, body|
        data_hash = Hash.new
        data_hash['delivery_tag'] = delivery_info.delivery_tag
        data_hash['data'] = body

        @current_logger.info "Bunny получили данные #{data_hash}"

        if data_hash.present?
          data = eval(data_hash['data'])
          @current_logger.info "Обработка поступившей информации"
          @current_logger.info data
          @current_logger.info data[:operation_type]
          @current_logger.info data[:class_name]
          @current_logger.info data[:item]          
          correct_redis(data[:operation_type], data[:class_name], data[:item])
          @current_logger.info "Завершение обработки поступившей информации"
        end

        @current_logger.info "Отправка ack в #{$config['runner']['input_correction_queue']} RabbitMQ delivery_tag: #{delivery_info.delivery_tag}"
        @ch.ack(delivery_info.delivery_tag)  
        @current_logger.info "Обработана корректировка redis #{data_hash['data']}"    
      end
    end

    def correct_redis(operation_type, class_name, item)
      if class_name == "on_board_device"
        item_id = item['number']
      else
        item_id = item['id']
      end

      case operation_type
      when 'update'
        $redis.set("#{$config['redis_cache']['prefix']}:#{class_name}:#{item_id}", item)
        @current_logger.info "Redis updated: #{$config['redis_cache']['prefix']}:#{class_name}:#{item_id} set #{item}"
      when 'insert'
        $redis.set("#{$config['redis_cache']['prefix']}:#{class_name}:#{item_id}", item)
        @current_logger.info "Redis inserted: #{$config['redis_cache']['prefix']}:#{class_name}:#{item_id} set #{item}"
      when 'delete'
        $redis.set("#{$config['redis_cache']['prefix']}:#{class_name}:#{item_id}", nil)
        @current_logger.info "Redis deleted: #{$config['redis_cache']['prefix']}:#{class_name}:#{item_id} set null"
      end        
    end
  end

  class CustomLogger
    def initialize(log_path=STDOUT)
      begin
        @logger = Logger.new(log_path)
        @remote_syslog = UDPSocket.new
        @remote_syslog.connect($config['remote_syslog']['host'], $config['remote_syslog']['port'])
      rescue Exception => e
        puts "LOGGER ERROR! #{e}"
      end
    end

    def info(msg)
      begin
        @logger.info p msg 
        @remote_syslog.send("redis_correction_worker: #{msg}", 0)
      rescue Exception => e
        puts "LOGGER ERROR! #{e}"
      end
    end 

    def close_syslog
      @remote_syslog.close
    end
  end
end