https = require 'https'
querystring = require 'querystring'
async = require 'async'
request = require 'request'
d3 = require 'd3'

module.exports = (grunt) ->

  # Creates the data files used by the app
  grunt.registerTask 'create_data_files', ->
    done = this.async()

    # load the commuting data from the individual raw data files
    commuting_data = load_data()
    for d in commuting_data
      console.log "year #{d.year} file has #{d.data.length} entries"

    # convenience structures
    data_by_geo = aggregate_data_by_geo commuting_data
    years = get_years commuting_data

    # look up lat_long data as necessary
    lat_long = grunt.file.readJSON 'source/data/lat_long_data.json'
    key = grunt.file.readYAML('secrets/geocoding_keys.yaml').google_key
    async.eachSeries commuting_data
    , (yr, cb) ->
      async.eachSeries yr.data
      , (obj, cb1) ->
        unless lat_long.hasOwnProperty(obj.geo)
          console.log "looking up #{obj.geo}"
          address = obj.geo.replace(' Metro Area', '')
          get_lat_long_for_address address
          , key
          , (err, ll) ->
            if err?
              console.log "error looking up #{obj.geo}: #{JSON.stringify(err)}"
              cb1 err
            else
              console.log "result: #{JSON.stringify(ll)}"
              lat_long[obj.geo] = ll
              cb1()
        else
          cb1()
      , (err) ->
        cb err
    , (err) ->
      done(err) if err?

      # save the output
      grunt.file.write 'source/data/lat_long_data.json', JSON.stringify(lat_long, null, '\t')
      grunt.file.write 'source/data/commuting_data.js', "commuting_data = #{JSON.stringify({ years, data_by_geo, lat_long })}"

      done()

  # Uses the Google API to geocode the address
  get_lat_long_for_address = (address, key, callback) ->
    query = querystring.stringify { address, key }
    request {
      url: "https://maps.googleapis.com/maps/api/geocode/json?#{query}"
      json: true
    }
    , (err, response, body) =>
      callback err, body?.results[0]?.geometry?.location

  load_data = ->
    ['07', '08', '09', '10', '11', '12', '13'].map (yr_str) ->
      year: "20#{yr_str}"
      data: load_data_file(yr_str)

  load_data_file = (yr_str) ->
    path = "data/aff_download_county/ACS_#{yr_str}_1YR_B08006_with_ann.csv"
    str = grunt.file.read path

    # later files have different identifiers, so unify them here
    str = str.replace(/Estimate; Total: - Car, truck, or van:/gi, 'Estimate; Car, truck, or van:')
    str = str.replace(/Estimate; Total: - Public transportation (excluding taxicab):/gi, 'Estimate; Public transportation (excluding taxicab):')
    str = str.replace(/Estimate; Total: - Bicycle/gi, 'Estimate; Bicycle')
    str = str.replace(/Estimate; Total: - Walked/gi, 'Estimate; Walked')
    str = str.replace(/Estimate; Total: - Worked at home/gi, 'Estimate; Worked at home')
    str = str.replace(/Estimate; Total: - Taxicab, motorcycle, or other means/gi, 'Estimate; Taxicab, motorcycle, or other means')

    # remove the first line
    rows = str.split("\r\n")
    str = rows[1..rows.length-1].join("\r\n")

    d3.csv.parse str, (d) ->
      year: "20#{yr_str}"
      id: +d.Id2
      geo: d.Geography
      total: +d['Estimate; Total:']
      car: +d['Estimate; Car, truck, or van:']
      public: +d['Estimate; Public transportation (excluding taxicab):']
      bike: +d['Estimate; Bicycle']
      walk: +d['Estimate; Walked']
      home: +d['Estimate; Worked at home']
      other: +d['Estimate; Taxicab, motorcycle, or other means']

  get_years = (commuting_data) ->
    commuting_data.map (d) -> d.year

  aggregate_data_by_geo = (commuting_data) ->
    data_by_geo = {}
    commuting_data.map (d) ->
      d.data.map (obj) ->
        unless data_by_geo.hasOwnProperty(obj.geo)
          data_by_geo[obj.geo] = []
        data_by_geo[obj.geo].push obj

    data = []
    for k,v of data_by_geo
      data.push
        geo: k
        data: v

    # remove counties that don't have data for all years
    num_years = commuting_data.length
    to_return = []
    for d in data
      if d.data.length is num_years
        to_return.push d
      else
        console.log "Ignoring #{d.geo} because it only has data for years: #{d.data.map (y) -> y.year}"
    to_return
