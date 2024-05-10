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
end
