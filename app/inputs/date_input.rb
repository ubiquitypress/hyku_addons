# frozen_string_literal: true

class HykuDateInput < SimpleForm::Inputs::DateTimeInput
  def input(wrapper_options = nil)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    @builder.send(:date_select, attribute_name, input_options, merged_input_options)
  end

  private

  def label_target
    date_order = input_options[:order] || I18n.t('date.order')
    position = date_order.first.to_sym
    position = ActionView::Helpers::DateTimeSelector::POSITION[position]

    "#{attribute_name}_#{position}i"
  end
end
