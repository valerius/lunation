module Lunation
  class Calculation
    module NutationAndObliquity
      # (M) Sun mean_anomaly (A.A. p. 144)
      def calculate_sun_mean_anomaly2
        Angle.from_decimal_degrees(357.52772 + 35_999.050340 * time - 0.0001603 * time**2 - time**3 / 300_000.0)
      end

      # (M') Moon mean_anomaly (A.A. p. 149)
      def calculate_moon_mean_anomaly2
        result = 134.96298 + 477_198.867398 * time + 0.0086972 * time**2 + time**3 / 56_250.0
        Angle.from_decimal_degrees(result)
      end

      # (F) Moon argument_of_latitude (A.A. p. 144)
      def calculate_moon_argument_of_latitude2
        result = 93.27191 + 483_202.017538 * time - 0.0036825 * time**2 + time**3 / 327_270.0
        Angle.from_decimal_degrees(result)
      end

      # (Omega) Longitude of the ascending node of the Moon's mean orbit on the ecliptic,
      #   measured from the mean equinox of the date (A.A. p. 144)
      def calculate_moon_orbital_longitude_mean_ascending_node
        Angle.from_decimal_degrees(125.04452 - 1934.136261 * time + 0.0020708 * time**2 + time**3 / 450_000.0)
      end

      # (Delta Psi) nutation in longitude (A.A. p. 144)
      def calculate_earth_nutation_in_longitude(
        moon_mean_elongation: calculate_moon_mean_elongation,
        sun_mean_anomaly: calculate_sun_mean_anomaly2,
        moon_mean_anomaly: calculate_moon_mean_anomaly2,
        moon_argument_of_latitude: calculate_moon_argument_of_latitude2,
        moon_orbital_longitude_mean_ascending_node: calculate_moon_orbital_longitude_mean_ascending_node
      )
        result = PERIODIC_TERMS_EARTH_NUTATION.inject(0.0) do |acc, elem|
          argument = Angle.from_decimal_degrees(
            elem["moon_mean_elongation"] * moon_mean_elongation.decimal_degrees +
            elem["sun_mean_anomaly"] * sun_mean_anomaly.decimal_degrees +
            elem["moon_mean_anomaly"] * moon_mean_anomaly.decimal_degrees +
            elem["moon_argument_of_latitude"] * moon_argument_of_latitude.decimal_degrees +
            elem["moon_orbital_longitude_mean_ascending_node"] * moon_orbital_longitude_mean_ascending_node.decimal_degrees
          )
          coefficient = elem["sine_coefficient_first_term"] + elem["sine_coefficient_second_term"] * time
          acc + coefficient * Math.sin(argument.radians)
        end / 10_000.0
        Angle.from_decimal_arcseconds(result)
      end

      # (Delta epsilon) nutation in obliquity (A.A. p. 144)
      def calculate_nutation_in_obliquity(
        moon_mean_elongation: calculate_moon_mean_elongation,
        sun_mean_anomaly: calculate_sun_mean_anomaly2,
        moon_mean_anomaly: calculate_moon_mean_anomaly2,
        moon_argument_of_latitude: calculate_moon_argument_of_latitude2,
        moon_orbital_longitude_mean_ascending_node: calculate_moon_orbital_longitude_mean_ascending_node
      )
        result = PERIODIC_TERMS_EARTH_NUTATION.inject(0.0) do |acc, elem|
          argument = Angle.from_decimal_degrees(
            elem["moon_mean_elongation"] * moon_mean_elongation.decimal_degrees +
            elem["sun_mean_anomaly"] * sun_mean_anomaly.decimal_degrees +
            elem["moon_mean_anomaly"] * moon_mean_anomaly.decimal_degrees +
            elem["moon_argument_of_latitude"] * moon_argument_of_latitude.decimal_degrees +
            elem["moon_orbital_longitude_mean_ascending_node"] * moon_orbital_longitude_mean_ascending_node.decimal_degrees
          )
          coefficient = elem["cosine_coefficient_first_term"] + elem["cosine_coefficient_second_term"] * time
          acc + coefficient * Math.cos(argument.radians)
        end / 10_000.0
        Angle.from_decimal_arcseconds(result)
      end

      # (epsilon 0) mean obliquity of the ecliptic (22.3, A.A. p. 147)
      def calculate_ecliptic_mean_obliquity
        decimal_arcseconds = 21.448 +
                             -4680.93 * julian_myriads_since_j2000 +
                             -1.55 * julian_myriads_since_j2000**2 +
                             1_999.25 * julian_myriads_since_j2000**3 +
                             -51.38 * julian_myriads_since_j2000**4 +
                             -249.67 * julian_myriads_since_j2000**5 +
                             -39.05 * julian_myriads_since_j2000**6 +
                             7.12 * julian_myriads_since_j2000**7 +
                             27.87 * julian_myriads_since_j2000**8 +
                             5.79 * julian_myriads_since_j2000**9 +
                             2.45 * julian_myriads_since_j2000**10
        Angle.from_degrees(
          degrees: 23.0,
          arcminutes: 26.0,
          decimal_arcseconds: decimal_arcseconds
        )
      end

      # (ε) true obliquity of the ecliptic (A.A. p. 147)
      def calculate_ecliptic_true_obliquity(
        ecliptic_mean_obliquity: calculate_ecliptic_mean_obliquity,
        nutation_in_obliquity: calculate_nutation_in_obliquity
      )
        ecliptic_mean_obliquity + nutation_in_obliquity
      end
    end
  end
end
