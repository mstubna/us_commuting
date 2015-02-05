class @Scatterplot extends @Graph

  constructor: (@commuting_data, @parent_view) ->
    super()

    @margin =
      top: 10
      left: 10
      bottom: 25
      right: 10
    @aspect_ratio = 1/2

    # sort data by most bike commuters
    @data = @commuting_data.data_by_geo.slice()
    @data.sort (a, b) ->
      b.data[6].bike/b.data[6].total - a.data[6].bike/a.data[6].total

    @construct_view()
    @render()

  construct_view: ->
    view = $("<div class='row'></div>")
    @graph_view_container = $("<div class='scatterplot graph medium-12 large-9 columns'></div>")
    @legend_view_container = $("<div class='scatterplot legend medium-12 large-2 columns'></div>")
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
      .attr('class', 'geo')

    @points = @geos
      .selectAll('.circle')
      .data((d) -> d.data)
      .enter()
      .append('circle')
      .attr('class', 'circle')

    @x_axis_view = graph.append('g')
      .attr('class', 'axis x_axis')

    @tips = d3.tip().attr('class', 'd3-tip').offset([-10, 0])
    @graph_view.call @tips

    @tips.html (d) ->
      "<p>#{d.geo}</p>"

    self = this
    @points
      .on('mouseover', (d) ->
        self.tips.show(d)
        parent = d3.select(this.parentNode).classed('active',true)
        this.parentNode.parentNode.appendChild(this.parentNode))
      .on('mouseout', (d) ->
        self.tips.hide(d)
        d3.select(this.parentNode)
          .classed('active',false))

  render: =>
    super()

    @x_scale = d3.scale.ordinal()
      .domain(@commuting_data.years)
      .rangePoints([0, @dims.inner_width], 1)

    @y_scale = d3.scale.linear()
      .domain([0, @data.length-1])
      .range([@dims.inner_height, 0])

    @graph_view
      .attr('width', @dims.outer_width)
      .attr('height', @dims.outer_height)

    @geos
      .attr('transform', (d,i) => "translate(0,#{@y_scale(@data.length-1-i)})")

    @points
      .attr('r', (d) -> d.bike/d.total*200)
      .attr('cx', (d) => @x_scale(d.year))

    @x_axis = d3.svg.axis().orient('bottom').scale(@x_scale)
    @x_axis_view.attr('transform', "translate(0,#{@dims.inner_height})")
    @x_axis_view.call @x_axis
