RSpec.describe Lunation::Calculation do
  let(:calculation) { described_class.new(datetime) }
  let(:datetime) { DateTime.new(1987, 4, 10, 0, 0, 0, "+00:00") }

  it { expect(calculation).to respond_to(:datetime) }
  it { expect(calculation).to respond_to(:julian_ephemeris_day) }

  describe "moon_illuminated_fraction" do
    subject(:moon_illuminated_fraction) { calculation.moon_illuminated_fraction }

    before do
      allow(calculation).to receive(:moon_phase_angle).and_return(moon_phase_angle)
    end

    let(:moon_phase_angle) { 69.0756 } # example 48.a (A.A. p. 347)

    it "returns the correct value" do
      expect(moon_illuminated_fraction).to eq(0.6786)
    end
  end

  describe "moon_phase_angle" do
    subject(:moon_phase_angle) { calculation.moon_phase_angle }

    before do
      allow(calculation).to receive_messages(
        earth_sun_distance_in_km: earth_sun_distance_in_km,
        earth_moon_distance: earth_moon_distance,
        moon_geocentric_elongation: moon_geocentric_elongation
      )
    end

    let(:earth_sun_distance_in_km) { 149_971_520 } # R
    let(:earth_moon_distance) { 368_410 } # Delta
    let(:moon_geocentric_elongation) { 110.7929 } # Psi

    it "returns the correct value" do
      expect(moon_phase_angle.round(4)).to eq(69.0756) # example 48.a (A.A. p. 347)
    end
  end

  describe "earth_sun_distance" do
    subject(:earth_sun_distance) { calculation.earth_sun_distance }

    before do
      allow(calculation).to receive_messages(
        earth_eccentricity: earth_eccentricity,
        sun_true_anomaly: sun_true_anomaly
      )
    end

    # 1992-10-13 at 0 TD
    let(:earth_eccentricity) { 0.016711668 } # (e) A.A. p. 165
    let(:sun_true_anomaly) { 278.99397 - 1.89732 } # (v = M + C) A.A. p. 165

    it { expect(earth_sun_distance.round(5)).to eq(0.99766) } # (R) A.A. p. 165
  end

  describe "earth_sun_distance_in_km" do
    subject(:earth_sun_distance_in_km) { calculation.earth_sun_distance_in_km }

    before do
      allow(calculation).to receive_messages(
        earth_sun_distance: earth_sun_distance
      )
    end

    let(:earth_sun_distance) { 1.0024977 } # example 48.a, A.A. p. 347

    it { expect(earth_sun_distance_in_km).to eq(149_971_520) }
  end

  describe "earth_eccentricity" do
    subject(:earth_eccentricity) { calculation.earth_eccentricity }

    before { allow(calculation).to receive_messages(time: time) }

    let(:time) { -0.072183436 } # 1992-10-13 at 0 TD

    it { expect(earth_eccentricity).to eq(0.016711668) } # example 25.a, A.A. p. 165
  end

  describe "earth_eccentricity_correction" do
    subject(:earth_eccentricity_correction) { calculation.earth_eccentricity_correction }

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.077221081451 } # 1992-04-12 0h TD

    # example 47.a (A.A. p. 342)
    it { expect(earth_eccentricity_correction).to eq(1.000194) }
  end

  describe "time" do
    subject(:time) { calculation.time }

    before do
      allow(calculation).to receive(:julian_ephemeris_day).and_return(2_446_895.5)
    end

    it { expect(time).to eq(-0.127296372348) }
  end

  # Reference values for these tests have been taken from: https://eclipse.gsfc.nasa.gov/SEcat5/deltat.html
  # Date of consulation: 2024-05-19
  describe "delta_t" do
    subject(:delta_t) { calculation.delta_t }

    context "when 500 B.C." do
      let(:datetime) { Date.new(-500, 1, 1) }

      it { expect(delta_t).to eq(17_202.9) } # reference value: 17_203.7
    end

    context "when 400 B.C." do
      let(:datetime) { Date.new(-400, 1, 1) }

      it { expect(delta_t).to eq(15_530.3) } # reference value: 15_530.0
    end

    context "when 300 B.C." do
      let(:datetime) { Date.new(-300, 1, 1) }

      it { expect(delta_t).to eq(14_077.6) } # reference value: 14_080.0
    end

    context "when 200 B.C." do
      let(:datetime) { Date.new(-200, 1, 1) }

      it { expect(delta_t).to eq(12_791.7) } # reference value: 12_790.0
    end

    context "when 100 B.C." do
      let(:datetime) { Date.new(-100, 1, 1) }

      it { expect(delta_t).to eq(11_637.1) } # reference value: 11_640.0
    end

    context "when 0 A.D." do
      let(:datetime) { Date.new(0, 1, 1) }

      it { expect(delta_t).to eq(10_583.2) } # reference value: 10_580.0
    end

    context "when 100 A.D." do
      let(:datetime) { Date.new(100, 1, 1) }

      it { expect(delta_t).to eq(9_596.5) } # reference value: 9_600.0
    end

    context "when 200 A.D." do
      let(:datetime) { Date.new(200, 1, 1) }

      it { expect(delta_t).to eq(8_640.3) } # reference value: 8_640.0
    end

    context "when 300 A.D." do
      let(:datetime) { Date.new(300, 1, 1) }

      it { expect(delta_t).to eq(7_680.7) } # reference value: 7_680.0
    end

    context "when 400 A.D." do
      let(:datetime) { Date.new(400, 1, 1) }

      it { expect(delta_t).to eq(6_698.8) } # reference value: 6_700.0
    end

    context "when 500 A.D." do
      let(:datetime) { Date.new(500, 1, 1) }

      it { expect(delta_t).to eq(5_709.6) } # reference value: 5_710.0
    end

    context "when 600 A.D." do
      let(:datetime) { Date.new(600, 1, 1) }

      it { expect(delta_t).to eq(4_738.8) } # reference value: 4740.0
    end

    context "when 700 A.D." do
      let(:datetime) { Date.new(700, 1, 1) }

      it { expect(delta_t).to eq(3_812.8) } # reference value: 3810.0
    end

    context "when 800 A.D." do
      let(:datetime) { Date.new(800, 1, 1) }

      it { expect(delta_t).to eq(2955.4) } # reference value: 2960.0
    end

    context "when 900 A.D." do
      let(:datetime) { Date.new(900, 1, 1) }

      it { expect(delta_t).to eq(2200.0) } # reference value: 2200.0
    end

    context "when 1000 A.D." do
      let(:datetime) { Date.new(1000, 1, 1) }

      it { expect(delta_t).to eq(1574.0) } # reference value: 1570.0
    end

    context "when 1100 A.D." do
      let(:datetime) { Date.new(1100, 1, 1) }

      it { expect(delta_t).to eq(1088.7) } # reference value: 1090.0
    end

    context "when 1200 A.D." do
      let(:datetime) { Date.new(1200, 1, 1) }

      it { expect(delta_t).to eq(736.3) } # reference value: 740.0
    end

    context "when 1300 A.D." do
      let(:datetime) { Date.new(1300, 1, 1) }

      it { expect(delta_t).to eq(491.8) } # reference value: 490.0
    end

    context "when 1400 A.D." do
      let(:datetime) { Date.new(1400, 1, 1) }

      it { expect(delta_t).to eq(321.7) } # reference value: 320.0
    end

    context "when 1500 A.D." do
      let(:datetime) { Date.new(1500, 1, 1) }

      it { expect(delta_t).to eq(198.3) } # reference value: 200.0
    end

    context "when 1600 A.D." do
      let(:datetime) { Date.new(1_600, 1, 1) }

      it { expect(delta_t).to eq(120.0) } # reference value: 120.0
    end

    context "when 1700 A.D." do
      let(:datetime) { Date.new(1_700, 1, 1) }

      it { expect(delta_t).to eq(8.8) } # reference value: 9.0
    end

    context "when 1750 A.D." do
      let(:datetime) { Date.new(1_750, 1, 1) }

      it { expect(delta_t).to eq(13.4) } # reference value: 13.0
    end

    context "when 1800 A.D." do
      let(:datetime) { Date.new(1_800, 1, 1) }

      it { expect(delta_t).to eq(13.7) } # reference value: 14.0
    end

    context "when 1850 A.D." do
      let(:datetime) { Date.new(1_850, 1, 1) }

      it { expect(delta_t).to eq(7.1) } # reference value: 7.0
    end

    context "when 1900 A.D." do
      let(:datetime) { Date.new(1_900, 1, 1) }

      it { expect(delta_t).to eq(-2.7) } # reference value: -3.0
    end

    context "when 1950 A.D." do
      let(:datetime) { Date.new(1_950, 1, 1) }

      it { expect(delta_t).to eq(29.1) } # reference value: 29.0
    end

    context "when year 1955 A.D." do
      let(:datetime) { Date.new(1_955, 1, 1) }

      it { expect(delta_t).to eq(31.1) } # reference value: 31.1
    end

    context "when year 1960 A.D." do
      let(:datetime) { Date.new(1_960, 1, 1) }

      it { expect(delta_t).to eq(33.1) } # reference value: 33.2
    end

    context "when year 1965 A.D." do
      let(:datetime) { Date.new(1_965, 1, 1) }

      it { expect(delta_t).to eq(35.8) } # reference value: 35.7
    end

    context "when year 1970 A.D." do
      let(:datetime) { Date.new(1_970, 1, 1) }

      it { expect(delta_t).to eq(40.2) } # reference value: 40.2
    end

    context "when year 1975 A.D." do
      let(:datetime) { Date.new(1_975, 1, 1) }

      it { expect(delta_t).to eq(45.5) } # reference value: 45.5
    end

    context "when year 1980 A.D." do
      let(:datetime) { Date.new(1_980, 1, 1) }

      it { expect(delta_t).to eq(50.6) } # reference value: 50.5
    end

    context "when year 1985 A.D." do
      let(:datetime) { Date.new(1_985, 1, 1) }

      it { expect(delta_t).to eq(54.4) } # reference value: 54.3
    end

    context "when year 1990 A.D." do
      let(:datetime) { Date.new(1_990, 1, 1) }

      it { expect(delta_t).to eq(56.9) } # reference value: 56.9
    end

    context "when year 1995 A.D." do
      let(:datetime) { Date.new(1_995, 1, 1) }

      it { expect(delta_t).to eq(60.8) } # reference value: 60.8
    end

    context "when year 2000 A.D." do
      let(:datetime) { Date.new(2_000, 1, 1) }

      it { expect(delta_t).to eq(63.9) } # reference value: 63.8
    end

    context "when year 2005 A.D." do
      let(:datetime) { Date.new(2_005, 1, 1) }

      it { expect(delta_t).to eq(64.7) } # reference value: 64.7
    end
  end

  describe "dynamical_time" do
    subject(:dynamical_time) { calculation.dynamical_time }

    context "when delta_t is positive" do
      let(:datetime) { DateTime.new(2_005, 1, 1, 0, 0, 0) }

      it "adds delta_t to the datetime" do
        expect(dynamical_time).to eql(DateTime.new(2_005, 1, 1, 0, 1, 5))
      end
    end

    context "when delta_t is positive" do
      let(:datetime) { Date.new(1_900, 1, 1) }

      it "subtracts delta_t from the datetime" do
        expect(dynamical_time).to eql(DateTime.new(1_899, 12, 31, 23, 59, 57))
      end
    end
  end

  describe "julian_ephemeris_day" do
    subject(:julian_ephemeris_day) { calculation.julian_ephemeris_day }

    let(:datetime) { DateTime.new(1992, 12, 16, 0, 0, 0) }

    # The JDE value is taken from example 43.b (A.A. p. 299)
    #   delta_t is calculated using using a more precise formula than in A.A.
    #   source: https://eclipse.gsfc.nasa.gov/SEhelp/deltatpoly2004.html
    it { expect(julian_ephemeris_day).to eq(2_448_972.50068) }
  end

  describe "sun_true_anomaly" do
    subject(:sun_true_anomaly) { calculation.sun_true_anomaly }

    before do
      allow(calculation).to receive_messages(
        sun_mean_anomaly: sun_mean_anomaly,
        sun_equation_center: sun_equation_center
      )
    end

    # example 25.a A.A. p. 165
    let(:sun_mean_anomaly) { 278.99397 } # (M)
    let(:sun_equation_center) { -1.89732 } # (C)

    it { expect(sun_true_anomaly).to eq(277.09665) }
  end

  describe "sun_mean_anomaly" do
    subject(:sun_mean_anomaly) { calculation.sun_mean_anomaly }

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.072183436 } # 1992-10-13 0h TD

    it { expect(sun_mean_anomaly.round(5)).to eq(278.99397) } # example 25.a (A.A. p. 165)
  end

  describe "sun_mean_anomaly2" do
    subject(:sun_mean_anomaly2) { calculation.sun_mean_anomaly2 }

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.127296372348 } # 1987-04-10 0h TD

    # example 22.a (A.A. p. 148)
    it { expect(sun_mean_anomaly2.round(5)).to eq(94.9792) }
  end

  describe "sun_equation_center" do
    subject(:sun_equation_center) { calculation.sun_equation_center }

    before do
      allow(calculation).to receive_messages(
        sun_mean_anomaly: sun_mean_anomaly,
        time: time
      )
    end

    # example 25.a A.A. p. 165
    let(:time) { -0.072183436 } # (T) 1992-10-13 0h TD
    let(:sun_mean_anomaly) { 278.99397 } # (M)

    it { expect(sun_equation_center).to eq(-1.89732) }
  end

  describe "moon_geocentric_elongation" do
    subject(:moon_geocentric_elongation) { calculation.moon_geocentric_elongation }

    before do
      allow(calculation).to receive_messages(
        sun_geocentric_right_ascension: sun_geocentric_right_ascension,
        sun_geocentric_declination: sun_geocentric_declination,
        moon_geocentric_right_ascension: moon_geocentric_right_ascension,
        moon_geocentric_declination: moon_geocentric_declination
      )
    end

    # example 48.a A.A. p. 347
    let(:sun_geocentric_right_ascension) { 20.6579 } # (alpha zero)
    let(:sun_geocentric_declination) { 8.6964 } # (delta zero)
    let(:moon_geocentric_right_ascension) { 134.6885 } # (alpha)
    let(:moon_geocentric_declination) { 13.7684 } # delta

    it { expect(moon_geocentric_elongation).to eq(110.7929) } # psi
  end

  describe "sun_geocentric_declination" do
    subject(:sun_geocentric_declination) { calculation.sun_geocentric_declination }

    before do
      allow(calculation).to receive_messages(
        corrected_ecliptic_true_obliquity: corrected_ecliptic_true_obliquity,
        sun_ecliptical_longitude: sun_ecliptical_longitude
      )
    end

    # example 25.b A.A. p. 169
    let(:corrected_ecliptic_true_obliquity) { 23.43999 } # true epsilon
    let(:sun_ecliptical_longitude) { 199.90895 } # lambda

    it { expect(sun_geocentric_declination).to eq(-7.78507) }
  end

  describe "earth_moon_distance" do
    subject(:earth_moon_distance) { calculation.earth_moon_distance }

    before do
      allow(calculation).to receive_messages(
        moon_heliocentric_distance: moon_heliocentric_distance
      )
    end

    # example 47.a A.A. p. 343
    let(:moon_heliocentric_distance) { -16_590_875 } # Sigma r

    it { expect(earth_moon_distance).to eq(368_409.7) }
  end

  describe "time_julian_millennia" do
    subject(:time_julian_millennia) { calculation.time_julian_millennia }

    before do
      allow(calculation).to receive_messages(julian_ephemeris_day: julian_ephemeris_day)
    end

    let(:julian_ephemeris_day) { 2_448_976.5 } # example 32.a A.A. p. 219

    # 1992-12-20 0h TD
    it { expect(time_julian_millennia).to eq(-0.007032169747) }
  end

  describe "moon_mean_longitude" do
    subject(:moon_mean_longitude) { calculation.moon_mean_longitude }

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.077221081451 } # 1992-04-12 0h TD

    it { expect(moon_mean_longitude).to eq(134.290182) } # A.A. p. 342
  end

  describe "moon_mean_elongation" do
    subject(:moon_mean_elongation) { calculation.moon_mean_elongation }

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.077221081451 } # 1992-04-12 0h TD

    it { expect(moon_mean_elongation).to eq(113.842304) }
  end

  describe "moon_mean_anomaly" do
    subject(:moon_mean_anomaly) { calculation.moon_mean_anomaly }

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.077221081451 } # 1992-04-12 0h TD

    it { expect(moon_mean_anomaly).to eq(5.150833) }
  end

  describe "moon_mean_anomaly2" do
    subject(:moon_mean_anomaly2) { calculation.moon_mean_anomaly2 }

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.127296372348 } # 1987-04-10 0h TD

    it { expect(moon_mean_anomaly2).to eq(229.2784) } # example 22.a, A.A. p. 148
  end

  describe "moon_argument_of_latitude" do
    subject(:moon_argument_of_latitude) { calculation.moon_argument_of_latitude }

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.077221081451 } # 1992-04-12 0h TD

    it { expect(moon_argument_of_latitude).to eq(219.889721) }
  end

  describe "moon_argument_of_latitude2" do
    subject(:moon_argument_of_latitude2) { calculation.moon_argument_of_latitude2 }

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.127296372348 } # 1987-04-10 0h TD

    it { expect(moon_argument_of_latitude2).to eq(143.4079) } # example 22.a, A.A. p. 148
  end

  describe "correction_venus" do
    subject(:correction_venus) { calculation.correction_venus }

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.077221081451 } # 1992-04-12 0h TD

    it { expect(correction_venus).to eq(109.57) } # example 47.a (A.A. p. 342)
  end

  describe "correction_jupiter" do
    subject(:correction_jupiter) { calculation.correction_jupiter }

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.077221081451 } # 1992-04-12 0h TD

    it { expect(correction_jupiter).to eq(123.78) }
  end

  describe "correction_latitude" do
    subject(:correction_latitude) { calculation.correction_latitude }

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.077221081451 } # 1992-04-12 0h TD

    it { expect(correction_latitude).to eq(229.53) } # example 47.a (A.A. p. 342)
  end

  describe "moon_heliocentric_longitude" do
    subject(:moon_heliocentric_longitude) { calculation.moon_heliocentric_longitude }

    before do
      allow(calculation).to receive_messages(
        correction_jupiter: correction_jupiter,
        correction_venus: correction_venus,
        earth_eccentricity_correction: earth_eccentricity_correction,
        moon_argument_of_latitude: moon_argument_of_latitude,
        moon_mean_anomaly: moon_mean_anomaly,
        moon_mean_elongation: moon_mean_elongation,
        moon_mean_longitude: moon_mean_longitude,
        sun_mean_anomaly: sun_mean_anomaly
      )
    end

    # example 47.a A.A. p. 342
    let(:correction_jupiter) { 123.78 } # (A2)
    let(:correction_venus) { 109.57 } # (A1)
    let(:earth_eccentricity_correction) { 1.000194 } # (E)
    let(:moon_argument_of_latitude) { 219.889721 } # (F)
    let(:moon_mean_anomaly) { 5.150833 } # (M')
    let(:moon_mean_elongation) { 113.842304 } # (D)
    let(:moon_mean_longitude) { 134.290182 } # (L')
    let(:sun_mean_anomaly) { 97.643514 } # (M)

    it { expect(moon_heliocentric_longitude).to eq(-1_127_527) }
  end

  describe "moon_heliocentric_distance" do
    subject(:moon_heliocentric_distance) { calculation.moon_heliocentric_distance }

    before do
      allow(calculation).to receive_messages(
        earth_eccentricity_correction: earth_eccentricity_correction,
        moon_argument_of_latitude: moon_argument_of_latitude,
        moon_mean_anomaly: moon_mean_anomaly,
        moon_mean_elongation: moon_mean_elongation,
        sun_mean_anomaly: sun_mean_anomaly
      )
    end

    # example 47.a A.A. p. 342
    let(:earth_eccentricity_correction) { 1.000194 } # (E)
    let(:moon_argument_of_latitude) { 219.889721 } # (F)
    let(:moon_mean_anomaly) { 5.15083 } # (M')
    let(:moon_mean_elongation) { 113.842304 } # (D)
    let(:sun_mean_anomaly) { 97.643514 } # (M)

    it { expect(moon_heliocentric_distance).to eq(-16_590_875) }
  end

  describe "moon_heliocentric_latitude" do
    subject(:moon_heliocentric_latitude) { calculation.moon_heliocentric_latitude }

    before do
      allow(calculation).to receive_messages(
        correction_latitude: correction_latitude,
        correction_venus: correction_venus,
        earth_eccentricity_correction: earth_eccentricity_correction,
        moon_argument_of_latitude: moon_argument_of_latitude,
        moon_mean_anomaly: moon_mean_anomaly,
        moon_mean_elongation: moon_mean_elongation,
        moon_mean_longitude: moon_mean_longitude,
        sun_mean_anomaly: sun_mean_anomaly
      )
    end

    let(:correction_latitude) { 229.53 } # (A3)
    let(:correction_venus) { 109.57 } # (A1)
    let(:earth_eccentricity_correction) { 1.000194 } # (E)
    let(:moon_argument_of_latitude) { 219.889721 } # (F)
    let(:moon_mean_anomaly) { 5.150833 } # (M')
    let(:moon_mean_elongation) { 113.842304 } # (D)
    let(:moon_mean_longitude) { 134.290182 } # (L')
    let(:sun_mean_anomaly) { 97.643514 } # (M)

    it { expect(moon_heliocentric_latitude).to eq(-3_229_126) }
  end

  describe "moon_geocentric_longitude" do
    subject(:moon_geocentric_longitude) { calculation.moon_geocentric_longitude }

    before do
      allow(calculation).to receive_messages(
        moon_heliocentric_longitude: moon_heliocentric_longitude,
        moon_mean_longitude: moon_mean_longitude
      )
    end

    let(:moon_heliocentric_longitude) { -1_127_527 } # (Sigma l)
    let(:moon_mean_longitude) { 134.290182 } # (L')

    it { expect(moon_geocentric_longitude).to eq(133.162655) }
  end

  describe "moon_ecliptic_latitude" do
    subject(:moon_ecliptic_latitude) { calculation.moon_ecliptic_latitude }

    before do
      allow(calculation).to receive(:moon_heliocentric_latitude).and_return(moon_heliocentric_latitude)
    end

    let(:moon_heliocentric_latitude) { -3_229_126 } # (Sigma b)

    it { expect(moon_ecliptic_latitude).to eq(-3.229126) }
  end

  describe "equitorial_horizontal_parallax" do
    subject(:equitorial_horizontal_parallax) do
      calculation.equitorial_horizontal_parallax
    end

    before do
      allow(calculation).to receive_messages(
        earth_moon_distance: earth_moon_distance
      )
    end

    let(:earth_moon_distance) { 368_409.7 } # (Sigma r) example 47.a, A.A. p. 342

    it { expect(equitorial_horizontal_parallax).to eq(0.991990) } # A.A. p. 343
  end

  describe "earth_nutation_in_longitude" do
    subject(:earth_nutation_in_longitude) { calculation.earth_nutation_in_longitude }

    before do
      allow(calculation).to receive_messages(
        time: time,
        moon_mean_elongation: moon_mean_elongation,
        sun_mean_anomaly: sun_mean_anomaly,
        moon_mean_anomaly: moon_mean_anomaly,
        moon_argument_of_latitude: moon_argument_of_latitude,
        moon_orbital_longitude_mean_ascending_node: moon_orbital_longitude_mean_ascending_node
      )
    end

    let(:time) { -0.127296372348 } # T, 1987-04-10
    let(:moon_mean_elongation) { 136.9623 } # D
    let(:sun_mean_anomaly) { 94.9792 } # M
    let(:moon_mean_anomaly) { 229.2784 } # M'
    let(:moon_argument_of_latitude) { 143.4079 } # F
    let(:moon_orbital_longitude_mean_ascending_node) { 11.2531 } # Omega

    it { expect(earth_nutation_in_longitude).to eq(-3.788) }
  end

  describe "moon_ecliptic_longitude" do
    subject(:moon_ecliptic_longitude) { calculation.moon_ecliptic_longitude }

    before do
      allow(calculation).to receive_messages(
        moon_geocentric_longitude: moon_geocentric_longitude,
        earth_nutation_in_longitude: earth_nutation_in_longitude
      )
    end

    # example 47.a A.A. p. 343
    let(:moon_geocentric_longitude) { 133.162655 } # (lambda)
    let(:earth_nutation_in_longitude) { 16.595 } # (Delta psi)

    it { expect(moon_ecliptic_longitude).to eq(133.167265) } # A.A. p. 343
  end

  describe "nutation_in_obliquity" do
    subject(:nutation_in_obliquity) { calculation.nutation_in_obliquity }

    before do
      allow(calculation).to receive_messages(
        time: time,
        moon_mean_elongation: moon_mean_elongation,
        sun_mean_anomaly: sun_mean_anomaly,
        moon_mean_anomaly: moon_mean_anomaly,
        moon_argument_of_latitude: moon_argument_of_latitude,
        moon_orbital_longitude_mean_ascending_node: moon_orbital_longitude_mean_ascending_node
      )
    end

    # example 22.a A.A. p. 148
    let(:time) { -0.127296372348 } # 1987-04-10 0h TD
    let(:moon_mean_elongation) { 136.9623 } # (D) A.A. p. 148
    let(:sun_mean_anomaly) { 94.9792 } # (M) A.A. p. 148
    let(:moon_mean_anomaly) { 229.2784 } # (M') A.A. p. 148
    let(:moon_argument_of_latitude) { 143.4079 } # (F) A.A. p. 148
    let(:moon_orbital_longitude_mean_ascending_node) { 11.2531 } # (Omega) A.A. p. 148

    it { expect(nutation_in_obliquity).to eq(9.443) }
  end

  describe "julian_myriads_since_j2000" do
    subject(:julian_myriads_since_j2000) { calculation.julian_myriads_since_j2000 }

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.127296372348 } # 1987-04-10 0h TD, example 22.a A.A. p. 148

    it { expect(julian_myriads_since_j2000).to eq(-0.00127296372348) } # (U)
  end

  describe "ecliptic_mean_obliquity" do
    subject(:ecliptic_mean_obliquity) { calculation.ecliptic_mean_obliquity }

    before do
      allow(calculation).to receive_messages(
        julian_myriads_since_j2000: julian_myriads_since_j2000
      )
    end

    # example 22.a A.A. p. 148
    let(:julian_myriads_since_j2000) { -0.00127296372348 } # (U)

    # converted from 23deg 26'27''.407
    it { expect(ecliptic_mean_obliquity).to eq(23.440946) } # (epsilon 0)
  end

  describe "ecliptic_true_obliquity" do
    subject(:ecliptic_true_obliquity) { calculation.ecliptic_true_obliquity }

    before do
      allow(calculation).to receive_messages(
        ecliptic_mean_obliquity: ecliptic_mean_obliquity,
        nutation_in_obliquity: nutation_in_obliquity
      )
    end

    let(:ecliptic_mean_obliquity) { 23.440946 } # (ε0)
    let(:nutation_in_obliquity) { 9.443 } # (Δε)

    # converted from 23deg26'36".850 (example 22.a A.A. p. 148)
    it { expect(ecliptic_true_obliquity).to eq(23.443569) }
  end

  describe "moon_geocentric_right_ascension" do
    subject(:moon_geocentric_right_ascension) do
      calculation.moon_geocentric_right_ascension
    end

    before do
      allow(calculation).to receive_messages(
        moon_ecliptic_longitude: moon_ecliptic_longitude,
        ecliptic_true_obliquity: ecliptic_true_obliquity,
        moon_ecliptic_latitude: moon_ecliptic_latitude
      )
    end

    context "when example 13.a (A.A. p. 95)" do
      let(:moon_ecliptic_longitude) { 113.215630 } # λ
      let(:ecliptic_true_obliquity) { 23.4392911 } # ε
      let(:moon_ecliptic_latitude) { 6.684170 } # β

      # reference value is 116.328943
      it { expect(moon_geocentric_right_ascension).to eq(116.328943) }
    end

    context "when example 47.a (A.A. p. 343)" do
      let(:moon_ecliptic_longitude) { 133.167265 } # apparent λ
      let(:ecliptic_true_obliquity) { 23.440636 } # ε
      let(:moon_ecliptic_latitude) { -3.229126 } # β

      it { expect(moon_geocentric_right_ascension).to eq(134.688470) }
    end
  end

  describe "moon_geocentric_declination" do
    subject(:moon_geocentric_declination) { calculation.moon_geocentric_declination }

    before do
      allow(calculation).to receive_messages(
        moon_ecliptic_longitude: moon_ecliptic_longitude,
        ecliptic_true_obliquity: ecliptic_true_obliquity,
        moon_ecliptic_latitude: moon_ecliptic_latitude
      )
    end

    let(:moon_ecliptic_longitude) { 133.167265 } # apparent λ
    let(:ecliptic_true_obliquity) { 23.440636 } # ε
    let(:moon_ecliptic_latitude) { -3.229126 } # β

    it { expect(moon_geocentric_declination).to eq(13.768368) }
  end

  describe "earth_ecliptical_longitude" do
    subject(:earth_ecliptical_longitude) { calculation.earth_ecliptical_longitude }

    before do
      allow(calculation).to receive_messages(julian_ephemeris_day: julian_ephemeris_day)
    end

    let(:julian_ephemeris_day) { 2_448_908.5 } # 1992-10-13 0h TD

    # example 25.b A.A. p. 169
    it { expect(earth_ecliptical_longitude).to eq(-43.63484796) }
  end

  # describe "earth_radius_vector" do
  #   subject(:earth_radius_vector) { calculation.earth_radius_vector }

  #   before do
  #     allow(calculation).to receive_messages(julian_ephemeris_day: julian_ephemeris_day)
  #   end

  #   let(:julian_ephemeris_day) { 2_448_908.5 } # 1992-10-13 0h TD

  #   # example 25.b A.A. p. 169
  #   it { expect(earth_radius_vector.round(8)).to eq(0.99760775) }
  # end
end
