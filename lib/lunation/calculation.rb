require "date"
require "yaml"
require_relative "calculation/earth_position_vsop87"
require_relative "calculation/moon_illuminated_fraction"
require_relative "calculation/nutation_and_obliquity"
require_relative "calculation/position_of_the_moon"
require_relative "calculation/position_of_the_sun"
require_relative "calculation/timekeeping"

module Lunation
  class Calculation
    include EarthPositionVSOP87
    include MoonIlluminatedFraction
    include NutationAndObliquity
    include PositionOfTheMoon
    include PositionOfTheSun
    include Timekeeping

    attr_reader :datetime

    def initialize(datetime)
      @datetime = datetime
      @decimal_year = datetime.year + (datetime.month - 0.5) / 12.0
    end

    def to_h
      @to_h ||= {
        corrected_ecliptic_true_obliquity: calculate_corrected_ecliptic_true_obliquity,
        correction_jupiter: calculate_correction_jupiter,
        correction_latitude: calculate_correction_latitude,
        correction_venus: calculate_correction_venus,
        delta_t: delta_t,
        dynamical_time: dynamical_time,
        earth_eccentricity_correction: calculate_earth_eccentricity_correction,
        earth_eccentricity: calculate_earth_eccentricity,
        earth_ecliptical_latitude_vsop87: calculate_earth_ecliptical_latitude_vsop87,
        earth_ecliptical_longitude_vsop87: calculate_earth_ecliptical_longitude_vsop87,
        earth_moon_distance: calculate_earth_moon_distance,
        earth_nutation_in_longitude: calculate_earth_nutation_in_longitude,
        earth_sun_distance_in_km: calculate_earth_sun_distance_in_km,
        earth_sun_distance: calculate_earth_sun_distance,
        ecliptic_mean_obliquity: calculate_ecliptic_mean_obliquity,
        ecliptic_true_obliquity: calculate_ecliptic_true_obliquity,
        equitorial_horizontal_parallax: calculate_equitorial_horizontal_parallax,
        julian_ephemeris_day: julian_ephemeris_day,
        julian_myriads_since_j2000: julian_myriads_since_j2000,
        moon_argument_of_latitude: calculate_moon_argument_of_latitude,
        moon_argument_of_latitude2: calculate_moon_argument_of_latitude2,
        moon_ecliptic_latitude: calculate_moon_ecliptic_latitude,
        moon_ecliptic_longitude: calculate_moon_ecliptic_longitude,
        moon_geocentric_declination: calculate_moon_geocentric_declination,
        moon_geocentric_elongation: calculate_moon_geocentric_elongation,
        moon_geocentric_longitude: calculate_moon_geocentric_longitude,
        moon_geocentric_right_ascension: calculate_moon_geocentric_right_ascension,
        moon_heliocentric_distance: calculate_moon_heliocentric_distance,
        moon_heliocentric_latitude: calculate_moon_heliocentric_latitude,
        moon_heliocentric_longitude: calculate_moon_heliocentric_longitude,
        moon_illuminated_fraction: calculate_moon_illuminated_fraction,
        moon_mean_anomaly: calculate_moon_mean_anomaly,
        moon_mean_anomaly2: calculate_moon_mean_anomaly2,
        moon_mean_elongation_from_the_sun: calculate_moon_mean_elongation_from_the_sun,
        moon_mean_elongation: calculate_moon_mean_elongation,
        moon_mean_longitude: calculate_moon_mean_longitude,
        moon_orbital_longitude_mean_ascending_node: calculate_moon_orbital_longitude_mean_ascending_node,
        moon_orbital_longitude_mean_ascending_node2: calculate_moon_orbital_longitude_mean_ascending_node2,
        moon_phase_angle: calculate_moon_phase_angle,
        nutation_in_obliquity: calculate_nutation_in_obliquity,
        radius_vector_vsop87: calculate_radius_vector_vsop87,
        sun_ecliptical_longitude: calculate_sun_ecliptical_longitude,
        sun_equation_center: calculate_sun_equation_center,
        sun_geocentric_declination: calculate_sun_geocentric_declination,
        sun_geocentric_mean_longitude: calculate_sun_geocentric_mean_longitude,
        sun_geocentric_right_ascension: calculate_sun_geocentric_right_ascension,
        sun_mean_anomaly: calculate_sun_mean_anomaly,
        sun_mean_anomaly2: calculate_sun_mean_anomaly2,
        sun_true_anomaly: calculate_sun_true_anomaly,
        sun_true_longitude: calculate_sun_true_longitude,
        time_julian_millennia: time_julian_millennia,
        time: time
      }
    end

    def to_s
      result = <<-HEREDOC
        DATE AND TIME (UT):                           #{@datetime}
        ----------------------------------------------------------------------------------
        DECIMAL YEAR:                                 #{@decimal_year}
        DELTA T:                                      #{to_h[:delta_t]}
        DYNAMICAL TIME:                               #{to_h[:dynamical_time]}
        JULIAN EPHEMERIS DAY:                         #{to_h[:julian_ephemeris_day]}
        JULIAN MYRIADS SINCE J2000:                   #{to_h[:julian_myriads_since_j2000]}
        TIME (JULIAN CENTURIES):                      #{to_h[:time]}
        TIME (JULIAN MILLENNIA):                      #{to_h[:time_julian_millennia]}

        **********************************************************************************
        NUTATION AND OBLIQUITY
        **********************************************************************************

        EARTH NUTATION IN LONGITUDE:                  #{to_h[:earth_nutation_in_longitude].decimal_degrees}
        ECLIPTIC MEAN OBLIQUITY:                      #{to_h[:ecliptic_mean_obliquity].decimal_degrees}
        ECLIPTIC TRUE OBLIQUITY:                      #{to_h[:ecliptic_true_obliquity].decimal_degrees}
        MOON ARGUMENT OF LATITUDE2:                   #{to_h[:moon_argument_of_latitude2].decimal_degrees}
        MOON MEAN ANOMALY2:                           #{to_h[:moon_mean_anomaly2].decimal_degrees}
        MOON MEAN ELONGATION FROM THE SUN:            #{to_h[:moon_mean_elongation_from_the_sun].decimal_degrees}
        MOON ORBITAL LONGITUDE MEAN ASCENDING NODE:   #{to_h[:moon_orbital_longitude_mean_ascending_node].decimal_degrees}
        NUTATION IN OBLIQUITY:                        #{to_h[:nutation_in_obliquity].decimal_degrees}
        SUN MEAN ANOMALY2:                            #{to_h[:sun_mean_anomaly2].decimal_degrees}

        **********************************************************************************
        POSITION OF THE SUN AND EARTH
        **********************************************************************************

        CORRECTED ECLIPTIC TRUE OBLIQUITY:            #{to_h[:corrected_ecliptic_true_obliquity].decimal_degrees}
        EARTH ECCENTRICITY:                           #{to_h[:earth_eccentricity]}
        EARTH-SUN DISTANCE (AU):                      #{to_h[:earth_sun_distance]}
        EARTH-SUN DISTANCE IN KM:                     #{to_h[:earth_sun_distance_in_km]}
        MOON ORBITAL LONGITUDE MEAN ASCENDING NODE2:  #{to_h[:moon_orbital_longitude_mean_ascending_node2].decimal_degrees}
        SUN ECLIPTICAL LONGITUDE:                     #{to_h[:sun_ecliptical_longitude].decimal_degrees}
        SUN EQUATION CENTER:                          #{to_h[:sun_equation_center].decimal_degrees}
        SUN GEOCENTRIC DECLINATION:                   #{to_h[:sun_geocentric_declination].decimal_degrees}
        SUN GEOCENTRIC MEAN LONGITUDE:                #{to_h[:sun_geocentric_mean_longitude].decimal_degrees}
        SUN GEOCENTRIC RIGHT ASCENSION:               #{to_h[:sun_geocentric_right_ascension].decimal_degrees}
        SUN MEAN ANOMALY:                             #{to_h[:sun_mean_anomaly].decimal_degrees}
        SUN TRUE ANOMALY:                             #{to_h[:sun_true_anomaly].decimal_degrees}
        SUN TRUE LONGITUDE:                           #{to_h[:sun_true_longitude].decimal_degrees}

        **********************************************************************************
        POSITION OF THE MOON
        **********************************************************************************

        CORRECTION JUPITER:                           #{to_h[:correction_jupiter].decimal_degrees}
        CORRECTION LATITUDE:                          #{to_h[:correction_latitude].decimal_degrees}
        CORRECTION VENUS:                             #{to_h[:correction_venus].decimal_degrees}
        EARTH ECCENTRICITY CORRECTION:                #{to_h[:earth_eccentricity_correction]}
        EARTH-MOON DISTANCE:                          #{to_h[:earth_moon_distance]}
        EQUITORIAL HORIZONTAL PARALLAX:               #{to_h[:equitorial_horizontal_parallax].decimal_degrees}
        MOON ARGUMENT OF LATITUDE:                    #{to_h[:moon_argument_of_latitude].decimal_degrees}
        MOON ECLIPTIC LATITUDE:                       #{to_h[:moon_ecliptic_latitude].decimal_degrees}
        MOON ECLIPTIC LONGITUDE:                      #{to_h[:moon_ecliptic_longitude].decimal_degrees}
        MOON GEOCENTRIC DECLINATION:                  #{to_h[:moon_geocentric_declination].decimal_degrees}
        MOON GEOCENTRIC LONGITUDE:                    #{to_h[:moon_geocentric_longitude].decimal_degrees}
        MOON GEOCENTRIC RIGHT ASCENSION:              #{to_h[:moon_geocentric_right_ascension].decimal_degrees}
        MOON HELIOCENTRIC DISTANCE:                   #{to_h[:moon_heliocentric_distance]}
        MOON HELIOCENTRIC LATITUDE:                   #{to_h[:moon_heliocentric_latitude]}
        MOON HELIOCENTRIC LONGITUDE:                  #{to_h[:moon_heliocentric_longitude]}
        MOON MEAN ANOMALY:                            #{to_h[:moon_mean_anomaly].decimal_degrees}
        MOON MEAN ELONGATION:                         #{to_h[:moon_mean_elongation].decimal_degrees}
        MOON MEAN LONGITUDE:                          #{to_h[:moon_mean_longitude].decimal_degrees}

        **********************************************************************************
        MOON ILLUMINATED FRACTION
        **********************************************************************************

        MOON GEOCENTRIC ELONGATION:                   #{to_h[:moon_geocentric_elongation].decimal_degrees}
        MOON ILLUMINATED FRACTION:                    #{to_h[:moon_illuminated_fraction]}
        MOON PHASE ANGLE:                             #{to_h[:moon_phase_angle].decimal_degrees}

        **********************************************************************************
        EARTH POSITION VSOP87
        **********************************************************************************

        EARTH ECLIPTICAL LATITUDE VSOP87:             #{to_h[:earth_ecliptical_latitude_vsop87].decimal_degrees}
        EARTH ECLIPTICAL LONGITUDE VSOP87:            #{to_h[:earth_ecliptical_longitude_vsop87].decimal_degrees}
        RADIUS VECTOR VSOP87:                         #{to_h[:radius_vector_vsop87]}
      HEREDOC

      puts(result)
    end
  end
end
