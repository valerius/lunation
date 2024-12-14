RSpec.describe "Timekeeping" do
  let(:calculation) { Lunation::Calculation.new(datetime) }
  let(:datetime) { DateTime.new(1987, 4, 10, 0, 0, 0, "+00:00") }

  it { expect(calculation).to respond_to(:datetime) }
  it { expect(calculation).to respond_to(:julian_ephemeris_day) }

  describe "time" do
    subject(:time) { calculation.time }

    before do
      allow(calculation).to receive(:julian_ephemeris_day).and_return(2_446_895.5)
    end

    it { expect(time).to eq(-0.127296372348) }
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

  describe "julian_myriads_since_j2000" do
    subject(:julian_myriads_since_j2000) { calculation.julian_myriads_since_j2000 }

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.127296372348 } # 1987-04-10 0h TD, example 22.a A.A. p. 148

    it { expect(julian_myriads_since_j2000).to eq(-0.00127296372348) } # (U)
  end
end
