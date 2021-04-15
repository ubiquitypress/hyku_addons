# frozen_string_literal: true
#
module Bulkrax
  module EntriesHelper
    def entry_error_coderay(v)
      if v.is_a? Hash
        change_description = "#{v[:path]}: #{v[:value]}"
        label_klazz = case v[:op]&.to_s
                      when 'add' then 'success'
                      when 'move' then 'info'
                      when 'remove' then 'danger'
                      else 'info'
                      end
        content_tag :span, change_description, class: "label label-lg label-#{label_klazz} overflow-wrap-break"
      else
        coderay(v, wrap: :page, css: :class, tab_width: 200, break_lines: true)
      end
    end
  end
end
