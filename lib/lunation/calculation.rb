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

    # (R) earth_sun_distance (25.5, A.A. p. 164)
    def earth_sun_distance
      result = 1.000001018 * (1 - earth_eccentricity**2) / (1 + earth_eccentricity * Math.cos(sun_true_anomaly * Math::PI / 180))
      result.round(7)
    end

    # (R) earth_sun_distance in km (25.5, A.A. p. 164)
    def earth_sun_distance_in_km
      (earth_sun_distance * 149_597_870).floor
    end

    # (e) eccentricity of the earth's orbit (25.4, A.A. p. 163)
    def earth_eccentricity
      result = 0.016708634 - 0.000042037 * time - 0.0000001267 * time**2
      result.round(9)
    end
  end
end
