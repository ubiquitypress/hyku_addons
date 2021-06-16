# frozen_string_literal: true

namespace :hyku_addons do
  namespace :model do
    task :generate_yaml, [:model_name] => [:environment] do |_t, args|
      model = args[:model_name].safe_constantize
      attributes = {}
      model.properties.each do |term, config|
        attributes[term] = {}
        attributes[term]['type'] = config.type.to_s if config.type.present?
        attributes[term]['predicate'] = config.predicate.to_s
        attributes[term]['multiple'] = config.multiple? if config.respond_to?(:multiple?)
        attributes[term]['index_keys'] = index_keys(config.term, config.type, config.behaviors)
        attributes[term]['form'] = {}
        attributes[term]['form']['required'] = false
        attributes[term]['form']['primary'] = false
        attributes[term]['form']['multiple'] = config.multiple? if config.respond_to?(:multiple?)
      end
      puts ({ 'attributes' => attributes }).to_yaml
    end
  end
end

def index_keys(term, type, behaviors)
  Array(behaviors).map do |behavior|
    if behavior == :stored_searchable
      if type == :string || type == :text
        "#{term}_tesim"
      else
        "unknown"
      end
    elsif behavior == :facetable
      "#{term}_sim"
    else
      "unknown"
    end
  end
end
