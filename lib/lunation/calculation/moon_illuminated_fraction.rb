module Lunation
  class Calculation
    module MoonIlluminatedFraction
      # (k) illuminated fraction of the moon (48.1, A.A. p. 345)
      # UNIT: fraction (decimal)
      def calculate_moon_illuminated_fraction(moon_phase_angle: calculate_moon_phase_angle)
        result = (1 + Math.cos(moon_phase_angle.radians)) / 2.0
        result.round(4)
      end

      # (i) phase angle of the moon (48.3, A.A. p. 346)
      # UNIT: Angle
      def calculate_moon_phase_angle(
        distance_between_earth_and_sun_in_kilometers: calculate_distance_between_earth_and_sun_in_kilometers,
        moon_elongation_from_sun: calculate_moon_elongation_from_sun,
        distance_between_earth_and_moon: calculate_distance_between_earth_and_moon
      )
        numerator = distance_between_earth_and_sun_in_kilometers * Math.sin(moon_elongation_from_sun.radians)
        denominator = distance_between_earth_and_moon -
          distance_between_earth_and_sun_in_kilometers * Math.cos(moon_elongation_from_sun.radians)
        Angle.from_radians(Math.atan2(numerator, denominator))
      end

      # (ψ) geocentric elongation of the moon (48.2, A.A. p. 345)
      # UNIT: Angle
      def calculate_moon_elongation_from_sun(
        sun_declination: calculate_sun_declination,
        moon_declination: calculate_moon_declination,
        sun_right_ascension: calculate_sun_right_ascension,
        moon_right_ascension: calculate_moon_right_ascension
      )
        result = Math.sin(sun_declination.radians) *
          Math.sin(moon_declination.radians) +
          Math.cos(sun_declination.radians) *
            Math.cos(moon_declination.radians) *
            Math.cos((sun_right_ascension - moon_right_ascension).radians)
        Angle.from_radians(Math.acos(result))
      end
    end
  end
end
