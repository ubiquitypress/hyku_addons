# frozen_string_literal: true

# this is needed so that works imported via autopopulation are set to inactive and as a result
# dont need to show in the Dashboard
#
::Hyrax::Dashboard::WorksSearchBuilder.class_eval do
  self.default_processor_chain += [:only_active_works]
end

::Hyrax::My::WorksSearchBuilder.class_eval do
  self.default_processor_chain += [:only_active_works]
end
