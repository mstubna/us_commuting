class @Cloropleth extends @Graph

  constructor: (@commuting_data, @parent_view) ->
    super()

    @margin =
      top: 10
      left: 10
      bottom: 25
      right: 10
    @aspect_ratio = 2/3

    @data = {}
    for datum in @commuting_data.data_by_geo
      @data[datum.data[0].id] = datum

    @construct_view()
    @render()

  construct_view: ->
    @graph_view_container = $("<div class='cloropleth graph small-12 columns'></div>")
    @parent_view.append $("<div class='row'></div>").append(@graph_view_container)
    @graph_view = d3.selectAll(@graph_view_container.toArray())
      .append('svg')

    @view = @graph_view.append('g')
      .attr('transform', "translate(#{@margin.left},#{@margin.top})")

    @boundary_view = @view.append('g')

    @tips = d3.tip().attr('class', 'd3-tip').offset([-10, 0])
    @boundary_view.call @tips
    @tips.html (d) =>
      obj = @data[d.id]
      "<p>#{obj.geo}</p>"

  render: =>
    super()

    @graph_view
      .attr('width', @dims.outer_width)
      .attr('height', @dims.outer_height)

    quantize = d3.scale.quantize()
      .domain([0, .05])
      .range(d3.range(9).map (i) -> "q" + i + "-9")

    projection = d3.geo.albersUsa()
      .scale(1.3*@dims.outer_width)
      .translate([@dims.outer_width/2, @dims.outer_height/2])

    # draw the US land boundaries, states, and counties
    # see: http://bl.ocks.org/mbostock/3734308
    path = d3.geo.path().projection(projection)
    d3.json 'vendor/us.json', (error, us) =>
      @boundary_view.remove()
      @boundary_view = @view.append('g')
      @boundary_view.append("path", ".boundary")
        .datum(topojson.mesh(us, us.objects.states, (a, b) -> a isnt b))
        .attr("class", "state-boundary")
        .attr("d", path)
      @boundary_view.append("path", ".boundary")
        .datum(topojson.feature(us, us.objects.land))
        .attr("class", "land")
        .attr("d", path)
      @boundary_view.insert("path", ".boundary")
        .datum(topojson.mesh(us, us.objects.counties, (a, b) ->
          a isnt b and not (a.id / 1000 ^ b.id / 1000) ))
        .attr("class", "county-boundary")
        .attr("d", path)
      @boundary_view.append("g")
        .attr("class", "counties")
        .selectAll("path")
        .data(topojson.feature(us, us.objects.counties).features)
        .enter().append("path")
        .attr("class", (d) =>
          if @data.hasOwnProperty d.id
            obj = @data[d.id]
            quantize(obj.data[6].bike / obj.data[6].total)
          else
            'none'
        )
        .attr("d", path)
        .on('mouseover', @tips.show)
        .on('mouseout', @tips.hide)
