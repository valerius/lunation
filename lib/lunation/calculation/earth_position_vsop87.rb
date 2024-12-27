module Lunation
  class Calculation
    module EarthPositionVSOP87
      # rubocop:disable Layout/LineLength
      PERIODIC_TERMS_B0 = YAML.load_file("config/periodic_terms_earth_position_b0.yml").freeze
      PERIODIC_TERMS_B1 = YAML.load_file("config/periodic_terms_earth_position_b1.yml").freeze
      PERIODIC_TERMS_L0 = YAML.load_file("config/periodic_terms_earth_position_l0.yml").freeze
      PERIODIC_TERMS_L1 = YAML.load_file("config/periodic_terms_earth_position_l1.yml").freeze
      PERIODIC_TERMS_L2 = YAML.load_file("config/periodic_terms_earth_position_l2.yml").freeze
      PERIODIC_TERMS_L3 = YAML.load_file("config/periodic_terms_earth_position_l3.yml").freeze
      PERIODIC_TERMS_L4 = YAML.load_file("config/periodic_terms_earth_position_l4.yml").freeze
      PERIODIC_TERMS_L5 = YAML.load_file("config/periodic_terms_earth_position_l5.yml").freeze
      PERIODIC_TERMS_R0 = YAML.load_file("config/periodic_terms_earth_position_r0.yml").freeze
      PERIODIC_TERMS_R1 = YAML.load_file("config/periodic_terms_earth_position_r1.yml").freeze
      PERIODIC_TERMS_R2 = YAML.load_file("config/periodic_terms_earth_position_r2.yml").freeze
      PERIODIC_TERMS_R3 = YAML.load_file("config/periodic_terms_earth_position_r3.yml").freeze
      PERIODIC_TERMS_R4 = YAML.load_file("config/periodic_terms_earth_position_r4.yml").freeze
      # rubocop:enable Layout/LineLength

      # (L) Ecliptical longitude of the earth (A.A. p. 219, 32.2)
      # UNIT: Angle
      def calculate_ecliptic_longitude_of_earth_using_vsop87
        result = Horner.compute(
          time_millennia,
          [
            reduce_periodic_terms(PERIODIC_TERMS_L0),
            reduce_periodic_terms(PERIODIC_TERMS_L1),
            reduce_periodic_terms(PERIODIC_TERMS_L2),
            reduce_periodic_terms(PERIODIC_TERMS_L3),
            reduce_periodic_terms(PERIODIC_TERMS_L4),
            reduce_periodic_terms(PERIODIC_TERMS_L5)
          ]
        )

        Angle.from_radians(result / 100_000_000.0)
      end

      # (B) Ecliptical latitude of the earth (A.A. p. 219, 32.2)
      # UNIT: Angle
      def calculate_ecliptic_latitude_of_earth_using_vsop87
        first_series = reduce_periodic_terms(PERIODIC_TERMS_B0)
        second_series = reduce_periodic_terms(PERIODIC_TERMS_B1)

        Angle.from_radians(
          (first_series + second_series * time_millennia) / 100_000_000.0,
          normalize: false
        )
      end

      # (R) Radius vector (distance to sun) of the earth (A.A. p. 219, 32.2)
      # UNIT: Astronomical Units (AU)
      def calculate_radius_vector_of_earth_using_vsop87
        result = Horner.compute(
          time_millennia,
          [
            reduce_periodic_terms(PERIODIC_TERMS_R0),
            reduce_periodic_terms(PERIODIC_TERMS_R1),
            reduce_periodic_terms(PERIODIC_TERMS_R2),
            reduce_periodic_terms(PERIODIC_TERMS_R3),
            reduce_periodic_terms(PERIODIC_TERMS_R4)
          ]
        )

        (result / 100_000_000.0).round(9)
      end

      private def reduce_periodic_terms(periodic_terms)
        periodic_terms.inject(0.0) do |sum, terms|
          sum + terms[0] * Math.cos(terms[1] + terms[2] * time_millennia)
        end
      end
    end
  end
end
