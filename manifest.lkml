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
