# - dashboard: test_lookml_sync
#   title: hide with extension test
#   layout: newspaper
#   elements:
#   - title: to be hidden
#     name: test lookml sync
#     model: km_tests
#     explore: test_grouping_sets
#     type: table
#     fields: [test_grouping_sets.broken_down_by_list, test_grouping_sets.row_count,test_grouping_sets.status]
#     width:  "{{ _user_attributes['id'] }}"
#   - title: main
#     name: test lookml sync2
#     model: km_tests
#     explore: test_grouping_sets
#     type: table
#     fields: [test_grouping_sets.broken_down_by_list, test_grouping_sets.row_count,test_grouping_sets.status]
#   - title: test_user_attribute filter
#     name: test_user_attribute filter
#     model: km_tests
#     explore: test_grouping_sets
#     type: table
#     fields: [test_grouping_sets.broken_down_by_list, test_grouping_sets.row_count,
#       test_grouping_sets.status]
#     filters: {}
#     sorts: [test_grouping_sets.row_count desc 0]
#     limit: 5000
#     column_limit: 50
#     show_view_names: false
#     show_row_numbers: true
#     truncate_column_names: false
#     hide_totals: false
#     hide_row_totals: false
#     table_theme: editable
#     limit_displayed_rows: false
#     enable_conditional_formatting: false
#     conditional_formatting_include_totals: false
#     conditional_formatting_include_nulls: false
#     defaults_version: 1
#     listen:
#       Status: test_grouping_sets.status
#   filters:
#   - name: Status
#     title: "{{ _user_attributes['last_name'] }}"
#     type: field_filter
#     default_value: "{{ _user_attributes['last_name'] }}"
#     allow_multiple_values: true
#     required: false
#     ui_config:
#       type: advanced
#       display: popover
#     model: km_tests
#     explore: test_grouping_sets
#     listens_to_filters: []
#     field: test_grouping_sets.status
