module Lunation
  class Calculation
    module Timekeeping
      SECONDS_PER_DAY = 86_400

      # (T) time, measured in Julian centuries from the Epoch J2000.0 (22.1, A.A. p. 143)
      def time
        @time ||= ((julian_ephemeris_day - 2_451_545) / 36_525.0).round(12)
      end

      # ΔT https://eclipse.gsfc.nasa.gov/SEcat5/deltatpoly.html
      def delta_t
        case datetime.year
        when -1_999...-500
          elapsed_years = (@decimal_year - 1_820) / 100
          -20 + 32 * elapsed_years**2
        when -500...500
          elapsed_years = @decimal_year / 100.0
          10_583.6 -
            1_014.41 * elapsed_years +
            33.78311 * elapsed_years**2 -
            5.952053 * elapsed_years**3 -
            0.1798452 * elapsed_years**4 +
            0.022174192 * elapsed_years**5 +
            0.0090316521 * elapsed_years**6
        when 500...1_600
          elapsed_years = (@decimal_year - 1_000.0) / 100.0
          1_574.2 -
            556.01 * elapsed_years +
            71.23472 * elapsed_years**2 +
            0.319781 * elapsed_years**3 -
            0.8503463 * elapsed_years**4 -
            0.005050998 * elapsed_years**5 +
            0.0083572073 * elapsed_years**6
        when 1_600...1_700
          elapsed_years = @decimal_year - 1_600.0
          120 - 0.9808 * elapsed_years -
            0.01532 * elapsed_years**2 +
            elapsed_years**3 / 7_129
        when 1_700...1_800
          elapsed_years = @decimal_year - 1_700.0
          8.83 +
            0.1603 * elapsed_years -
            0.0059285 * elapsed_years**2 +
            0.00013336 * elapsed_years**3 -
            elapsed_years**4 / 1_174_000
        when 1_800...1_860
          elapsed_years = @decimal_year - 1_800
          13.72 -
            0.332447 * elapsed_years +
            0.0068612 * elapsed_years**2 +
            0.0041116 * elapsed_years**3 -
            0.00037436 * elapsed_years**4 +
            0.0000121272 * elapsed_years**5 -
            0.0000001699 * elapsed_years**6 +
            0.000000000875 * elapsed_years**7
        when 1_860...1_900
          elapsed_years = @decimal_year - 1_860
          7.62 +
            0.5737 * elapsed_years -
            0.251754 * elapsed_years**2 +
            0.01680668 * elapsed_years**3 -
            0.0004473624 * elapsed_years**4 +
            elapsed_years**5 / 233_174
        when 1_900...1_920
          elapsed_years = @decimal_year - 1_900
          -2.79 +
            1.494119 * elapsed_years -
            0.0598939 * elapsed_years**2 +
            0.0061966 * elapsed_years**3 -
            0.000197 * elapsed_years**4
        when 1_920...1_941
          elapsed_years = @decimal_year - 1_920
          21.20 +
            0.84493 * elapsed_years -
            0.076100 * elapsed_years**2 +
            0.0020936 * elapsed_years**3
        when 1_941...1_961
          elapsed_years = @decimal_year - 1_950
          29.07 +
            0.407 * elapsed_years -
            elapsed_years**2 / 233 +
            elapsed_years**3 / 2_547
        when 1_961...1_986
          elapsed_years = @decimal_year - 1_975
          45.45 +
            1.067 * elapsed_years -
            elapsed_years**2 / 260 -
            elapsed_years**3 / 718
        when 1_986...2_005
          elapsed_years = @decimal_year - 2_000
          63.86 +
            0.3345 * elapsed_years -
            0.060374 * elapsed_years**2 +
            0.0017275 * elapsed_years**3 +
            0.000651814 * elapsed_years**4 +
            0.00002373599 * elapsed_years**5
        when 2_005...2_050
          elapsed_years = @decimal_year - 2_000
          62.92 + 0.32217 * elapsed_years + 0.005589 * elapsed_years**2
        when 2_050...2_150
          -20 + 32 * ((@decimal_year - 1_820) / 100)**2 - 0.5628 * (2_150 - @decimal_year)
        when 2_150..3_000
          -20 + 32 * @decimal_year**2
        end.round(1)
      end

      # (TD) Dynamical time (A.A. p. 77)
      def dynamical_time
        @dynamical_time ||= datetime + delta_t.round.to_f / SECONDS_PER_DAY
      end

      # (JDE) Julian ephemeris day (A.A. p. 59)
      def julian_ephemeris_day
        dynamical_time.ajd.round(5)
      end

      # (t) tim, measured in Julian millennia from the epock J2000.0 (32.1, A.A. p. 218)
      def time_julian_millennia
        @time_julian_millennia ||= (time / 10.0).round(12)
      end

      # (U) Time measured in units of 10_000 Julian years from J2000.0 (A.A. p. 147)
      def julian_myriads_since_j2000
        time / 100.0
      end
    end
  end
end
