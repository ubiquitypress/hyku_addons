# frozen_string_literal: true

require "maremma"

# Attempts were made to use active_support  or modules to override this via module include or prepend
# but it did not work hence module_eval was used to re-open the module and override the method in the gem
#
Maremma.module_eval do
  def self.parse_response(string, options = {})
    string = string.dup
    string = if options[:skip_encoding]
               string
             else
               string.force_encoding(Encoding::UTF_8).encode(
                 Encoding.find("UTF-8"),
                 invalid: :replace,
                 undef: :replace,
                 replace: "?"
               )
             end
    return string if options[:raw]

    from_json(string) || from_xml(string) || from_string(string)
  end
end
