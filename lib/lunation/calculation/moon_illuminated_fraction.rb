module Lunation
  class Calculation
    module MoonIlluminatedFraction
      # (k) illuminated fraction of the moon (48.1, A.A. p. 345)
      # UNIT: fraction (decimal)
      def moon_illuminated_fraction
        @moon_illuminated_fraction ||=
          ((1 + Math.cos(moon_phase_angle.radians)) / 2.0).round(4)
      end

      # (i) phase angle of the moon (48.3, A.A. p. 346)
      # UNIT: Angle
      def moon_phase_angle
        @moon_phase_angle ||= begin
          numerator = distance_between_earth_and_sun_in_kilometers * Math.sin(moon_elongation_from_sun.radians)
          denominator = distance_between_earth_and_moon -
            distance_between_earth_and_sun_in_kilometers * Math.cos(moon_elongation_from_sun.radians)
          Angle.from_radians(Math.atan2(numerator, denominator))
        end
      end

      # (ψ) geocentric elongation of the moon (48.2, A.A. p. 345)
      # UNIT: Angle
      def moon_elongation_from_sun
        @moon_elongation_from_sun ||= begin
          result = Math.sin(sun_declination.radians) *
            Math.sin(moon_declination.radians) +
            Math.cos(sun_declination.radians) *
              Math.cos(moon_declination.radians) *
              Math.cos((sun_right_ascension - moon_right_ascension).radians)
          Angle.from_radians(Math.acos(result))
        end
      end

      # (χ) Position angle of the moon's bright limb (48.5, A.A. p. 346)
      # UNIT: Angle
      def moon_position_angle_of_bright_limb
        @moon_position_angle_of_bright_limb ||= begin
          numerator = Math.cos(sun_declination.radians) *
            Math.sin((sun_right_ascension - moon_right_ascension).radians)
          denominator = Math.sin(sun_declination.radians) *
            Math.cos(moon_declination.radians) -
            Math.cos(sun_declination.radians) *
              Math.sin(moon_declination.radians) *
              Math.cos((sun_right_ascension - moon_right_ascension).radians)
          Angle.from_radians(Math.atan2(numerator, denominator))
        end
      end
    end
  end
end
