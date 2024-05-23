RSpec.describe Lunation::Calculation do
  let(:calculation) { described_class.new }

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
end
