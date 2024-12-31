module Lunation
  class Calculation
    module MoonIlluminatedFraction
      # (k) illuminated fraction of the moon (48.1, A.A. p. 345)
      # UNIT: fraction (decimal)
      def moon_illuminated_fraction
        @moon_illuminated_fraction ||=
          (1 + moon_phase_angle.cos).fdiv(2).round(4)
      end

      # (i) phase angle of the moon (48.3, A.A. p. 346)
      # UNIT: Angle
      def moon_phase_angle
        @moon_phase_angle ||= begin
          numerator = distance_between_earth_and_sun_in_kilometers * moon_elongation_from_sun.sin
          denominator = distance_between_earth_and_moon -
            distance_between_earth_and_sun_in_kilometers * moon_elongation_from_sun.cos
          Angle.from_radians(Math.atan2(numerator, denominator))
        end
      end

      # (ψ) geocentric elongation of the moon (48.2, A.A. p. 345)
      # UNIT: Angle
      def moon_elongation_from_sun
        @moon_elongation_from_sun ||= begin
          result = sun_declination.sin *
            moon_declination.sin +
            sun_declination.cos *
              moon_declination.cos *
              (sun_right_ascension - moon_right_ascension).cos
          Angle.from_radians(Math.acos(result))
        end
      end

      # (χ) Position angle of the moon's bright limb (48.5, A.A. p. 346)
      # UNIT: Angle
      def moon_position_angle_of_bright_limb
        @moon_position_angle_of_bright_limb ||= begin
          numerator = sun_declination.cos *
            (sun_right_ascension - moon_right_ascension).sin
          denominator = sun_declination.sin *
            moon_declination.cos -
            sun_declination.cos *
              moon_declination.sin *
              (sun_right_ascension - moon_right_ascension).cos
          Angle.from_radians(Math.atan2(numerator, denominator))
        end
      end
    end
  end
end
