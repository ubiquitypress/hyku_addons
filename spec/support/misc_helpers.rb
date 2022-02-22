# frozen_string_literal: true

# Provides a list of schema work types
#
# Requires you set up a Site instance:
# let(:account) { build_stubbed(:account) }
# let(:site) { Site.new(account: account) }
# before do
#   allow(Site).to receive(:instance).and_return(site)
# end
def schema_work_types
  Site.instance.available_works.select { |wt| wt.constantize.new.schema_driven? }
end
