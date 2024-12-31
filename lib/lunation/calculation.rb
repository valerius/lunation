require "date"
require "yaml"
require_relative "calculation/earth_position_vsop87"
require_relative "calculation/moon_illuminated_fraction"
require_relative "calculation/nutation_and_obliquity"
require_relative "calculation/moon_position"
require_relative "calculation/sun_position"
require_relative "calculation/timekeeping"

module Lunation
  class Calculation
    include EarthPositionVSOP87
    include MoonIlluminatedFraction
    include NutationAndObliquity
    include MoonPosition
    include SunPosition
    include Timekeeping

    attr_reader :datetime, :decimal_year

    def initialize(datetime = DateTime.now)
      @datetime = datetime
      @decimal_year = datetime.year + (datetime.month - 0.5) / 12.0
    end

    def to_h
      {
        # rubocop:disable Layout/LineLength
        corrected_obliquity_of_ecliptic: corrected_obliquity_of_ecliptic,
        correction_eccentricity_of_earth: correction_eccentricity_of_earth,
        correction_jupiter: correction_jupiter,
        correction_latitude: correction_latitude,
        correction_venus: correction_venus,
        datetime: datetime,
        decimal_year: decimal_year,
        delta_t: delta_t,
        distance_between_earth_and_moon: distance_between_earth_and_moon,
        distance_between_earth_and_sun_in_astronomical_units: distance_between_earth_and_sun_in_astronomical_units,
        distance_between_earth_and_sun_in_kilometers: distance_between_earth_and_sun_in_kilometers,
        dynamical_time: dynamical_time,
        earth_orbit_eccentricity: earth_orbit_eccentricity,
        ecliptic_latitude_of_earth_using_vsop87: ecliptic_latitude_of_earth_using_vsop87,
        ecliptic_longitude_of_earth_using_vsop87: ecliptic_longitude_of_earth_using_vsop87,
        equatorial_horizontal_parallax: equatorial_horizontal_parallax,
        julian_ephemeris_day: julian_ephemeris_day,
        longitude_of_ascending_node_low_precision: longitude_of_ascending_node_low_precision,
        longitude_of_ascending_node: longitude_of_ascending_node,
        mean_obliquity_of_ecliptic: mean_obliquity_of_ecliptic,
        moon_apparent_ecliptic_longitude: moon_apparent_ecliptic_longitude,
        moon_argument_of_latitude_high_precision: moon_argument_of_latitude_high_precision,
        moon_argument_of_latitude: moon_argument_of_latitude,
        moon_declination: moon_declination,
        moon_ecliptic_latitude: moon_ecliptic_latitude,
        moon_ecliptic_longitude: moon_ecliptic_longitude,
        moon_elongation_from_sun: moon_elongation_from_sun,
        moon_heliocentric_distance: moon_heliocentric_distance,
        moon_heliocentric_latitude: moon_heliocentric_latitude,
        moon_heliocentric_longitude: moon_heliocentric_longitude,
        moon_illuminated_fraction: moon_illuminated_fraction,
        moon_mean_anomaly_high_precision: moon_mean_anomaly_high_precision,
        moon_mean_anomaly: moon_mean_anomaly,
        moon_mean_elongation_from_sun: moon_mean_elongation_from_sun,
        moon_mean_elongation_from_sun_high_precision: moon_mean_elongation_from_sun_high_precision,
        moon_mean_longitude: moon_mean_longitude,
        moon_phase_angle: moon_phase_angle,
        moon_position_angle_of_bright_limb: moon_position_angle_of_bright_limb,
        moon_right_ascension: moon_right_ascension,
        nutation_in_longitude: nutation_in_longitude,
        nutation_in_obliquity: nutation_in_obliquity,
        obliquity_of_ecliptic: obliquity_of_ecliptic,
        radius_vector_of_earth_using_vsop87: radius_vector_of_earth_using_vsop87,
        sun_anomaly: sun_anomaly,
        sun_declination: sun_declination,
        sun_ecliptic_longitude: sun_ecliptic_longitude,
        sun_equation_of_center: sun_equation_of_center,
        sun_mean_anomaly: sun_mean_anomaly,
        sun_mean_anomaly2: sun_mean_anomaly2,
        sun_mean_longitude: sun_mean_longitude,
        sun_right_ascension: sun_right_ascension,
        sun_true_longitude: sun_true_longitude,
        time_millennia: time_millennia,
        time_myriads: time_myriads,
        time: time,
        # rubocop:enable Layout/LineLength
      }
    end

    def to_s
      <<~HEREDOC
        DATE AND TIME (UT):                           #{datetime}
        ----------------------------------------------------------------------------------
        DECIMAL YEAR:                                 #{decimal_year}
        DELTA T:                                      #{delta_t}
        DYNAMICAL TIME:                               #{dynamical_time}
        JULIAN EPHEMERIS DAY:                         #{julian_ephemeris_day}
        JULIAN MYRIADS (10K YEARS) SINCE J2000:       #{time_myriads}
        TIME (JULIAN CENTURIES):                      #{time}
        TIME (JULIAN MILLENNIA):                      #{time_millennia}

        **********************************************************************************
        NUTATION AND OBLIQUITY
        **********************************************************************************

        EARTH NUTATION IN LONGITUDE:                  #{nutation_in_longitude.decimal_degrees}°
        ECLIPTIC MEAN OBLIQUITY:                      #{mean_obliquity_of_ecliptic.decimal_degrees}°
        ECLIPTIC TRUE OBLIQUITY:                      #{obliquity_of_ecliptic.decimal_degrees}°
        MOON ARGUMENT OF LATITUDE:                    #{moon_argument_of_latitude.decimal_degrees}°
        MOON MEAN ANOMALY:                            #{moon_mean_anomaly.decimal_degrees}°
        MOON MEAN ELONGATION FROM THE SUN:            #{moon_mean_elongation_from_sun.decimal_degrees}°
        LONGITUDE OF ASCENDING NODE:                  #{longitude_of_ascending_node.decimal_degrees}°
        NUTATION IN OBLIQUITY:                        #{nutation_in_obliquity.decimal_degrees}°
        SUN MEAN ANOMALY:                             #{sun_mean_anomaly.decimal_degrees}°

        **********************************************************************************
        POSITION OF THE SUN AND EARTH
        **********************************************************************************

        CORRECTED OBLIQUITY OF THE ECLIPTIC:          #{corrected_obliquity_of_ecliptic.decimal_degrees}°
        ECCENTRICITY OF THE EARTH'S ORBIT:            #{earth_orbit_eccentricity}
        EARTH-SUN DISTANCE (AU):                      #{distance_between_earth_and_sun_in_astronomical_units}
        EARTH-SUN DISTANCE (KM):                      #{distance_between_earth_and_sun_in_kilometers}
        LONGITUDE OF ASCENDING NODE (LOW PRECISION):  #{longitude_of_ascending_node.decimal_degrees}°
        SUN ECLIPTICAL LONGITUDE:                     #{sun_ecliptic_longitude.decimal_degrees}°
        SUN EQUATION CENTER:                          #{sun_equation_of_center.decimal_degrees}°
        SUN GEOCENTRIC DECLINATION:                   #{sun_declination.decimal_degrees}°
        SUN GEOCENTRIC MEAN LONGITUDE:                #{sun_mean_longitude.decimal_degrees}°
        SUN GEOCENTRIC RIGHT ASCENSION:               #{sun_right_ascension.decimal_degrees}°
        SUN MEAN ANOMALY2:                            #{sun_mean_anomaly2.decimal_degrees}°
        SUN TRUE ANOMALY:                             #{sun_anomaly.decimal_degrees}°
        SUN TRUE LONGITUDE:                           #{sun_true_longitude.decimal_degrees}°

        **********************************************************************************
        POSITION OF THE MOON
        **********************************************************************************

        CORRECTION JUPITER:                           #{correction_jupiter.decimal_degrees}°
        CORRECTION LATITUDE:                          #{correction_latitude.decimal_degrees}°
        CORRECTION VENUS:                             #{correction_venus.decimal_degrees}°
        CORRECTION EARTH ECCENTRICITY:                #{correction_eccentricity_of_earth}
        EARTH-MOON DISTANCE (KM):                     #{distance_between_earth_and_moon}
        EQUITORIAL HORIZONTAL PARALLAX:               #{equatorial_horizontal_parallax.decimal_degrees}°
        MOON ARGUMENT OF LATITUDE:                    #{moon_argument_of_latitude_high_precision.decimal_degrees}°
        MOON ECLIPTIC LATITUDE:                       #{moon_ecliptic_latitude.decimal_degrees}°
        MOON ECLIPTIC LONGITUDE:                      #{moon_apparent_ecliptic_longitude.decimal_degrees}°
        MOON GEOCENTRIC DECLINATION:                  #{moon_declination.decimal_degrees}°
        MOON GEOCENTRIC LONGITUDE:                    #{moon_ecliptic_longitude.decimal_degrees}°
        MOON GEOCENTRIC RIGHT ASCENSION:              #{moon_right_ascension.decimal_degrees}°
        MOON HELIOCENTRIC DISTANCE:                   #{moon_heliocentric_distance}
        MOON HELIOCENTRIC LATITUDE:                   #{moon_heliocentric_latitude}
        MOON HELIOCENTRIC LONGITUDE:                  #{moon_heliocentric_longitude}
        MOON MEAN ANOMALY:                            #{moon_mean_anomaly_high_precision.decimal_degrees}°
        MOON MEAN ELONGATION:                         #{moon_mean_elongation_from_sun_high_precision.decimal_degrees}°
        MOON MEAN LONGITUDE:                          #{moon_mean_longitude.decimal_degrees}°

        **********************************************************************************
        MOON ILLUMINATED FRACTION
        **********************************************************************************

        MOON ELONGATION FROM SUN:                     #{moon_elongation_from_sun.decimal_degrees}°
        MOON ILLUMINATED FRACTION:                    #{moon_illuminated_fraction}
        MOON PHASE ANGLE:                             #{moon_phase_angle.decimal_degrees}°
        MOON POSITION ANGLE OF BRIGHT LIMB            #{moon_position_angle_of_bright_limb.decimal_degrees}°

        **********************************************************************************
        EARTH POSITION VSOP87
        **********************************************************************************

        EARTH ECLIPTICAL LATITUDE VSOP87:             #{ecliptic_latitude_of_earth_using_vsop87.decimal_degrees}°
        EARTH ECLIPTICAL LONGITUDE VSOP87:            #{ecliptic_longitude_of_earth_using_vsop87.decimal_degrees}°
        EARTH RADIUS VECTOR VSOP87:                   #{radius_vector_of_earth_using_vsop87}
      HEREDOC
    end
  end
end
