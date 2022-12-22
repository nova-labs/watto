module FieldsHelper
  def print_field_user_values(values)
    Array(print_field_user_value(values))
  end

  def print_field_user_value(values)
    return if values.empty?

    field = values.first.field

    case field.field_type
    when "Boolean"
      (values.first.value == "t").to_s
    when "Number"
      values.first.value
    when "DateTime"
      values.first.value
    when "String"
      values.first.value

      # Why does "choice" find the field allowed value by value, but
      # "MultipleChoice" find the field allowed value by uid? Good question.
      # The WAAPI returns fields for the contact no value when it is multiple
      # choice, instead they give the ID. That ID appens to map to the right
      # thing.
      #
      # When it is a "Choice" field then they like to stuff the value of that
      # AllowedValue.
      #
      # Examples. Here is a Choice:
      #
      # {
      #   "FieldName": "Membership status",
      #   "Value": {
      #     "Id":1,
      #     "Label":"Active",
      #     "Value":"Active",
      #     "SelectedByDefault":false,
      #     "Position":0
      #   },
      #   "SystemCode":"Status"
      # }
      #
      #
      #  {
      #    "FieldName":"NL Signoff Permissions",
      #    "Value":[
      #       {
      #          "Id":14917545,
      #          "Label":"WW"
      #       }
      #    ],
      #    "SystemCode":"custom-13082555"
      # }
      #

    when "Choice"
      values.map do |v|
        v.field.field_allowed_values.find_by(value: v.value)&.label || "Nil"
        v.label || "Nil"
      end
    when "MultipleChoice"
      values.map do |v|
        #v.field.field_allowed_values.find_by(uid: v.value).label
        v.label || "Nil"
      end
    else

    end

  end

  def user_field_value_badge(field_value)
    classes = ["badge", "badge-default"]
    classes = ["badge", "badge-default", "badge-#{field_value.category}".downcase]
    classes << "badge-novapass" if field_value.novapass?

    content_tag(:span, field_value.category, class: classes)
  end
end
