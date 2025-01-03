module Lunation
  class Calculation
    module EarthPositionVSOP87
      # rubocop:disable Layout/LineLength
      PERIODIC_TERMS_B0_PATH = File.expand_path("../../../config/periodic_terms_earth_position_b0.yml", __dir__).freeze
      PERIODIC_TERMS_B1_PATH = File.expand_path("../../../config/periodic_terms_earth_position_b1.yml", __dir__).freeze
      PERIODIC_TERMS_L0_PATH = File.expand_path("../../../config/periodic_terms_earth_position_l0.yml", __dir__).freeze
      PERIODIC_TERMS_L1_PATH = File.expand_path("../../../config/periodic_terms_earth_position_l1.yml", __dir__).freeze
      PERIODIC_TERMS_L2_PATH = File.expand_path("../../../config/periodic_terms_earth_position_l2.yml", __dir__).freeze
      PERIODIC_TERMS_L3_PATH = File.expand_path("../../../config/periodic_terms_earth_position_l3.yml", __dir__).freeze
      PERIODIC_TERMS_L4_PATH = File.expand_path("../../../config/periodic_terms_earth_position_l4.yml", __dir__).freeze
      PERIODIC_TERMS_L5_PATH = File.expand_path("../../../config/periodic_terms_earth_position_l5.yml", __dir__).freeze
      PERIODIC_TERMS_R0_PATH = File.expand_path("../../../config/periodic_terms_earth_position_r0.yml", __dir__).freeze
      PERIODIC_TERMS_R1_PATH = File.expand_path("../../../config/periodic_terms_earth_position_r1.yml", __dir__).freeze
      PERIODIC_TERMS_R2_PATH = File.expand_path("../../../config/periodic_terms_earth_position_r2.yml", __dir__).freeze
      PERIODIC_TERMS_R3_PATH = File.expand_path("../../../config/periodic_terms_earth_position_r3.yml", __dir__).freeze
      PERIODIC_TERMS_R4_PATH = File.expand_path("../../../config/periodic_terms_earth_position_r4.yml", __dir__).freeze
      PERIODIC_TERMS_B0 = YAML.load_file(PERIODIC_TERMS_B0_PATH).freeze
      PERIODIC_TERMS_B1 = YAML.load_file(PERIODIC_TERMS_B1_PATH).freeze
      PERIODIC_TERMS_L0 = YAML.load_file(PERIODIC_TERMS_L0_PATH).freeze
      PERIODIC_TERMS_L1 = YAML.load_file(PERIODIC_TERMS_L1_PATH).freeze
      PERIODIC_TERMS_L2 = YAML.load_file(PERIODIC_TERMS_L2_PATH).freeze
      PERIODIC_TERMS_L3 = YAML.load_file(PERIODIC_TERMS_L3_PATH).freeze
      PERIODIC_TERMS_L4 = YAML.load_file(PERIODIC_TERMS_L4_PATH).freeze
      PERIODIC_TERMS_L5 = YAML.load_file(PERIODIC_TERMS_L5_PATH).freeze
      PERIODIC_TERMS_R0 = YAML.load_file(PERIODIC_TERMS_R0_PATH).freeze
      PERIODIC_TERMS_R1 = YAML.load_file(PERIODIC_TERMS_R1_PATH).freeze
      PERIODIC_TERMS_R2 = YAML.load_file(PERIODIC_TERMS_R2_PATH).freeze
      PERIODIC_TERMS_R3 = YAML.load_file(PERIODIC_TERMS_R3_PATH).freeze
      PERIODIC_TERMS_R4 = YAML.load_file(PERIODIC_TERMS_R4_PATH).freeze
      # rubocop:enable Layout/LineLength

      # (L) Ecliptical longitude of the earth (A.A. p. 219, 32.2)
      # UNIT: Angle
      def ecliptic_longitude_of_earth_using_vsop87
        @ecliptic_longitude_of_earth_using_vsop87 ||= begin
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
      end

      # (B) Ecliptical latitude of the earth (A.A. p. 219, 32.2)
      # UNIT: Angle
      def ecliptic_latitude_of_earth_using_vsop87
        @ecliptic_latitude_of_earth_using_vsop87 ||= begin
          first_series = reduce_periodic_terms(PERIODIC_TERMS_B0)
          second_series = reduce_periodic_terms(PERIODIC_TERMS_B1)

          Angle.from_radians(
            (first_series + second_series * time_millennia).fdiv(100_000_000),
            normalize: false
          )
        end
      end

      # (R) Radius vector (distance to sun) of the earth (A.A. p. 219, 32.2)
      # UNIT: Astronomical Units (AU)
      def radius_vector_of_earth_using_vsop87
        @radius_vector_of_earth_using_vsop87 ||= begin
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
      end

      private def reduce_periodic_terms(periodic_terms)
        periodic_terms.inject(0.0) do |sum, terms|
          sum + terms[0] * Math.cos(terms[1] + terms[2] * time_millennia)
        end
      end
    end
  end
end
