connection: "kevmccarthy_bq"

view: action_test {
  derived_table: {
    sql: select 1 as id ;;
  }
  dimension: id {
    action:  {
      label: "Label to Appear in Action Menu"
      url: "https://example.com/posts"
      icon_url: "https://looker.com/favicon.ico"
      # form_url: "https://example.com/ping/{{ value }}/form.json"
      param: {
        name: "name string"
        value: "value string"
      }
      form_param: {
        name:  "name string"
        type: select
        label:  "possibly-localized-string"
        option: {
          name:  "name string"
          label:  "possibly-localized-string"
        }
        required:  no
        description:  "possibly-localized-string"
        default:  "string"
      }
      # user_attribute_param: {
      #   user_attribute: user_attribute_name
      #   name: "name_for_json_payload"
      # }
    }
  }
}
explore: action_test {}
