module Lunation
  class Calculation
    # (k) illuminated fraction of the moon (48.1, A.A. p. 345)
    def moon_illuminated_fraction
      result = (1 + Math.cos(moon_phase_angle * Math::PI / 180)) / 2.0
      result.round(4)
    end
  end
end
