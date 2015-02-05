$ ->
  FastClick.attach document.body
  $(document).foundation()

  view = $('#container')
  new Scatterplot commuting_data, view
  new Linegraph commuting_data, view
  new Bargraph commuting_data, view
