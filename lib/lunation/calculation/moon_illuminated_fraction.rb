module Lunation
  class Calculation
    module MoonIlluminatedFraction
      # (k) illuminated fraction of the moon (48.1, A.A. p. 345)
      def calculate_moon_illuminated_fraction(moon_phase_angle: calculate_moon_phase_angle)
        result = (1 + Math.cos(moon_phase_angle.radians)) / 2.0
        result.round(4)
      end

      # (i) phase angle of the moon (48.3, A.A. p. 346)
      def calculate_moon_phase_angle(
        earth_sun_distance_in_km: calculate_earth_sun_distance_in_km,
        moon_geocentric_elongation: calculate_moon_geocentric_elongation,
        earth_moon_distance: calculate_earth_moon_distance
      )
        numerator = earth_sun_distance_in_km * Math.sin(moon_geocentric_elongation.radians)
        denominator = earth_moon_distance - earth_sun_distance_in_km * Math.cos(moon_geocentric_elongation.radians)
        Angle.from_radians(Math.atan2(numerator, denominator))
      end
    end
  end
end
