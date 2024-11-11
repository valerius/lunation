require "date"
require "yaml"
require_relative "calculation/nutation_and_obliquity"
require_relative "calculation/position_of_the_sun"
require_relative "calculation/position_of_the_moon"
require_relative "calculation/timekeeping"

module Lunation
  class Calculation
    include NutationAndObliquity
    include PositionOfTheSun
    include PositionOfTheMoon
    include Timekeeping

    PERIODIC_TERMS_EARTH_NUTATION = YAML.load_file("config/periodic_terms_earth_nutation.yml").freeze
    PERIODIC_TERMS_EARTH_POSITION_L0 = YAML.load_file("config/period_terms_earth_position_l0.yml").freeze
    PERIODIC_TERMS_EARTH_POSITION_L1 = YAML.load_file("config/period_terms_earth_position_l1.yml").freeze
    PERIODIC_TERMS_EARTH_POSITION_L2 = YAML.load_file("config/period_terms_earth_position_l2.yml").freeze
    PERIODIC_TERMS_EARTH_POSITION_L3 = YAML.load_file("config/period_terms_earth_position_l3.yml").freeze
    PERIODIC_TERMS_EARTH_POSITION_L4 = YAML.load_file("config/period_terms_earth_position_l4.yml").freeze
    PERIODIC_TERMS_EARTH_POSITION_L5 = YAML.load_file("config/period_terms_earth_position_l5.yml").freeze
    PERIODIC_TERMS_EARTH_POSITION_R0 = YAML.load_file("config/periodic_terms_earth_position_r0.yml").freeze
    PERIODIC_TERMS_EARTH_POSITION_R1 = YAML.load_file("config/periodic_terms_earth_position_r1.yml").freeze
    PERIODIC_TERMS_EARTH_POSITION_R2 = YAML.load_file("config/periodic_terms_earth_position_r2.yml").freeze
    PERIODIC_TERMS_EARTH_POSITION_R3 = YAML.load_file("config/periodic_terms_earth_position_r3.yml").freeze
    PERIODIC_TERMS_EARTH_POSITION_R4 = YAML.load_file("config/periodic_terms_earth_position_r4.yml").freeze
    PERIODIC_TERMS_EARTH_POSITION_B0 = YAML.load_file("config/periodic_terms_earth_position_b0.yml").freeze
    PERIODIC_TERMS_EARTH_POSITION_B1 = YAML.load_file("config/periodic_terms_earth_position_b1.yml").freeze

    attr_reader :datetime

    def initialize(datetime)
      @datetime = datetime
      @decimal_year = datetime.year + (datetime.month - 0.5) / 12.0
    end

    # (k) illuminated fraction of the moon (48.1, A.A. p. 345)
    def calculate_moon_illuminated_fraction(moon_phase_angle: calculate_moon_phase_angle)
      result = (1 + Math.cos(moon_phase_angle.radians)) / 2.0
      result.round(4)
    end

    # (i) phase angle of the moon (48.3, A.A. p. 346)
    def calculate_moon_phase_angle(
      earth_sun_distance_in_km: calculate_earth_sun_distance_in_km,
      moon_geocentric_elongation: calculate_moon_geocentric_elongation,
      earth_moon_distance: calculate_earth_moon_distance
    )
      numerator = earth_sun_distance_in_km * Math.sin(moon_geocentric_elongation.radians)
      denominator = earth_moon_distance - earth_sun_distance_in_km * Math.cos(moon_geocentric_elongation.radians)
      Angle.from_radians(Math.atan2(numerator, denominator))
    end

    # (R) earth_sun_distance in km (25.5, A.A. p. 164)
    def calculate_earth_sun_distance_in_km(earth_sun_distance: calculate_earth_sun_distance)
      (earth_sun_distance * 149_597_870).floor
    end

    # (psi) geocentric elongation of the moon (48.2, A.A. p. 345)
    def calculate_moon_geocentric_elongation(
      sun_geocentric_declination: calculate_sun_geocentric_declination,
      moon_geocentric_declination: calculate_moon_geocentric_declination,
      sun_geocentric_right_ascension: calculate_sun_geocentric_right_ascension,
      moon_geocentric_right_ascension: calculate_moon_geocentric_right_ascension
    )
      result = Math.sin(sun_geocentric_declination.radians) *
               Math.sin(moon_geocentric_declination.radians) +
               Math.cos(sun_geocentric_declination.radians) *
               Math.cos(moon_geocentric_declination.radians) *
               Math.cos((sun_geocentric_right_ascension - moon_geocentric_right_ascension).radians)
      Angle.from_radians(Math.acos(result))
    end

    # (apparent beta0) Sun apparent latitude (A.A. p. 169)
    def calculate_sun_ecliptical_latitude(
      earth_ecliptical_latitude: calculate_earth_ecliptical_latitude
    )
      Angle.from_decimal_degrees(-earth_ecliptical_latitude.decimal_degrees)
    end

    # Abberation of the earth (25.10, A.A. p. 167)
    def calculate_earth_abberation(earth_sun_distance: calculate_earth_sun_distance)
      Angle.from_decimal_arcseconds(-(20.4898 / earth_sun_distance), normalize: false)
    end

    # (L) ecliptic longitude of the earth (32.2) A.A. p. 218
    def calculate_earth_ecliptical_longitude
      term0 = PERIODIC_TERMS_EARTH_POSITION_L0.inject(0.0) do |acc, elem|
        acc + elem[0] * Math.cos(elem[1] + elem[2] * time_julian_millennia)
      end

      term1 = PERIODIC_TERMS_EARTH_POSITION_L1.inject(0.0) do |acc, elem|
        acc + elem[0] * Math.cos(elem[1] + elem[2] * time_julian_millennia)
      end

      term2 = PERIODIC_TERMS_EARTH_POSITION_L2.inject(0.0) do |acc, elem|
        acc + elem[0] * Math.cos(elem[1] + elem[2] * time_julian_millennia)
      end

      term3 = PERIODIC_TERMS_EARTH_POSITION_L3.inject(0.0) do |acc, elem|
        acc + elem[0] * Math.cos(elem[1] + elem[2] * time_julian_millennia)
      end

      term4 = PERIODIC_TERMS_EARTH_POSITION_L4.inject(0.0) do |acc, elem|
        acc + elem[0] * Math.cos(elem[1] + elem[2] * time_julian_millennia)
      end

      term5 = PERIODIC_TERMS_EARTH_POSITION_L5.inject(0.0) do |acc, elem|
        acc + elem[0] * Math.cos(elem[1] + elem[2] * time_julian_millennia)
      end

      result = term0 +
               term1 * time_julian_millennia +
               term2 * time_julian_millennia**2 +
               term3 * time_julian_millennia**3 +
               term4 * time_julian_millennia**4 +
               term5 * time_julian_millennia**5
      Angle.from_radians(result / 100_000_000.0)
    end

    # (R) Radius vector of the earth (distance to sun) A.A. p. 219
    # def earth_radius_vector
    #   term0 = PERIODIC_TERMS_EARTH_POSITION_R0.inject(0.0) do |acc, elem|
    #     acc + elem[0] * Math.cos(elem[1] + elem[2] * time_julian_millennia)
    #   end

    #   term1 = PERIODIC_TERMS_EARTH_POSITION_R1.inject(0.0) do |acc, elem|
    #     acc + elem[0] * Math.cos(elem[1] + elem[2] * time_julian_millennia)
    #   end

    #   term2 = PERIODIC_TERMS_EARTH_POSITION_R2.inject(0.0) do |acc, elem|
    #     acc + elem[0] * Math.cos(elem[1] + elem[2] * time_julian_millennia)
    #   end

    #   term3 = PERIODIC_TERMS_EARTH_POSITION_R3.inject(0.0) do |acc, elem|
    #     acc + elem[0] * Math.cos(elem[1] + elem[2] * time_julian_millennia)
    #   end

    #   term4 = PERIODIC_TERMS_EARTH_POSITION_R4.inject(0.0) do |acc, elem|
    #     acc + elem[0] * Math.cos(elem[1] + elem[2] * time_julian_millennia)
    #   end

    #   result = term0 +
    #            term1 * time_julian_millennia +
    #            term2 * time_julian_millennia**2 +
    #            term3 * time_julian_millennia**3 +
    #            term4 * time_julian_millennia**4
    #   result / 100_000_000.0
    # end

    # (B) ecliptic latitude of the earth A.A. p. 219
    def calculate_earth_ecliptical_latitude
      term0 = PERIODIC_TERMS_EARTH_POSITION_B0.inject(0.0) do |acc, elem|
        acc + elem[0] * Math.cos(elem[1] + elem[2] * time_julian_millennia)
      end

      term1 = PERIODIC_TERMS_EARTH_POSITION_B1.inject(0.0) do |acc, elem|
        acc + elem[0] * Math.cos(elem[1] + elem[2] * time_julian_millennia)
      end

      Angle.from_radians((term0 + term1 * time_julian_millennia) / 100_000_000.0,
                         normalize: false)
    end
  end
end
