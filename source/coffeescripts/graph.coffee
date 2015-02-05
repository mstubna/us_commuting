class @Graph

  constructor: ->
    # rerenders the graph on widow resize event
    $(window).on 'resize', Foundation.utils.throttle(@render, 300)

  # Toggles a class based on the condition argument
  add_remove_class: ($obj, class_name, condition) ->
    if condition
      $obj.addClass class_name
    else
      $obj.removeClass class_name
    return

  # Gets the outer dimensions of the object
  get_dimensions: =>
    outer_width = @graph_view_container.width()
    outer_height = outer_width * @aspect_ratio
    inner_width = outer_width - (@margin.left + @margin.right)
    inner_height = outer_height - (@margin.top + @margin.bottom)
    { outer_width, outer_height, inner_width, inner_height }

  render: =>
    @dims = @get_dimensions()
