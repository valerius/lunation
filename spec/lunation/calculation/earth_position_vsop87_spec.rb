RSpec.describe "Position of the earth calculated using the abridged VSOP87 theory" do
  before { allow(calculation).to receive(:time).and_return(time) }

  let(:calculation) { Lunation::Calculation.new(datetime) }
  let(:datetime) { DateTime.new(1992, 10, 13, 0, 0, 0, "+00:00") }
  let(:time) { -0.072183436 } # 1992-10-13 0h TD

  specify "julian_ephemeris_day" do
    expect(calculation.julian_ephemeris_day.to_f.round(1)).to eq(2_448_908.5)
  end

  specify "calculate_earth_ecliptical_longitude_vsop87" do
    expect(calculation.calculate_earth_ecliptical_longitude_vsop87.decimal_degrees.round(6))
      .to eq(19.907372)
  end

  specify "calculate_earth_ecliptical_latitude_vsop87" do
    expect(calculation.calculate_earth_ecliptical_latitude_vsop87.decimal_degrees.round(6))
      .to eq(-0.000179)
  end

  specify "calculate_radius_vector_vsop87" do
    expect(calculation.calculate_radius_vector_vsop87.round(8)).to eq(0.99760775)
  end
end
