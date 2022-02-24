# frozen_string_literal: true

Hyrax::Identifier::Dispatcher.class_eval do
  def assign_for(object:, attribute: :identifier)
    record = registrar.register!(object: object)
    object.public_send("#{attribute}=".to_sym, Array.wrap(record.identifier))
    object
  end
end
