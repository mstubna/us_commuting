class @Bargraph extends @Graph

  constructor: (@commuting_data, @parent_view) ->
    super()

    @margin =
      top: 10
      left: 20
      bottom: 25
      right: 10
    @aspect_ratio = 2/3

    # sort data by percent improved in biking
    @percent_improved = (d) ->
      result = (d.data[6].bike - d.data[0].bike) / d.data[0].bike
      if isNaN(result) or not isFinite(result) then 0 else result

    # sort by percent improved
    @data = @commuting_data.data_by_geo.slice()
    @data.sort (a, b) =>
      @percent_improved(a) - @percent_improved(b)

    @construct_view()
    @render()

  construct_view: ->
    view = $("<div class='row'></div>")
    @graph_view_container = $("<div class='bargraph graph medium-12 large-9 columns'></div>")
    @legend_view_container = $("<div class='bargraph legend medium-12 large-2 columns'></div>")
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

    @bars = @geos
      .append('rect')
      .attr('class', 'bar')

    @x_axis_view = graph.append('g')
      .attr('class', 'axis x_axis')

    @y_axis_view = graph.append('g')
      .attr('class', 'axis y_axis')

    @tips = d3.tip().attr('class', 'd3-tip').offset([-10, 0])
    @graph_view.call @tips

    format = d3.format('.1f')
    @tips.html (d) =>
      val = @percent_improved d
      str = if val < 0
        "#{format(-@percent_improved(d)*100)}% decrease"
      else
        "#{format(@percent_improved(d)*100)}% increase"
      "<p>#{d.geo}</p>
      <p>#{str}</p>
      <p>from #{format(d.data[0].bike/d.data[0].total*100)}% to #{format(d.data[6].bike/d.data[6].total*100)}%</p>"

    self = this
    @geos
      .on('mouseover', (d) ->
        self.tips.show(d)
        d3.select(this).classed('active', true))
      .on('mouseout', (d) ->
        self.tips.hide(d)
        d3.select(this).classed('active', false))

  render: =>
    super()

    @x_scale = d3.scale.linear()
      .domain([@data.length-1, 0])
      .range([@margin.left, @dims.inner_width])

    @y_scale = d3.scale.linear()
      .domain(d3.extent(@data, (d) => @percent_improved(d)))
      .range([@dims.inner_height, @margin.top])

    @graph_view
      .attr('width', @dims.outer_width)
      .attr('height', @dims.outer_height)

    @bars
      .attr('x', (d,i) => @x_scale(i))
      .attr('y', (d) => @y_scale(Math.max(0,@percent_improved(d))))
      .attr('width', '0.2em')
      .attr('height', (d) => Math.abs(-@y_scale(@percent_improved(d)) + @y_scale(0)))

    @y_axis = d3.svg.axis()
      .orient('left')
      .scale(@y_scale)
      .tickFormat((d) -> Math.round(d*100))
    @y_axis_view.attr('transform', "translate(#{@margin.left},0)")
    @y_axis_view.call @y_axis
