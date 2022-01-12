# Avoid media pluralizing to medium
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.irregular "media", "medias"
end

