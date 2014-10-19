module RedisWorkers
  class Jobs
    include Sidekiq::Worker
    sidekiq_options queue: :scheduled_jobs

    def perform
      p "Clock worked"

      @current_logger = Logger.new("#{File.dirname(__FILE__)}/../../log/sidekiq_worker_#{ENV['APP_ENV']}.log")
      @current_logger.info "NOTIFICATIONS: Started"      
      
 
      # что храним в редисе
      # Db::OnBoardDevice
      # Db::Truck
      # Db::Company
      # Db::Tariff
      # Db::TariffSetting
      
      new_last_time_checked = Time.now
      if $redis.get("svp:last_time_checked").blank?
        $redis.set("svp:last_time_checked", new_last_time_checked)

        last_obd = Db::OnBoardDevice.all
        if last_obd.present?
          move_to_redis(last_obd)
        end

        last_trucks = Db::Truck.all
        if last_trucks.present?
          move_to_redis(last_trucks)
        end

        last_companies = Db::UserCard.all
        if last_companies.present?
          move_to_redis(last_companies)
        end

        last_tariff = Db::Tariff.all
        if last_tariff.present?
          move_to_redis(last_tariff)
        end

        last_tariff_settings = Db::TariffSetting.all
        if last_tariff_settings.present?
          $redis.set("svp:tariff_setting", last_tariff_settings.last.code)
        end      
      else
        last_time_checked = Time.parse($redis.get("svp:last_time_checked")) 

        last_obd = Db::OnBoardDevice.where("updated_at > ?", last_time_checked)
        if last_obd.present?
          move_to_redis(last_obd)
        end

        last_trucks = Db::Truck.where("updated_at > ?", last_time_checked)
        if last_trucks.present?
          move_to_redis(last_trucks)
        end

        last_companies = Db::UserCard.where("updated_at > ?", last_time_checked)
        if last_companies.present?
          move_to_redis(last_companies)
        end

        last_tariff = Db::Tariff.where("updated_at > ?", last_time_checked)
        if last_tariff.present?
          move_to_redis(last_tariff)
        end

        last_tariff_settings = Db::TariffSetting.where("updated_at > ?", last_time_checked)
        if last_tariff_settings.present?
          $redis.set("svp:tariff_setting", last_tariff_settings.last.code)
        end
      end


      $redis.set("svp:last_time_checked", new_last_time_checked)
      @current_logger.info "NOTIFICATIONS: Stopped"
    end

    def move_to_redis(last_records)
      last_records.each do |obj|
        obj_redis_name = obj.class.name.gsub("Db::", "").underscore.to_s
        # on_board_device хранятся по imei - это number в db
        if obj_redis_name == "on_board_device"
          obj_id = obj.number
        else
          obj_id = obj.id
        end
        h = Hash.new
        # убираем косяк с обратной конвертацией времени
        obj.attributes.each {|key, value| h[key] = value.to_s }
        $redis.set("svp:#{obj_redis_name}:#{obj_id}", h)
      end
    end
  end
end