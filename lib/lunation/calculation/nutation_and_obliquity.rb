module Lunation
  class Calculation
    module NutationAndObliquity
      # rubocop:disable Layout/LineLength
      PERIODIC_TERMS_EARTH_NUTATION = YAML.load_file("config/periodic_terms_earth_nutation.yml").freeze
      CALCULATE_ECLIPTIC_MEAN_OBLIQUITY_CONSTANTS = [21.448, -4680.93, -1.55, 1_999.25, -51.38, -249.67, -39.05, 7.12, 27.87, 5.79, 2.45].freeze
      CALCULATE_MOON_MEAN_ELONGATION_FROM_THE_SUN_CONSTANTS = [297.85036, 445_267.111480, -0.0019142, 1 / 189_474.0].freeze
      CALCULATE_SUN_MEAN_ANOMALY2_CONSTANTS = [357.52772, 35_999.050340, -0.0001603, -1 / 300_000.0].freeze
      CALCULATE_MOON_MEAN_ANOMALY2_CONSTANTS = [134.96298, 477_198.867398, 0.0086972, 1 / 56_250.0].freeze
      CALCULATE_MOON_ARGUMENT_OF_LATITUDE2_CONSTANTS = [93.27191, 483_202.017538, -0.0036825, 1 / 327_270.0].freeze
      CALCULATE_MOON_ORBITAL_LONGITUDE_MEAN_ASCENDING_NODE_CONSTANTS = [125.04452, -1934.136261, 0.0020708, 1 / 450_000.0].freeze
      # rubocop:enable Layout/LineLength

      # (D) Mean elongation of the moon from the sun (A.A. p. 144)
      def calculate_moon_mean_elongation_from_the_sun
        result = Horner.compute(
          time,
          CALCULATE_MOON_MEAN_ELONGATION_FROM_THE_SUN_CONSTANTS
        )
        Angle.from_decimal_degrees(result)
      end

      # (M) Sun mean_anomaly (A.A. p. 144)
      def calculate_sun_mean_anomaly2
        result = Horner.compute(time, CALCULATE_SUN_MEAN_ANOMALY2_CONSTANTS)
        Angle.from_decimal_degrees(result)
      end

      # (M') Moon mean_anomaly (A.A. p. 149)
      def calculate_moon_mean_anomaly2
        result = Horner.compute(time, CALCULATE_MOON_MEAN_ANOMALY2_CONSTANTS)
        Angle.from_decimal_degrees(result)
      end

      # (F) Moon argument_of_latitude (A.A. p. 144)
      def calculate_moon_argument_of_latitude2
        result = Horner.compute(time, CALCULATE_MOON_ARGUMENT_OF_LATITUDE2_CONSTANTS)
        Angle.from_decimal_degrees(result)
      end

      # (Omega) Longitude of the ascending node of the Moon's mean orbit on the ecliptic,
      #   measured from the mean equinox of the date (A.A. p. 144)
      def calculate_moon_orbital_longitude_mean_ascending_node
        result = Horner.compute(
          time,
          CALCULATE_MOON_ORBITAL_LONGITUDE_MEAN_ASCENDING_NODE_CONSTANTS
        )
        Angle.from_decimal_degrees(result)
      end

      # (Delta Psi) nutation in longitude (A.A. p. 144)
      def calculate_earth_nutation_in_longitude(
        moon_mean_elongation: calculate_moon_mean_elongation_from_the_sun,
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
        moon_mean_elongation: calculate_moon_mean_elongation_from_the_sun,
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
        decimal_arcseconds = Horner.compute(
          time_myriads,
          CALCULATE_ECLIPTIC_MEAN_OBLIQUITY_CONSTANTS
        )
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
