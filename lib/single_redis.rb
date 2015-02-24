module SingleRedis
  class Custom
    def self.perform
      p "Single task worked"

      # @current_logger = Logger.new("#{File.dirname(__FILE__)}/../../log/single_sidekiq_worker_#{ENV['APP_ENV']}.log")
      @current_logger = Logger.new(STDOUT)
      @current_logger.info "NOTIFICATIONS: Started SingleRedis"      
           

      last_obd = Db::OnBoardDevice.all
      if last_obd.present?
        move_to_redis(last_obd)
      end

      last_trucks = Db::Truck.all
      if last_trucks.present?
        move_to_redis(last_trucks)
      end

      last_obd = Db::CompanyAccount.all
      if last_obd.present?
        move_to_redis(last_obd)
      end

      last_company = Db::Company.all
      if last_company.present?
        move_to_redis(last_company)
      end


      @current_logger.info "NOTIFICATIONS: Stopped SingleRedis"
    end

    def self.move_to_redis(last_records)
      last_records.each do |obj|
        p obj_redis_name = obj.class.name.gsub("Db::", "").underscore.to_s
        # on_board_device хранятся по imei - это number в db
        if obj_redis_name == "on_board_device"
          p obj_id = obj.imei
        else
          p obj_id = obj.id
        end
        h = Hash.new
        # убираем косяк с обратной конвертацией времени
        obj.attributes.each {|key, value| h[key] = value.to_s }
        $redis.set("#{$config['redis_cache']['prefix']}:#{obj_redis_name}:#{obj_id}", h)
      end
    end
  end
end