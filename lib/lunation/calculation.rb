require "date"
require "yaml"

module Lunation
  class Calculation
    SECONDS_PER_DAY = 86_400
    PERIODIC_TERMS_MOON_LONGITUDE_DISTANCE = YAML.load_file("config/periodic_terms_moon_longitude_distance.yml").freeze

    attr_reader :datetime

    def initialize(datetime)
      @datetime = datetime
      @decimal_year = datetime.year + (datetime.month - 0.5) / 12.0
    end

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

    # (E) Earth eccentricity (47.6 A.A. p. 338)
    def earth_eccentricity_correction
      result = 1 - 0.002516 * time - 0.0000074 * time**2
      result.round(6)
    end

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

    # (v) true anomaly of the sun (A.A. p. 164)
    def sun_true_anomaly
      (sun_mean_anomaly + sun_equation_center).round(5)
    end

    # (M) Sun mean_anomaly (25.3, A.A. p. 163)
    def sun_mean_anomaly
      result = 357.52911 + 35_999.05029 * time - 0.0001537 * time**2
      (result % 360).round(6)
    end

    # (M) Sun mean_anomaly (A.A. p. 144)
    def sun_mean_anomaly2
      result = 357.52772 + 35_999.050340 * time - 0.0001603 * time**2 - time**3 / 300_000.0
      (result % 360).round(6)
    end

    # (C) Sun's equation of the center (A.A. p. 164)
    def sun_equation_center
      result = (1.914602 - 0.004817 * time - 0.000014 * time**2) * Math.sin(sun_mean_anomaly * Math::PI / 180) +
               (0.019993 - 0.000101 * time) * Math.sin(2 * sun_mean_anomaly * Math::PI / 180) +
               0.000289 * Math.sin(3 * sun_mean_anomaly * Math::PI / 180)
      result.round(5)
    end

    # (psi) geocentric elongation of the moon (48.2, A.A. p. 345)
    def moon_geocentric_elongation
      result = Math.sin(sun_geocentric_declination * Math::PI / 180) *
               Math.sin(moon_geocentric_declination * Math::PI / 180) +
               Math.cos(sun_geocentric_declination * Math::PI / 180) *
               Math.cos(moon_geocentric_declination * Math::PI / 180) *
               Math.cos((sun_geocentric_right_ascension - moon_geocentric_right_ascension) * Math::PI / 180)
      (Math.acos(result) / Math::PI * 180).round(4)
    end

    # (delta0) geocentric declination (of the sun) (13.4) A.A. p. 93
    def sun_geocentric_declination
      result = Math.sin(corrected_ecliptic_true_obliquity * Math::PI / 180) *
               Math.sin(sun_ecliptical_longitude * Math::PI / 180)
      (Math.asin(result) / Math::PI * 180).round(5)
    end

    # (Delta) Earth-moon distance (in kilometers) (A.A. p. 342)
    def earth_moon_distance
      result = 385_000.56 + (moon_heliocentric_distance / 1_000.0)
      result.round(1)
    end

    # (t) tim, measured in Julian millennia from the epock J2000.0 (32.1, A.A. p. 218)
    def time_julian_millennia
      @time_julian_millennia ||= (time / 10.0).round(12)
    end

    # (L') Moon mean_longitude (47.1, A.A. p. 338)
    def moon_mean_longitude
      result = 218.3164477 + (481_267.88123421 * time) - (0.0015786 * (time**2)) + ((time**3) / 538_841.0) - ((time**4) / 65_194_000.0)
      (result % 360).round(6)
    end

    # (D) Moon mean_elongation (47.2, A.A. p. 338)
    def moon_mean_elongation
      result = 297.8501921 + 445_267.1114034 * time - 0.0018819 * time**2 + time**3 / 545_868.0 - time**4 / 113_065_000.0
      (result % 360).round(6)
    end

    # (M') Moon mean_anomaly (47.4, A.A. p. 338)
    def moon_mean_anomaly
      result = 134.9633964 + 477_198.8675055 * time + 0.0087414 * time**2 + time**3 / 69_699 - time**4 / 14_712_000
      (result % 360).round(6)
    end

    # (M') Moon mean_anomaly (A.A. p. 149)
    def moon_mean_anomaly2
      result = 134.96298 + 477_198.867398 * time + 0.0086972 * time**2 + time**3 / 56_250.0
      (result % 360).round(4)
    end

    # (F) Moon argument_of_latitude (47.5, A.A. p. 338)
    def moon_argument_of_latitude
      result = 93.2720950 + 483_202.0175233 * time - 0.0036539 * time**2 - time**3 / 3_526_000 + time**4 / 863_310_000.0
      (result % 360).round(6)
    end

    # (F) Moon argument_of_latitude (A.A. p. 144)
    def moon_argument_of_latitude2
      result = 93.27191 + 483_202.017538 * time - 0.0036825 * time**2 + time**3 / 327_270.0
      (result % 360).round(4)
    end

    # (A1) Venus correction (A.A. p. 338)
    def correction_venus
      result = 119.75 + 131.849 * time
      (result % 360).round(2)
    end

    # (A2) Jupiter correction (A.A. p. 338)
    def correction_jupiter
      result = 53.09 + 4_792_64.29 * time
      (result % 360).round(2)
    end

    # (A3) latitude correction (A.A. p. 338)
    def correction_latitude
      result = 313.45 + 481_266.484 * time
      (result % 360).round(2)
    end

    # (Sigma l) Moon longitude (A.A. p. 338)
    def moon_heliocentric_longitude
      result = PERIODIC_TERMS_MOON_LONGITUDE_DISTANCE.inject(0.0) do |acc, elem|
        sine_argument = (
          elem["moon_mean_elongation"] * moon_mean_elongation +
          elem["sun_mean_anomaly"] * sun_mean_anomaly +
          elem["moon_mean_anomaly"] * moon_mean_anomaly +
          elem["moon_argument_of_latitude"] * moon_argument_of_latitude
        ) % 360

        if elem["sine_coefficient"].nil?
          next acc
        elsif [1, -1].include?(elem["sun_mean_anomaly"])
          acc + elem["sine_coefficient"] * earth_eccentricity_correction * Math.sin(sine_argument * Math::PI / 180)
        elsif [-2, 2].include?(elem["sun_mean_anomaly"])
          acc + elem["sine_coefficient"] * earth_eccentricity_correction**2 * Math.sin(sine_argument * Math::PI / 180)
        else
          acc + elem["sine_coefficient"] * Math.sin(sine_argument * Math::PI / 180)
        end
      end + 3958 * Math.sin(correction_venus * Math::PI / 180) +
               1962 * Math.sin((moon_mean_longitude - moon_argument_of_latitude) % 360 * Math::PI / 180) +
               318 * Math.sin(correction_jupiter * Math::PI / 180)
      result.round
    end

    # (Sigma r) Moon distance (A.A. p. 338)
    def moon_heliocentric_distance
      result = PERIODIC_TERMS_MOON_LONGITUDE_DISTANCE.inject(0.0) do |acc, elem|
        cosine_argument = (
          elem["moon_mean_elongation"] * moon_mean_elongation +
          elem["sun_mean_anomaly"] * sun_mean_anomaly +
          elem["moon_mean_anomaly"] * moon_mean_anomaly +
          elem["moon_argument_of_latitude"] * moon_argument_of_latitude
        ) % 360

        if elem["cosine_coefficient"].nil?
          next acc
        elsif [1, -1].include?(elem["sun_mean_anomaly"])
          acc + elem["cosine_coefficient"] * earth_eccentricity_correction * Math.cos(cosine_argument * Math::PI / 180)
        elsif [-2, 2].include?(elem["sun_mean_anomaly"])
          acc + elem["cosine_coefficient"] * earth_eccentricity_correction**2 * Math.cos(cosine_argument * Math::PI / 180)
        else
          acc + elem["cosine_coefficient"] * Math.cos(cosine_argument * Math::PI / 180)
        end
      end
      result.round
    end
  end
end
