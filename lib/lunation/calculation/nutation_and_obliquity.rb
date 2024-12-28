module Lunation
  class Calculation
    module NutationAndObliquity
      # rubocop:disable Layout/LineLength
      NUTATION_IN_OBLIQUITY_PERIODIC_TERMS = YAML.load_file("config/periodic_terms_earth_nutation.yml").freeze
      ECLIPTIC_MEAN_OBLIQUITY_CONSTANTS = [21.448, -4680.93, -1.55, 1_999.25, -51.38, -249.67, -39.05, 7.12, 27.87, 5.79, 2.45].freeze
      MOON_MEAN_ELONGATION_FROM_SUN_CONSTANTS = [297.85036, 445_267.111480, -0.0019142, 1 / 189_474.0].freeze
      SUN_MEAN_ANOMALY_CONSTANTS = [357.52772, 35_999.050340, -0.0001603, -1 / 300_000.0].freeze
      MOON_MEAN_ANOMALY_CONSTANTS = [134.96298, 477_198.867398, 0.0086972, 1 / 56_250.0].freeze
      MOON_ARGUMENT_OF_LATITUDE_CONSTANTS = [93.27191, 483_202.017538, -0.0036825, 1 / 327_270.0].freeze
      LONGITUDE_OF_THE_ASCENDING_NODE_CONSTANTS = [125.04452, -1934.136261, 0.0020708, 1 / 450_000.0].freeze
      # rubocop:enable Layout/LineLength

      # (D) Mean elongation of the moon from the sun (A.A. p. 144)
      # UNIT: Angle
      def moon_mean_elongation_from_sun
        @moon_mean_elongation_from_sun ||= begin
          result = Horner.compute(time, MOON_MEAN_ELONGATION_FROM_SUN_CONSTANTS)
          Angle.from_decimal_degrees(result)
        end
      end

      # (M) Sun mean_anomaly (A.A. p. 144)
      # UNIT: Angle
      def sun_mean_anomaly
        @sun_mean_anomaly ||= begin
          result = Horner.compute(time, SUN_MEAN_ANOMALY_CONSTANTS)
          Angle.from_decimal_degrees(result)
        end
      end

      # (M') Moon mean_anomaly (A.A. p. 149)
      # UNIT: Angle
      def moon_mean_anomaly
        @moon_mean_anomaly ||= begin
          result = Horner.compute(time, MOON_MEAN_ANOMALY_CONSTANTS)
          Angle.from_decimal_degrees(result)
        end
      end

      # (F) Moon argument_of_latitude (A.A. p. 144)
      # UNIT: Angle
      def moon_argument_of_latitude
        @moon_argument_of_latitude ||= begin
          result = Horner.compute(time, MOON_ARGUMENT_OF_LATITUDE_CONSTANTS)
          Angle.from_decimal_degrees(result)
        end
      end

      # (Ω) Longitude of the ascending node of the Moon's mean orbit on the ecliptic,
      #   measured from the mean equinox of the date (A.A. p. 144)
      # UNIT: Angle
      def longitude_of_ascending_node
        @longitude_of_ascending_node ||= begin
          result = Horner.compute(time, LONGITUDE_OF_THE_ASCENDING_NODE_CONSTANTS)
          Angle.from_decimal_degrees(result)
        end
      end

      # (Δψ) nutation in longitude (A.A. p. 144)
      # UNIT: Angle
      def nutation_in_longitude
        @nutation_in_longitude ||= begin
          result = NUTATION_IN_OBLIQUITY_PERIODIC_TERMS.inject(0.0) do |acc, elem|
            argument = Angle.from_decimal_degrees(
              elem["moon_mean_elongation"] * moon_mean_elongation_from_sun.decimal_degrees +
              elem["sun_mean_anomaly"] * sun_mean_anomaly.decimal_degrees +
              elem["moon_mean_anomaly"] * moon_mean_anomaly.decimal_degrees +
              elem["moon_argument_of_latitude"] * moon_argument_of_latitude.decimal_degrees +
              elem["longitude_of_ascending_node"] * longitude_of_ascending_node.decimal_degrees
            )
            coefficient = elem["sine_coefficient_first_term"] + elem["sine_coefficient_second_term"] * time
            acc + coefficient * Math.sin(argument.radians)
          end / 10_000.0
          Angle.from_decimal_arcseconds(result)
        end
      end

      # (Δε) nutation in obliquity (A.A. p. 144)
      # UNIT: Angle
      def nutation_in_obliquity
        @nutation_in_obliquity ||= begin
          result = NUTATION_IN_OBLIQUITY_PERIODIC_TERMS.inject(0.0) do |acc, elem|
            argument = Angle.from_decimal_degrees(
              elem["moon_mean_elongation"] * moon_mean_elongation_from_sun.decimal_degrees +
              elem["sun_mean_anomaly"] * sun_mean_anomaly.decimal_degrees +
              elem["moon_mean_anomaly"] * moon_mean_anomaly.decimal_degrees +
              elem["moon_argument_of_latitude"] * moon_argument_of_latitude.decimal_degrees +
              elem["longitude_of_ascending_node"] * longitude_of_ascending_node.decimal_degrees
            )
            coefficient = elem["cosine_coefficient_first_term"] + elem["cosine_coefficient_second_term"] * time
            acc + coefficient * Math.cos(argument.radians)
          end / 10_000.0
          Angle.from_decimal_arcseconds(result)
        end
      end

      # (ε0) mean obliquity of the ecliptic (22.3, A.A. p. 147)
      # UNIT: Angle
      def mean_obliquity_of_ecliptic
        @mean_obliquity_of_ecliptic ||= begin
          decimal_arcseconds = Horner.compute(
            time_myriads,
            ECLIPTIC_MEAN_OBLIQUITY_CONSTANTS
          )
          Angle.from_degrees(
            degrees: 23.0,
            arcminutes: 26.0,
            decimal_arcseconds: decimal_arcseconds
          )
        end
      end

      # (ε) true obliquity of the ecliptic (A.A. p. 147)
      # UNIT: Angle
      def obliquity_of_ecliptic
        @obliquity_of_ecliptic ||= mean_obliquity_of_ecliptic + nutation_in_obliquity
      end
    end
  end
end
