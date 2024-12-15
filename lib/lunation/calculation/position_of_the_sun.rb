require_relative "nutation_and_obliquity"

module Lunation
  class Calculation
    module PositionOfTheSun
      # (L0) Geocentric mean longitude of the sun (25.2, A.A. p. 163)
      def calculate_sun_geocentric_mean_longitude
        result = Horner.compute(time, [280.46646, 36_000.76983, 0.0003032])
        Angle.from_decimal_degrees(result)
      end

      # (M) Sun mean_anomaly (25.3, A.A. p. 163)
      def calculate_sun_mean_anomaly
        result = Horner.compute(time, [357.52911, 35_999.05029, -0.0001537])
        Angle.from_decimal_degrees(result)
      end

      # (e) eccentricity of the earth's orbit (25.4, A.A. p. 163)
      def calculate_earth_eccentricity
        Horner.compute(time, [0.016708634, -0.000042037, -0.0000001267]).round(9)
      end

      # (C) Sun's equation of the center (A.A. p. 164)
      def calculate_sun_equation_center(sun_mean_anomaly: calculate_sun_mean_anomaly)
        result = Horner.compute(time, [1.914602, -0.004817, -0.000014]) *
                 Math.sin(sun_mean_anomaly.radians) +
                 (0.019993 - 0.000101 * time) * Math.sin(2 * sun_mean_anomaly.radians) +
                 0.000289 * Math.sin(3 * sun_mean_anomaly.radians)
        Angle.from_decimal_degrees(result, normalize: false)
      end

      # (Symbol of the sun) true longitude of the sun (A.A. p. 164)
      def calculate_sun_true_longitude(
        sun_geocentric_mean_longitude: calculate_sun_geocentric_mean_longitude,
        sun_equation_center: calculate_sun_equation_center
      )
        sun_geocentric_mean_longitude + sun_equation_center
      end

      # (v) true anomaly of the sun (A.A. p. 164)
      def calculate_sun_true_anomaly(
        sun_mean_anomaly: calculate_sun_mean_anomaly,
        sun_equation_center: calculate_sun_equation_center
      )
        sun_mean_anomaly + sun_equation_center
      end

      # (R) earth_sun_distance (25.5, A.A. p. 164)
      def calculate_earth_sun_distance(
        earth_eccentricity: calculate_earth_eccentricity,
        sun_true_anomaly: calculate_sun_true_anomaly
      )
        result = 1.000001018 * (1 - earth_eccentricity**2) / (1 + earth_eccentricity * Math.cos(sun_true_anomaly.radians))
        result.round(7)
      end

      # (R) earth_sun_distance in km (25.5, A.A. p. 164)
      def calculate_earth_sun_distance_in_km(earth_sun_distance: calculate_earth_sun_distance)
        (earth_sun_distance * 149_597_870).floor
      end

      # (Omega) Longitude of the ascending node of the Moon's mean orbit on the ecliptic (low precision)
      #   A.A. p. 164
      def calculate_moon_orbital_longitude_mean_ascending_node2
        Angle.from_decimal_degrees(125.04 - 1934.136 * time)
      end

      # (apparent lambda0) Sun apparent longitude (A.A. p. 169)
      def calculate_sun_ecliptical_longitude(
        sun_true_longitude: calculate_sun_true_longitude,
        moon_orbital_longitude_mean_ascending_node2: calculate_moon_orbital_longitude_mean_ascending_node2
      )
        result = sun_true_longitude.decimal_degrees +
                 - 0.00569 +
                 - 0.00478 * Math.sin(moon_orbital_longitude_mean_ascending_node2.radians)
        Angle.from_decimal_degrees(result)
      end

      # (corrected ε) corrected true obliquity of the cliptic (A.A. p. 165)
      def calculate_corrected_ecliptic_true_obliquity(
        ecliptic_mean_obliquity: calculate_ecliptic_mean_obliquity,
        moon_orbital_longitude_mean_ascending_node: calculate_moon_orbital_longitude_mean_ascending_node
      )
        result = ecliptic_mean_obliquity.decimal_degrees +
                 0.00256 * Math.cos(moon_orbital_longitude_mean_ascending_node.radians)
        Angle.from_decimal_degrees(result)
      end

      # (α0) geocentric (apparent) right ascension of the sun (25.6 A.A. p. 165)
      def calculate_sun_geocentric_right_ascension(
        corrected_ecliptic_true_obliquity: calculate_corrected_ecliptic_true_obliquity,
        sun_ecliptical_longitude: calculate_sun_ecliptical_longitude
      )
        numerator = Math.cos(corrected_ecliptic_true_obliquity.radians) *
                    Math.sin(sun_ecliptical_longitude.radians)
        denominator = Math.cos(sun_ecliptical_longitude.radians)
        Angle.from_radians(Math.atan2(numerator, denominator))
      end

      # (delta0) geocentric declination (of the sun) (13.4) A.A. p. 93
      def calculate_sun_geocentric_declination(
        corrected_ecliptic_true_obliquity: calculate_corrected_ecliptic_true_obliquity,
        sun_ecliptical_longitude: calculate_sun_ecliptical_longitude
      )
        result = Math.sin(corrected_ecliptic_true_obliquity.radians) *
                 Math.sin(sun_ecliptical_longitude.radians)
        Angle.from_radians(Math.asin(result), normalize: false)
      end
    end
  end
end
