require 'active_record'

module Db
  class CompanyAccount < ActiveRecord::Base
  end

  class Company < ActiveRecord::Base
  end

  class UserCard < ActiveRecord::Base
  end

  class User < ActiveRecord::Base
  end

  class Tariff < ActiveRecord::Base
  end

  class TariffSetting < ActiveRecord::Base
  end

  class Truck < ActiveRecord::Base
    belongs_to :company
  end

  class OnBoardDevice < ActiveRecord::Base
    belongs_to :truck
  end
end