require_relative "nutation_and_obliquity"

module Lunation
  class Calculation
    module MoonPosition
      # rubocop:disable Layout/LineLength
      MOON_LONGITUDE_AND_DISTANCE_PERIOD_TERMS_PATH = File.expand_path("../../../config/periodic_terms_moon_longitude_distance.yml", __dir__).freeze
      MOON_LATITUDE_PERIOD_TERMS_PATH = File.expand_path("../../../config/periodic_terms_moon_latitude.yml", __dir__).freeze
      MOON_LONGITUDE_AND_DISTANCE_PERIOD_TERMS = YAML.load_file(MOON_LONGITUDE_AND_DISTANCE_PERIOD_TERMS_PATH).freeze
      MOON_LATITUDE_PERIOD_TERMS = YAML.load_file(MOON_LATITUDE_PERIOD_TERMS_PATH).freeze
      MOON_MEAN_LONGITUDE_CONSTANTS = [218.3164477, 481_267.88123421, -0.0015786, 1.fdiv(538_841), -1.fdiv(65_194_000)].freeze
      MOON_MEAN_ELONGATION_CONSTANTS = [297.8501921, 445_267.1114034, -0.0018819, 1.fdiv(545_868), -1.fdiv(113_065_000)].freeze
      MOON_MEAN_ANOMALY_CONSTANTS = [134.9633964, 477_198.8675055, 0.0087414, 1.fdiv(69_699), -1.fdiv(14_712_000)].freeze
      MOON_ARGUMENT_OF_LATITUDE_CONSTANTS = [93.2720950, 483_202.0175233, -0.0036539, -1.fdiv(3_526_000), 1.fdiv(863_310_000)].freeze
      CORRECTION_ECCENTRICITY_OF_EARTH_CONSTANTS = [1, -0.002516, -0.0000074].freeze
      FIXED_DISTANCE_BETWEEN_EARTH_AND_MOON = 385_000.56
      RADIUS_OF_EARTH = 6378.14
      # rubocop:enable Layout/LineLength

      # (L') Moon mean_longitude (47.1, A.A. p. 338)
      # UNIT: Angle
      def moon_mean_longitude
        @moon_mean_longitude ||=
          Angle.from_decimal_degrees(Horner.compute(time, MOON_MEAN_LONGITUDE_CONSTANTS))
      end

      # (D) Moon mean_elongation (47.2, A.A. p. 338)
      # UNIT: Angle
      def moon_mean_elongation_from_sun_high_precision
        @moon_mean_elongation_from_sun_high_precision ||=
          Angle.from_decimal_degrees(Horner.compute(time, MOON_MEAN_ELONGATION_CONSTANTS))
      end

      # (M') Moon mean_anomaly (47.4, A.A. p. 338)
      # UNIT: Angle
      def moon_mean_anomaly_high_precision
        @moon_mean_anomaly_high_precision ||=
          Angle.from_decimal_degrees(Horner.compute(time, MOON_MEAN_ANOMALY_CONSTANTS))
      end

      # (F) Moon argument_of_latitude (47.5, A.A. p. 338)
      # UNIT: Angle
      def moon_argument_of_latitude_high_precision
        @moon_argument_of_latitude_high_precision ||= begin
          result = Horner.compute(time, MOON_ARGUMENT_OF_LATITUDE_CONSTANTS)
          Angle.from_decimal_degrees(result)
        end
      end

      # (A1) Venus correction (A.A. p. 338)
      # UNIT: Angle
      def correction_venus
        @correction_venus ||= Angle.from_decimal_degrees(119.75 + 131.849 * time)
      end

      # (A2) Jupiter correction (A.A. p. 338)
      # UNIT: Angle
      def correction_jupiter
        @correction_jupiter ||= Angle.from_decimal_degrees(53.09 + 4_792_64.29 * time)
      end

      # (A3) latitude correction (A.A. p. 338)
      # UNIT: Angle
      def correction_latitude
        @correction_latitude ||= Angle.from_decimal_degrees(313.45 + 481_266.484 * time)
      end

      # (E) Earth eccentricity (47.6 A.A. p. 338)
      def correction_eccentricity_of_earth
        @correction_eccentricity_of_earth ||= begin
          result = Horner.compute(time, CORRECTION_ECCENTRICITY_OF_EARTH_CONSTANTS)
          result.round(6)
        end
      end

      # (Σl) Moon longitude (A.A. p. 338)
      # UNIT: decimal degrees
      def moon_heliocentric_longitude
        @moon_heliocentric_longitude ||= begin
          result = MOON_LONGITUDE_AND_DISTANCE_PERIOD_TERMS.inject(0.0) do |acc, elem|
            sine_argument = Angle.from_decimal_degrees(
              elem[0] * moon_mean_elongation_from_sun_high_precision.decimal_degrees +
              elem[1] * sun_mean_anomaly2.decimal_degrees +
              elem[2] * moon_mean_anomaly_high_precision.decimal_degrees +
              elem[3] * moon_argument_of_latitude_high_precision.decimal_degrees
            )

            if elem[4].nil?
              next acc
            elsif [1, -1].include?(elem[1])
              acc + elem[4] * correction_eccentricity_of_earth * sine_argument.sin
            elsif [-2, 2].include?(elem[1])
              acc + elem[4] * correction_eccentricity_of_earth**2 * sine_argument.sin
            else
              acc + elem[4] * sine_argument.sin
            end
          end + 3958 * correction_venus.sin +
            1962 * (moon_mean_longitude - moon_argument_of_latitude_high_precision).sin +
            318 * correction_jupiter.sin
          result.round
        end
      end

      # (Σb) Moon latitude (A.A. p. 338)
      # UNIT: decimal degrees
      def moon_heliocentric_latitude
        @moon_heliocentric_latitude ||= begin
          result = MOON_LATITUDE_PERIOD_TERMS.inject(0.0) do |acc, elem|
            sine_argument = Angle.from_decimal_degrees(
              elem[0] * moon_mean_elongation_from_sun_high_precision.decimal_degrees +
              elem[1] * sun_mean_anomaly2.decimal_degrees +
              elem[2] * moon_mean_anomaly_high_precision.decimal_degrees +
              elem[3] * moon_argument_of_latitude_high_precision.decimal_degrees
            )

            if elem[4].nil?
              next acc
            elsif [1, -1].include?(elem[1])
              acc + elem[4] * correction_eccentricity_of_earth * sine_argument.sin
            elsif [-2, 2].include?(elem[1])
              acc + elem[4] * correction_eccentricity_of_earth**2 * sine_argument.sin
            else
              acc + elem[4] * sine_argument.sin
            end
          end - 2235 * moon_mean_longitude.sin +
            382 * correction_latitude.sin +
            175 * (correction_venus - moon_argument_of_latitude_high_precision).sin +
            175 * (correction_venus + moon_argument_of_latitude_high_precision).sin +
            127 * (moon_mean_longitude - moon_mean_anomaly_high_precision).sin +
            -115 * (moon_mean_longitude + moon_mean_anomaly_high_precision).sin
          result.round
        end
      end

      # (Σr) Moon distance (A.A. p. 338)
      # UNIT: 1000 km
      def moon_heliocentric_distance
        @moon_heliocentric_distance ||= begin
          result = MOON_LONGITUDE_AND_DISTANCE_PERIOD_TERMS.inject(0.0) do |acc, elem|
            cosine_argument = Angle.from_decimal_degrees(
              elem[0] * moon_mean_elongation_from_sun_high_precision.decimal_degrees +
              elem[1] * sun_mean_anomaly2.decimal_degrees +
              elem[2] * moon_mean_anomaly_high_precision.decimal_degrees +
              elem[3] * moon_argument_of_latitude_high_precision.decimal_degrees
            )

            if elem[5].nil?
              next acc
            elsif [1, -1].include?(elem[1])
              acc + elem[5] * correction_eccentricity_of_earth * cosine_argument.cos
            elsif [-2, 2].include?(elem[1])
              acc + elem[5] * correction_eccentricity_of_earth**2 * cosine_argument.cos
            else
              acc + elem[5] * cosine_argument.cos
            end
          end
          result.round
        end
      end

      # (λ) ecliptical longitude (A.A. p. 342)
      # UNIT: Angle
      def moon_ecliptic_longitude
        @moon_ecliptic_longitude ||= Angle.from_decimal_degrees(
          moon_mean_longitude.decimal_degrees +
            moon_heliocentric_longitude.fdiv(1_000_000)
        )
      end

      # (β) ecliptical latitude (A.A. p. 342)
      # UNIT: Angle
      def moon_ecliptic_latitude
        @moon_ecliptic_latitude ||= Angle.from_decimal_degrees(
          moon_heliocentric_latitude.fdiv(1_000_000),
          normalize: false
        )
      end

      # (Δ) Earth-moon distance (in kilometers) (A.A. p. 342)
      # UNIT: kilometers (km)
      def distance_between_earth_and_moon
        @distance_between_earth_and_moon ||= begin
          result = FIXED_DISTANCE_BETWEEN_EARTH_AND_MOON +
            moon_heliocentric_distance.fdiv(1_000)
          result.round(1)
        end
      end

      # (π) Moon equitorial horizontal parallax (A.A. p. 337)
      # UNIT: Angle
      def equatorial_horizontal_parallax
        @equatorial_horizontal_parallax ||= Angle.from_radians(
          Math.asin(RADIUS_OF_EARTH / distance_between_earth_and_moon)
        )
      end

      # (apparent λ) Moon apparent longitude (A.A. p. 343)
      # UNIT: Angle
      def moon_apparent_ecliptic_longitude
        @moon_apparent_ecliptic_longitude ||=
          moon_ecliptic_longitude + nutation_in_longitude
      end

      # (α) geocentric (apparent) right ascension of the moon (13.3 A.A. p. 93)
      # UNIT: Angle
      def moon_right_ascension
        @moon_right_ascension ||= begin
          numerator = moon_apparent_ecliptic_longitude.sin *
            obliquity_of_ecliptic.cos -
            moon_ecliptic_latitude.tan *
              obliquity_of_ecliptic.sin
          denominator = moon_apparent_ecliptic_longitude.cos
          Angle.from_radians(Math.atan2(numerator, denominator))
        end
      end

      # (δ) geocentric (apparent) declination of the moon (13.4) A.A. p. 93
      # UNIT: Angle
      def moon_declination
        @moon_declination ||= begin
          result = moon_ecliptic_latitude.sin *
            obliquity_of_ecliptic.cos +
            moon_ecliptic_latitude.cos *
              obliquity_of_ecliptic.sin *
              moon_apparent_ecliptic_longitude.sin
          Angle.from_radians(Math.asin(result))
        end
      end
    end
  end
end
