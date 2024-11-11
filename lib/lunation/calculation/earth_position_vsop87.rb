module Lunation
  class Calculation
    module EarthPositionVSOP87
      PERIODIC_TERMS_EARTH_POSITION_VSOP87_B0 = YAML.load_file("config/periodic_terms_earth_position_b0.yml").freeze
      PERIODIC_TERMS_EARTH_POSITION_VSOP87_B1 = YAML.load_file("config/periodic_terms_earth_position_b1.yml").freeze
      PERIODIC_TERMS_EARTH_POSITION_VSOP87_L0 = YAML.load_file("config/periodic_terms_earth_position_l0.yml").freeze
      PERIODIC_TERMS_EARTH_POSITION_VSOP87_L1 = YAML.load_file("config/periodic_terms_earth_position_l1.yml").freeze
      PERIODIC_TERMS_EARTH_POSITION_VSOP87_L2 = YAML.load_file("config/periodic_terms_earth_position_l2.yml").freeze
      PERIODIC_TERMS_EARTH_POSITION_VSOP87_L3 = YAML.load_file("config/periodic_terms_earth_position_l3.yml").freeze
      PERIODIC_TERMS_EARTH_POSITION_VSOP87_L4 = YAML.load_file("config/periodic_terms_earth_position_l4.yml").freeze
      PERIODIC_TERMS_EARTH_POSITION_VSOP87_L5 = YAML.load_file("config/periodic_terms_earth_position_l5.yml").freeze
      PERIODIC_TERMS_EARTH_POSITION_VSOP87_R0 = YAML.load_file("config/periodic_terms_earth_position_r0.yml").freeze
      PERIODIC_TERMS_EARTH_POSITION_VSOP87_R1 = YAML.load_file("config/periodic_terms_earth_position_r1.yml").freeze
      PERIODIC_TERMS_EARTH_POSITION_VSOP87_R2 = YAML.load_file("config/periodic_terms_earth_position_r2.yml").freeze
      PERIODIC_TERMS_EARTH_POSITION_VSOP87_R3 = YAML.load_file("config/periodic_terms_earth_position_r3.yml").freeze
      PERIODIC_TERMS_EARTH_POSITION_VSOP87_R4 = YAML.load_file("config/periodic_terms_earth_position_r4.yml").freeze

      def calculate_earth_ecliptical_longitude_vsop87
        first_series = PERIODIC_TERMS_EARTH_POSITION_VSOP87_L0.inject(0.0) do |sum, terms|
          sum + terms[0] * Math.cos(terms[1] + terms[2] * time_julian_millennia)
        end
        second_series = PERIODIC_TERMS_EARTH_POSITION_VSOP87_L1.inject(0.0) do |sum, terms|
          sum + terms[0] * Math.cos(terms[1] + terms[2] * time_julian_millennia)
        end
        third_series = PERIODIC_TERMS_EARTH_POSITION_VSOP87_L2.inject(0.0) do |sum, terms|
          sum + terms[0] * Math.cos(terms[1] + terms[2] * time_julian_millennia)
        end
        fourth_series = PERIODIC_TERMS_EARTH_POSITION_VSOP87_L3.inject(0.0) do |sum, terms|
          sum + terms[0] * Math.cos(terms[1] + terms[2] * time_julian_millennia)
        end
        fifth_series = PERIODIC_TERMS_EARTH_POSITION_VSOP87_L4.inject(0.0) do |sum, terms|
          sum + terms[0] * Math.cos(terms[1] + terms[2] * time_julian_millennia)
        end
        sixth_series = PERIODIC_TERMS_EARTH_POSITION_VSOP87_L5.inject(0.0) do |sum, terms|
          sum + terms[0] * Math.cos(terms[1] + terms[2] * time_julian_millennia)
        end

        result = first_series +
                 second_series * time_julian_millennia +
                 third_series * time_julian_millennia**2 +
                 fourth_series * time_julian_millennia**3 +
                 fifth_series * time_julian_millennia**4 +
                 sixth_series * time_julian_millennia**5

        Angle.from_radians(result / 100_000_000.0)
      end

      def calculate_earth_ecliptical_latitude_vsop87
        first_series = PERIODIC_TERMS_EARTH_POSITION_VSOP87_B0.inject(0.0) do |sum, terms|
          sum + terms[0] * Math.cos(terms[1] + terms[2] * time_julian_millennia)
        end
        second_series = PERIODIC_TERMS_EARTH_POSITION_VSOP87_B1.inject(0.0) do |sum, terms|
          sum + terms[0] * Math.cos(terms[1] + terms[2] * time_julian_millennia)
        end

        Angle.from_radians(
          (first_series + second_series * time_julian_millennia) / 100_000_000.0,
          normalize: false
        )
      end

      def calculate_radius_vector_vsop87
        first_series = PERIODIC_TERMS_EARTH_POSITION_VSOP87_R0.inject(0.0) do |sum, terms|
          sum + terms[0] * Math.cos(terms[1] + terms[2] * time_julian_millennia)
        end
        second_series = PERIODIC_TERMS_EARTH_POSITION_VSOP87_R1.inject(0.0) do |sum, terms|
          sum + terms[0] * Math.cos(terms[1] + terms[2] * time_julian_millennia)
        end
        third_series = PERIODIC_TERMS_EARTH_POSITION_VSOP87_R2.inject(0.0) do |sum, terms|
          sum + terms[0] * Math.cos(terms[1] + terms[2] * time_julian_millennia)
        end
        fourth_series = PERIODIC_TERMS_EARTH_POSITION_VSOP87_R3.inject(0.0) do |sum, terms|
          sum + terms[0] * Math.cos(terms[1] + terms[2] * time_julian_millennia)
        end
        fifth_series = PERIODIC_TERMS_EARTH_POSITION_VSOP87_R4.inject(0.0) do |sum, terms|
          sum + terms[0] * Math.cos(terms[1] + terms[2] * time_julian_millennia)
        end

        result = first_series +
                 second_series * time_julian_millennia +
                 third_series * time_julian_millennia**2 +
                 fourth_series * time_julian_millennia**3 +
                 fifth_series * time_julian_millennia**4

        (result / 100_000_000.0).round(9)
      end
    end
  end
end
