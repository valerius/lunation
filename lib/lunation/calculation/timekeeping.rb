module Lunation
  class Calculation
    module Timekeeping
      SECONDS_PER_DAY = 86_400
      EPOCH_J2000_JDE = 2_451_545 # expressed in terms of Julian Ephemeris Day
      JULIAN_CENTURY_IN_DAYS = 36_525.0
      # rubocop:disable Layout/LineLength
      DELTA_T_500BC_500AD = [10_583.6, -1_014.41, 33.78311, -5.952053, -0.1798452, 0.022174192, 0.0090316521].freeze
      DELTA_T_500AD_1600AD = [1_574.2, -556.01, 71.23472, 0.319781, -0.8503463, -0.005050998, 0.0083572073].freeze
      DELTA_T_1600AD_1700AD = [120, -0.9808, -0.01532, 1 / 7_129.0].freeze
      DELTA_T_1700AD_1800AD = [8.83, 0.1603, -0.0059285, 0.00013336, -1 / 1_174_000.0].freeze
      DELTA_T_1800AD_1860AD = [13.72, -0.332447, 0.0068612, 0.0041116, -0.00037436, 0.0000121272, -0.0000001699, 0.000000000875].freeze
      DELTA_T_1860AD_1900AD = [7.62, 0.5737, -0.251754, 0.01680668, -0.0004473624, 1 / 233_174.0].freeze
      DELTA_T_1900AD_1920AD = [-2.79, 1.494119, -0.0598939, 0.0061966, -0.000197].freeze
      DELTA_T_1920AD_1941AD = [21.20, 0.84493, -0.076100, 0.0020936].freeze
      DELTA_T_1941AD_1961AD = [29.07, 0.407, -1 / 233.0, 1 / 2_547.0].freeze
      DELTA_T_1961AD_1986AD = [45.45, 1.067, -1 / 260.0, -1 / 718.0].freeze
      DELTA_T_1986AD_2005AD = [63.86, 0.3345, -0.060374, 0.0017275, 0.000651814, 0.00002373599].freeze
      DELTA_T_2005AD_2050AD = [62.92, 0.32217, 0.005589].freeze
      # rubocop:enable Layout/LineLength

      # (T) time, measured in Julian centuries from the Epoch J2000.0 (22.1, A.A. p. 143)
      # UNIT: centuries from the Epoch J2000.0
      def time
        @time ||= ((julian_ephemeris_day - EPOCH_J2000_JDE) / JULIAN_CENTURY_IN_DAYS).round(12)
      end

      # ΔT Difference between Dynamical Time (TD) and Universal Time (UT, more commonly
      #   known as Greenwhich Time).
      # The formula for ΔT was taken from a later paper written by Espenak and Meeus
      #   (https://eclipse.gsfc.nasa.gov/SEcat5/deltatpoly.html). ΔT is described less
      #   precisely in the book (A.A. p. 78-79, formulae 10.0 and 10.2).
      # UNIT: seconds
      def delta_t
        case datetime.year
        when -1_999...-500
          elapsed_years = (@decimal_year - 1_820) / 100
          -20 + 32 * elapsed_years**2
        when -500...500
          Horner.compute(@decimal_year / 100.0, DELTA_T_500BC_500AD)
        when 500...1_600
          Horner.compute((@decimal_year - 1_000.0) / 100.0, DELTA_T_500AD_1600AD)
        when 1_600...1_700
          Horner.compute(@decimal_year - 1_600.0, DELTA_T_1600AD_1700AD)
        when 1_700...1_800
          Horner.compute(@decimal_year - 1_700.0, DELTA_T_1700AD_1800AD)
        when 1_800...1_860
          Horner.compute(@decimal_year - 1_800, DELTA_T_1800AD_1860AD)
        when 1_860...1_900
          Horner.compute(@decimal_year - 1_860, DELTA_T_1860AD_1900AD)
        when 1_900...1_920
          Horner.compute(@decimal_year - 1_900, DELTA_T_1900AD_1920AD)
        when 1_920...1_941
          Horner.compute(@decimal_year - 1_920, DELTA_T_1920AD_1941AD)
        when 1_941...1_961
          Horner.compute(@decimal_year - 1_950, DELTA_T_1941AD_1961AD)
        when 1_961...1_986
          Horner.compute(@decimal_year - 1_975, DELTA_T_1961AD_1986AD)
        when 1_986...2_005
          Horner.compute(@decimal_year - 2_000, DELTA_T_1986AD_2005AD)
        when 2_005...2_050
          Horner.compute(@decimal_year - 2_000, DELTA_T_2005AD_2050AD)
        when 2_050...2_150
          -20 + 32 * ((@decimal_year - 1_820) / 100)**2 - 0.5628 * (2_150 - @decimal_year)
        when 2_150..3_000
          -20 + 32 * @decimal_year**2
        end.round(1)
      end

      # (TD) Dynamical time (A.A. p. 77)
      # UNIT: ISO 8601 Date and time with offset
      def dynamical_time
        @dynamical_time ||= datetime + delta_t.round.to_f / SECONDS_PER_DAY
      end

      # (JDE) Julian ephemeris day (A.A. p. 59)
      # UNIT: days, expressed as a floating point number
      def julian_ephemeris_day
        dynamical_time.ajd.to_f.round(5)
      end

      # (t) time, measured in Julian millennia from the epoch J2000.0 (32.1, A.A. p. 218)
      # UNIT: millennia from the Epoch J2000.0
      def time_millennia
        @time_millennia ||= (time / 10.0).round(12)
      end

      # (U) Time measured in units of 10_000 Julian years from J2000.0 (A.A. p. 147)
      # UNIT: 10_000 years (myriads) from the Epoch J2000.0
      def time_myriads
        time / 100.0
      end
    end
  end
end
