class @Linegraph extends @Graph

  constructor: (@commuting_data, @parent_view) ->
    super()

    @margin =
      top: 10
      left: 20
      bottom: 25
      right: 10
    @aspect_ratio = 2/3

    @data = @commuting_data.data_by_geo.slice()

    @construct_view()
    @render()

  construct_view: ->
    view = $("<div class='row'></div>")
    @graph_view_container = $("<div class='linegraph graph medium-12 large-9 columns'></div>")
    @legend_view_container = $("<div class='linegraph legend medium-12 large-2 columns'></div>")
    view.append [
      @graph_view_container
      @legend_view_container ]
    @parent_view.append view

    @graph_view = d3.selectAll(@graph_view_container.toArray())
      .append('svg')

    graph = @graph_view.append('g')
      .attr('transform', "translate(#{@margin.left},#{@margin.top})")

    @geos = graph
      .selectAll('.geo')
      .data(@data)
      .enter()
      .append('g')
      .attr('class', (d) -> "geo #{d.geo}")

    @lines = @geos
      .append('path')
      .attr('class', 'line')

    @x_axis_view = graph.append('g')
      .attr('class', 'axis x_axis')

    @y_axis_view = graph.append('g')
      .attr('class', 'axis y_axis')

    @tips = d3.tip().attr('class', 'd3-tip').offset([-10, 0])
    @graph_view.call @tips

    @tips.html (d) ->
      "<p>#{d.geo}</p>"

    self = this
    @lines
      .on('mouseover', (d) ->
        self.tips.show(d)
        d3.select(this).classed('active', true)
        this.parentNode.parentNode.appendChild(this.parentNode))
      .on('mouseout', (d) ->
        self.tips.hide(d)
        d3.select(this).classed('active', false))

  render: =>
    super()

    @x_scale = d3.scale.ordinal()
      .domain(@commuting_data.years)
      .rangePoints([@margin.left, @dims.inner_width], .3)

    @y_scale = d3.scale.linear()
      .domain([0, d3.max(@data, (d) -> d.data[6].bike/d.data[6].total)])
      .range([@dims.inner_height, @margin.top])

    @color_scale = d3.scale.quantize()
      .domain([0, 3])
      .range(['rgb(239,243,255)','rgb(189,215,231)','rgb(107,174,214)','rgb(49,130,189)','rgb(8,81,156)'])

    @graph_view
      .attr('width', @dims.outer_width)
      .attr('height', @dims.outer_height)

    line = d3.svg.line()
      .x( (d) => @x_scale(d.year))
      .y( (d) => @y_scale(d.bike/d.total))

    @lines
      .attr('d', (d) => line(d.data))
      .attr('stroke', (d) => @color_scale(((d.data[6].bike-d.data[0].bike)/(d.data[0].bike))))

    @x_axis = d3.svg.axis()
      .orient('bottom')
      .scale(@x_scale)
    @x_axis_view.attr('transform', "translate(0,#{@dims.inner_height})")
    @x_axis_view.call @x_axis

    @y_axis = d3.svg.axis()
      .orient('left')
      .scale(@y_scale)
      .tickFormat((d) -> Math.round(d*100))
    @y_axis_view.attr('transform', "translate(#{@margin.left},0)")
    @y_axis_view.call @y_axis
