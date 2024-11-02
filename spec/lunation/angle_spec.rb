RSpec.describe Lunation::Angle do
  let(:angle) { described_class.from_radians(Math::PI) }

  it { expect(angle).to respond_to(:radians) }
  it { expect(angle).to respond_to(:decimal_arcseconds) }
  it { expect(angle).to respond_to(:arcminutes) }
  it { expect(angle).to respond_to(:degrees) }
  it { expect(angle).to respond_to(:decimal_degrees) }

  # examples taken from example 25.b, A.A. p. 169
  describe "from_radians" do
    it "converts to decimal degrees" do
      expect(
        described_class.from_radians(-43.63484796, normalize: false)
          .decimal_degrees
          .round(6)
      ).to eq(-2500.092628)
    end

    it "converts to normalized decimal degrees" do
      expect(described_class.from_radians(-43.63484796).decimal_degrees.round(6))
        .to eq(19.907372)
    end

    it "converts to decimal_degrees (small angle)" do
      expect(
        described_class.from_radians(-0.00000312, normalize: false)
          .decimal_degrees
          .round(6)
      ).to eq(-0.000179)
    end

    it "converts to decimal_arcseconds" do
      expect(
        described_class.from_radians(-0.00000312, normalize: false)
          .decimal_arcseconds
          .round(3)
      ).to eq(-0.644)
    end

    # A.A. p. 156 (alpha)
    it "converts small values to decimal degrees" do
      angle = described_class.from_radians(0.000145252)
      expect(angle.decimal_degrees.round(7)).to eq(0.0083223)
      expect(angle.radians).to eq(0.000145252) # it does not round the radians
    end

    # A.A. p. 156 (delta)
    it "converts small values to decimal degrees" do
      angle = described_class.from_radians(0.000032723)
      expect(angle.decimal_degrees.round(7)).to eq(0.0018749)
      expect(angle.radians).to eq(0.000032723) # it does not round the radians
    end

    # A.A. p. 169
    it "converts radians correctly when not normalizing" do
      angle = described_class.from_radians(-0.00000312, normalize: false)
      expect(angle.decimal_degrees.round(6)).to eq(-0.000179)
      expect(angle.decimal_arcseconds.round(3)).to eq(-0.644)
    end
  end

  describe "from_decimal_degrees" do
    it "converts decimal degrees to degrees/arcminutes/decimal_arcseconds" do
      angle = described_class.from_decimal_degrees(199.907347)
      expect(angle.degrees).to eq(199)
      expect(angle.arcminutes).to eq(54)
      expect(angle.decimal_arcseconds.round(3)).to eq(26.449)
    end

    it "converts decimal degrees to hours/minutes/decimal_seconds" do
      angle = described_class.from_decimal_degrees(198.378178)
      expect(angle.hours).to eq(13)
      expect(angle.minutes).to eq(13)
      expect(angle.decimal_seconds.round(3)).to eq(30.763)
    end

    it "normalizes the angle by default" do
      angle = described_class.from_decimal_degrees(13_774_269.8622) # A.A. p. 296
      expect(angle.decimal_degrees.round(4)).to eq(309.8622)
    end

    it "converts decimal degrees to radians" do
      angle = described_class.from_decimal_degrees(27.724274) # A.A. p. 85
      expect(angle.radians.round(8)).to eq(0.48387986) # value in example is 0.48387987
    end
  end

  describe "from_degrees" do
    # A.A. p. 343
    it "converts degrees/arcminutes/decimal_arcseconds to decimal_degrees" do
      angle = described_class.from_degrees(
        degrees: 23,
        arcminutes: 26,
        decimal_arcseconds: 26.29
      )
      expect(angle.decimal_degrees.round(6)).to eq(23.440636)
    end

    # A.A. p. 156
    it "converts degrees/arcminutes/decimal_arcseconds to decimal_degrees" do
      angle = described_class.from_degrees(
        degrees: 49,
        arcminutes: 13,
        decimal_arcseconds: 39.896
      )
      expect(angle.decimal_degrees.round(7)).to eq(49.2277489)
    end
  end

  describe "from_hours_minutes_decimal_seconds" do
    it "convers hours/minutes/decimal_seconds to decimal_degrees" do
      angle = described_class.from_hours_minutes_decimal_seconds(
        hours: 2,
        minutes: 44,
        decimal_seconds: 12.9747
      )
      expect(angle.decimal_degrees.round(7)).to eq(41.0540613)
    end
  end

  describe "from_decimal_arcseconds" do
    # A.A. p. 157 (Delta alpha)
    it "converts decimal_arcseconds into decimal_degrees" do
      angle = described_class.from_decimal_arcseconds(15.844)
      expect(angle.decimal_degrees.round(7)).to eq(0.0044011)
    end

    # A.A. p. 157 (Delta delta)
    it "converts decimal_arcseconds into decimal_degrees" do
      angle = described_class.from_decimal_arcseconds(6.217)
      expect(angle.decimal_degrees.round(7)).to eq(0.0017269) # value in A.A. is 0.0017270
    end

    # A.A. p. 169
    it "converts decimal_arcseconds into decimal_degrees when not normalizing" do
      angle = described_class.from_decimal_arcseconds(-0.09033, normalize: false)
      expect(angle.decimal_degrees.round(6)).to eq(-0.000025)
    end

    # A.A. p. 176 (zeta)
    it "converts decimal_arcseconds into decimal_degrees" do
      angle = described_class.from_decimal_arcseconds(1014.7959)
      expect(angle.decimal_degrees.round(7)).to eq(0.2818878)
    end

    # A.A. p. 176 (z)
    it "converts decimal_arcseconds into decimal_degrees" do
      angle = described_class.from_decimal_arcseconds(1014.9494)
      expect(angle.decimal_degrees.round(7)).to eq(0.2819304)
    end

    # A.A. p. 176 (theta)
    it "converts decimal_arcseconds into decimal_degrees" do
      angle = described_class.from_decimal_arcseconds(881.8106)
      expect(angle.decimal_degrees.round(7)).to eq(0.2449474)
    end
  end
end
