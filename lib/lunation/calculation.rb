require "date"
require "yaml"
require_relative "calculation/nutation_and_obliquity"
require_relative "calculation/position_of_the_sun"
require_relative "calculation/position_of_the_moon"
require_relative "calculation/timekeeping"
require_relative "calculation/moon_illuminated_fraction"
require_relative "calculation/earth_position_vsop87"

module Lunation
  class Calculation
    include NutationAndObliquity
    include PositionOfTheSun
    include PositionOfTheMoon
    include Timekeeping
    include MoonIlluminatedFraction
    include EarthPositionVSOP87

    PERIODIC_TERMS_EARTH_NUTATION = YAML.load_file("config/periodic_terms_earth_nutation.yml").freeze

    attr_reader :datetime

    def initialize(datetime)
      @datetime = datetime
      @decimal_year = datetime.year + (datetime.month - 0.5) / 12.0
    end
  end
end
