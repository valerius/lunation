require_relative "nutation_and_obliquity"

module Lunation
  class Calculation
    module SunPosition
      # (L0) Geometric mean longitude of the sun (25.2, A.A. p. 163)
      # UNIT: Angle
      def sun_mean_longitude
        @sun_mean_longitude ||= begin
          result = Horner.compute(time, [280.46646, 36_000.76983, 0.0003032])
          Angle.from_decimal_degrees(result)
        end
      end

      # (M) Sun mean_anomaly (25.3, A.A. p. 163)
      # There is another, similar definition of the mean anomaly of the sun in
      # (A.A. p. 144). This method seems to be slightly less precise.
      # UNIT: Angle
      def sun_mean_anomaly2
        @sun_mean_anomaly2 ||= begin
          result = Horner.compute(time, [357.52911, 35_999.05029, -0.0001537])
          Angle.from_decimal_degrees(result)
        end
      end

      # (e) eccentricity of the earth's orbit (25.4, A.A. p. 163)
      # UNIT: Astronomical Units (AU)
      def earth_orbit_eccentricity
        @earth_orbit_eccentricity ||=
          Horner.compute(time, [0.016708634, -0.000042037, -0.0000001267]).round(9)
      end

      # (C) Sun's equation of the center (A.A. p. 164)
      # UNIT: Angle
      def sun_equation_of_center
        @sun_equation_of_center ||= begin
          result = Horner.compute(time, [1.914602, -0.004817, -0.000014]) *
            sun_mean_anomaly2.sin +
            (0.019993 - 0.000101 * time) * Math.sin(2 * sun_mean_anomaly2.radians) +
            0.000289 * Math.sin(3 * sun_mean_anomaly2.radians)
          Angle.from_decimal_degrees(result, normalize: false)
        end
      end

      # (☉) true longitude of the sun (A.A. p. 164)
      # UNIT: Angle
      def sun_true_longitude
        @sun_true_longitude ||= sun_mean_longitude + sun_equation_of_center
      end

      # (v) true anomaly of the sun (A.A. p. 164)
      # UNIT: Angle
      def sun_anomaly
        @sun_anomaly ||= sun_mean_anomaly2 + sun_equation_of_center
      end

      # (R) earth_sun_distance (25.5, A.A. p. 164)
      # UNIT: Astronomical Units (AU)
      def distance_between_earth_and_sun_in_astronomical_units
        @distance_between_earth_and_sun_in_astronomical_units ||= begin
          result = 1.000001018 * (1 - earth_orbit_eccentricity**2) / (1 + earth_orbit_eccentricity * sun_anomaly.cos)
          result.round(7)
        end
      end

      # (R) earth_sun_distance (25.5, A.A. p. 164)
      # UNIT: Kilometers (km)
      def distance_between_earth_and_sun_in_kilometers
        @distance_between_earth_and_sun_in_kilometers ||=
          (distance_between_earth_and_sun_in_astronomical_units * 149_597_870).floor
      end

      # (Ω) Longitude of the ascending node of the Moon's mean orbit on the ecliptic (low precision)
      #   A.A. p. 164
      # UNIT: Angle
      def longitude_of_ascending_node_low_precision
        @longitude_of_ascending_node_low_precision ||=
          Angle.from_decimal_degrees(125.04 - 1934.136 * time)
      end

      # (apparent λ0) Sun apparent longitude (A.A. p. 169)
      # UNIT: Angle
      def sun_ecliptic_longitude
        @sun_ecliptic_longitude ||= begin
          result = sun_true_longitude.decimal_degrees +
            - 0.00569 +
            - 0.00478 * longitude_of_ascending_node_low_precision.sin
          Angle.from_decimal_degrees(result)
        end
      end

      # (corrected ε) corrected true obliquity of the ecliptic (A.A. p. 165)
      # UNIT: Angle
      def corrected_obliquity_of_ecliptic
        @corrected_obliquity_of_ecliptic ||= begin
          result = mean_obliquity_of_ecliptic.decimal_degrees +
            0.00256 * longitude_of_ascending_node.cos
          Angle.from_decimal_degrees(result)
        end
      end

      # (α0) geocentric (apparent) right ascension of the sun (25.6 A.A. p. 165)
      # UNIT: Angle
      def sun_right_ascension
        @sun_right_ascension ||= begin
          numerator = corrected_obliquity_of_ecliptic.cos *
            sun_ecliptic_longitude.sin
          denominator = sun_ecliptic_longitude.cos
          Angle.from_radians(Math.atan2(numerator, denominator))
        end
      end

      # (δ0) geocentric declination (of the sun) (13.4) A.A. p. 93
      # UNIT: Angle
      def sun_declination
        @sun_declination ||= begin
          result = corrected_obliquity_of_ecliptic.sin *
            sun_ecliptic_longitude.sin
          Angle.from_radians(Math.asin(result), normalize: false)
        end
      end
    end
  end
end
