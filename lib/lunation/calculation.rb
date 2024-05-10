module Lunation
  class Calculation
    # (k) illuminated fraction of the moon (48.1, A.A. p. 345)
    def moon_illuminated_fraction
      result = (1 + Math.cos(moon_phase_angle * Math::PI / 180)) / 2.0
      result.round(4)
    end

    # (i) phase angle of the moon (48.3, A.A. p. 346)
    def moon_phase_angle
      numerator = earth_sun_distance_in_km * Math.sin(moon_geocentric_elongation * Math::PI / 180)
      denominator = earth_moon_distance - earth_sun_distance_in_km * Math.cos(moon_geocentric_elongation * Math::PI / 180)
      result = Math.atan2(numerator, denominator) / Math::PI * 180
      result.round(6)
    end
  end
end
