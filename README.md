# US Commuting

View the demo at <.......>

## Data

Files in the `data` folder were downloaded from <http://factfinder2.census.gov/faces/nav/jsf/pages/searchresults.xhtml> filtered by county.

The `commuting_data.js` file loaded by the browser can be generated from the raw data by

        $ grunt create_data_files

## Set up for development

### Prerequisites

[Node and npm](http://nodejs.org/), and [grunt-cli](http://gruntjs.com/getting-started) should be installed on your development system.

### Commands

- To install the project dependencies after downloading the source files

        $ npm install

- To run the development environment

  1. In a terminal window

          $ grunt build_watch

      This triggers the build process when source files change.

  2. In another terminal window

          $ grunt preview

      This serves the site on <http://localhost:8000>

## Questions?

Feel free to contact me at `mike@stubna.com`
