class LtuSerial < ActiveFedora::Base
  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:ltu_serial)
end
