
- dashboard: dash_tile_positions_for_extended
  extends: dash_tile_positions_for_extension

  # title: dash tile positions for extension
  layout: newspaper
  preferred_viewer: dashboards-next
  # description: ''
  # preferred_slug: ROCtatwAW6MG5q7n9cNzq2

  elements:
  - title: dash tile positions for extension
    name: tile1
    model: km_tests
    explore: t
    type: table
    fields: [t.id, t.count]
    limit: 500
    query_timezone: America/Chicago
    listen: {}
    # row: 0
    # col: 0
    # width: 8
    # height: 6
  - title: dash tile positions for extension (Copy)
    name: tile2
    model: km_tests
    explore: t
    type: table
    fields: [t.id, t.count]
    limit: 500
    query_timezone: America/Chicago
    # row: 0
    # col: 8
    # width: 16
    # height: 6
  - title: dash tile positions for extension (Copy 2)
    name: tile3
    model: km_tests
    explore: t
    type: table
    fields: [t.id, t.count]
    limit: 500
    query_timezone: America/Chicago
    # row: 6
    # col: 0
    # width: 24
    # height: 18
  - title: dash tile positions for extension (Copy 3)
    name: tile4
    model: km_tests
    explore: t
    type: table
    fields: [t.id, t.count]
    limit: 500
    query_timezone: America/Chicago
    # row: 6
    # col: 0
    # width: 24
    # height: 18
