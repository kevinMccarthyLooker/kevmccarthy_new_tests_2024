project_name: "kevmccarthy_sandbox"

# # Use local_dependency: To enable referencing of another project
# # on this instance with include: statements
#
# local_dependency: {
#   project: "name_of_other_project"
# }

constant: test_constant {
  # value: "{{order_items.created_date._sql}}"
  # value: "matches_filter${order_items.created_date},`6 months`)"
  value: "NOT matches_filter(${order_items.created_date}, `6 months`) OR matches_filter(${products.brand}, `Levi's`)"
}

localization_settings: {
  default_locale: en
  localization_level: permissive
}

constant: constant_as_html_function {
  value: "
  {% assign local_var = function_input %}
  {% assign local_var = local_var | prepend: '$' %}
  {{local_var}}
  "

}

constant: date_format {
  value: "
    {% if _user_attributes['country'] == 'US'%}
      {{value | date: '%m/%d/%y' }}
    {% else %}
      {{value | date: '%d/%m/%y' }}
    {% endif %}
    "
}
