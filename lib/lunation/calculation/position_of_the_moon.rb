require_relative "nutation_and_obliquity"

module Lunation
  class Calculation
    module PositionOfTheMoon
      # rubocop:disable Layout/LineLength
      PERIODIC_TERMS_MOON_LONGITUDE_DISTANCE = YAML.load_file("config/periodic_terms_moon_longitude_distance.yml").freeze
      PERIODIC_TERMS_MOON_LATITUDE = YAML.load_file("config/periodic_terms_moon_latitude.yml").freeze
      CALCULATE_MOON_MEAN_LONGITUDE_CONSTANTS = [218.3164477, 481_267.88123421, -0.0015786, 1 / 538_841.0, -1 / 65_194_000.0].freeze
      CALCULATE_MOON_MEAN_ELONGATION_CONSTANTS = [297.8501921, 445_267.1114034, -0.0018819, 1 / 545_868.0, -1 / 113_065_000.0].freeze
      CALCULATE_MOON_MEAN_ANOMALY_CONSTANTS = [134.9633964, 477_198.8675055, 0.0087414, 1 / 69_699.0, -1 / 14_712_000.0].freeze
      CALCULATE_MOON_ARGUMENT_OF_LATITUDE_CONSTANTS = [93.2720950, 483_202.0175233, -0.0036539, -1 / 3_526_000.0, 1 / 863_310_000.0].freeze
      CALCULATE_EARTH_ECCENTRICITY_CORRECTION_CONSTANTS = [1, -0.002516, -0.0000074].freeze
      # rubocop:enable Layout/LineLength

      # (L') Moon mean_longitude (47.1, A.A. p. 338)
      def calculate_moon_mean_longitude
        result = Horner.compute(time, CALCULATE_MOON_MEAN_LONGITUDE_CONSTANTS)
        Angle.from_decimal_degrees(result)
      end

      # (D) Moon mean_elongation (47.2, A.A. p. 338)
      def calculate_moon_mean_elongation
        result = Horner.compute(time, CALCULATE_MOON_MEAN_ELONGATION_CONSTANTS)
        Angle.from_decimal_degrees(result)
      end

      # (M') Moon mean_anomaly (47.4, A.A. p. 338)
      def calculate_moon_mean_anomaly
        result = Horner.compute(time, CALCULATE_MOON_MEAN_ANOMALY_CONSTANTS)
        Angle.from_decimal_degrees(result)
      end

      # (F) Moon argument_of_latitude (47.5, A.A. p. 338)
      def calculate_moon_argument_of_latitude
        result = Horner.compute(time, CALCULATE_MOON_ARGUMENT_OF_LATITUDE_CONSTANTS)
        Angle.from_decimal_degrees(result)
      end

      # (A1) Venus correction (A.A. p. 338)
      def calculate_correction_venus
        Angle.from_decimal_degrees(119.75 + 131.849 * time)
      end

      # (A2) Jupiter correction (A.A. p. 338)
      def calculate_correction_jupiter
        Angle.from_decimal_degrees(53.09 + 4_792_64.29 * time)
      end

      # (A3) latitude correction (A.A. p. 338)
      def calculate_correction_latitude
        Angle.from_decimal_degrees(313.45 + 481_266.484 * time)
      end

      # (E) Earth eccentricity (47.6 A.A. p. 338)
      def calculate_earth_eccentricity_correction
        Horner.compute(time, CALCULATE_EARTH_ECCENTRICITY_CORRECTION_CONSTANTS).round(6)
      end

      # (Sigma l) Moon longitude (A.A. p. 338)
      def calculate_moon_heliocentric_longitude(
        moon_mean_elongation: calculate_moon_mean_elongation,
        sun_mean_anomaly: calculate_sun_mean_anomaly,
        moon_mean_anomaly: calculate_moon_mean_anomaly,
        moon_argument_of_latitude: calculate_moon_argument_of_latitude,
        earth_eccentricity_correction: calculate_earth_eccentricity_correction,
        correction_venus: calculate_correction_venus,
        moon_mean_longitude: calculate_moon_mean_longitude,
        correction_jupiter: calculate_correction_jupiter
      )
        result = PERIODIC_TERMS_MOON_LONGITUDE_DISTANCE.inject(0.0) do |acc, elem|
          sine_argument = Angle.from_decimal_degrees(
            elem["moon_mean_elongation"] * moon_mean_elongation.decimal_degrees +
            elem["sun_mean_anomaly"] * sun_mean_anomaly.decimal_degrees +
            elem["moon_mean_anomaly"] * moon_mean_anomaly.decimal_degrees +
            elem["moon_argument_of_latitude"] * moon_argument_of_latitude.decimal_degrees
          )

          if elem["sine_coefficient"].nil?
            next acc
          elsif [1, -1].include?(elem["sun_mean_anomaly"])
            acc + elem["sine_coefficient"] * earth_eccentricity_correction * Math.sin(sine_argument.radians)
          elsif [-2, 2].include?(elem["sun_mean_anomaly"])
            acc + elem["sine_coefficient"] * earth_eccentricity_correction**2 * Math.sin(sine_argument.radians)
          else
            acc + elem["sine_coefficient"] * Math.sin(sine_argument.radians)
          end
        end + 3958 * Math.sin(correction_venus.radians) +
                 1962 * Math.sin((moon_mean_longitude - moon_argument_of_latitude).radians) +
                 318 * Math.sin(correction_jupiter.radians)
        result.round
      end

      # (Sigma b) Moon latitude (A.A. p. 338)
      def calculate_moon_heliocentric_latitude(
        moon_mean_elongation: calculate_moon_mean_elongation,
        sun_mean_anomaly: calculate_sun_mean_anomaly,
        moon_mean_anomaly: calculate_moon_mean_anomaly,
        moon_argument_of_latitude: calculate_moon_argument_of_latitude,
        earth_eccentricity_correction: calculate_earth_eccentricity_correction,
        moon_mean_longitude: calculate_moon_mean_longitude,
        correction_latitude: calculate_correction_latitude,
        correction_venus: calculate_correction_venus
      )
        result = PERIODIC_TERMS_MOON_LATITUDE.inject(0.0) do |acc, elem|
          sine_argument = Angle.from_decimal_degrees(
            elem["moon_mean_elongation"] * moon_mean_elongation.decimal_degrees +
            elem["sun_mean_anomaly"] * sun_mean_anomaly.decimal_degrees +
            elem["moon_mean_anomaly"] * moon_mean_anomaly.decimal_degrees +
            elem["moon_argument_of_latitude"] * moon_argument_of_latitude.decimal_degrees
          )

          if elem["sine_coefficient"].nil?
            next acc
          elsif [1, -1].include?(elem["sun_mean_anomaly"])
            acc + elem["sine_coefficient"] * earth_eccentricity_correction * Math.sin(sine_argument.radians)
          elsif [-2, 2].include?(elem["sun_mean_anomaly"])
            acc + elem["sine_coefficient"] * earth_eccentricity_correction**2 * Math.sin(sine_argument.radians)
          else
            acc + elem["sine_coefficient"] * Math.sin(sine_argument.radians)
          end
        end - 2235 * Math.sin(moon_mean_longitude.radians) +
                 382 * Math.sin(correction_latitude.radians) +
                 175 * Math.sin((correction_venus - moon_argument_of_latitude).radians) +
                 175 * Math.sin((correction_venus + moon_argument_of_latitude).radians) +
                 127 * Math.sin((moon_mean_longitude - moon_mean_anomaly).radians) +
                 -115 * Math.sin((moon_mean_longitude + moon_mean_anomaly).radians)
        result.round
      end

      # (Sigma r) Moon distance (A.A. p. 338)
      def calculate_moon_heliocentric_distance(
        moon_mean_elongation: calculate_moon_mean_elongation,
        sun_mean_anomaly: calculate_sun_mean_anomaly,
        moon_mean_anomaly: calculate_moon_mean_anomaly,
        moon_argument_of_latitude: calculate_moon_argument_of_latitude,
        earth_eccentricity_correction: calculate_earth_eccentricity_correction
      )
        result = PERIODIC_TERMS_MOON_LONGITUDE_DISTANCE.inject(0.0) do |acc, elem|
          cosine_argument = Angle.from_decimal_degrees(
            elem["moon_mean_elongation"] * moon_mean_elongation.decimal_degrees +
            elem["sun_mean_anomaly"] * sun_mean_anomaly.decimal_degrees +
            elem["moon_mean_anomaly"] * moon_mean_anomaly.decimal_degrees +
            elem["moon_argument_of_latitude"] * moon_argument_of_latitude.decimal_degrees
          )

          if elem["cosine_coefficient"].nil?
            next acc
          elsif [1, -1].include?(elem["sun_mean_anomaly"])
            acc + elem["cosine_coefficient"] * earth_eccentricity_correction * Math.cos(cosine_argument.radians)
          elsif [-2, 2].include?(elem["sun_mean_anomaly"])
            acc + elem["cosine_coefficient"] * earth_eccentricity_correction**2 * Math.cos(cosine_argument.radians)
          else
            acc + elem["cosine_coefficient"] * Math.cos(cosine_argument.radians)
          end
        end
        result.round
      end

      # (lambda) ecliptical longitude (A.A. p. 342)
      def calculate_moon_geocentric_longitude(
        moon_mean_longitude: calculate_moon_mean_longitude,
        moon_heliocentric_longitude: calculate_moon_heliocentric_longitude
      )
        Angle.from_decimal_degrees(moon_mean_longitude.decimal_degrees + moon_heliocentric_longitude / 1_000_000.0)
      end

      # (beta) ecliptical latitude (A.A. p. 342)
      def calculate_moon_ecliptic_latitude(
        moon_heliocentric_latitude: calculate_moon_heliocentric_latitude
      )
        Angle.from_decimal_degrees(
          moon_heliocentric_latitude / 1_000_000.0,
          normalize: false
        )
      end

      # (Delta) Earth-moon distance (in kilometers) (A.A. p. 342)
      def calculate_earth_moon_distance(
        moon_heliocentric_distance: calculate_moon_heliocentric_distance
      )
        result = 385_000.56 + (moon_heliocentric_distance / 1_000.0)
        result.round(1)
      end

      # (pi) Moon equitorial horizontal parallax (A.A. p. 337)
      def calculate_equitorial_horizontal_parallax(
        earth_moon_distance: calculate_earth_moon_distance
      )
        Angle.from_radians(Math.asin(6378.14 / earth_moon_distance))
      end

      # (apparent lambda) Moon apparent longitude (A.A. p. 343)
      def calculate_moon_ecliptic_longitude(
        moon_geocentric_longitude: calculate_moon_geocentric_longitude,
        earth_nutation_in_longitude: calculate_earth_nutation_in_longitude
      )
        moon_geocentric_longitude + earth_nutation_in_longitude
      end

      # (α) geocentric (apparent) right ascension of the moon (13.3 A.A. p. 93)
      def calculate_moon_geocentric_right_ascension(
        moon_ecliptic_longitude: calculate_moon_ecliptic_longitude,
        ecliptic_true_obliquity: calculate_ecliptic_true_obliquity,
        moon_ecliptic_latitude: calculate_moon_ecliptic_latitude
      )
        numerator = Math.sin(moon_ecliptic_longitude.radians) *
                    Math.cos(ecliptic_true_obliquity.radians) -
                    Math.tan(moon_ecliptic_latitude.radians) *
                    Math.sin(ecliptic_true_obliquity.radians)
        denominator = Math.cos(moon_ecliptic_longitude.radians)
        Angle.from_radians(Math.atan2(numerator, denominator))
      end

      # (delta) geocentric (apparent) declination of the moon (13.4) A.A. p. 93
      def calculate_moon_geocentric_declination(
        moon_ecliptic_latitude: calculate_moon_ecliptic_latitude,
        ecliptic_true_obliquity: calculate_ecliptic_true_obliquity,
        moon_ecliptic_longitude: calculate_moon_ecliptic_longitude
      )
        result = Math.sin(moon_ecliptic_latitude.radians) *
                 Math.cos(ecliptic_true_obliquity.radians) +
                 Math.cos(moon_ecliptic_latitude.radians) *
                 Math.sin(ecliptic_true_obliquity.radians) *
                 Math.sin(moon_ecliptic_longitude.radians)
        Angle.from_radians(Math.asin(result))
      end
    end
  end
end
