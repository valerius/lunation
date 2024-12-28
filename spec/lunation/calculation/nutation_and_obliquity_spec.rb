RSpec.describe "Nutation and obliquity" do
  # This spec tests the values described in example 22.a (A.A. p. 148)

  before { allow(calculation).to receive(:dynamical_time).and_return(dynamical_time) }

  # datetime does not matter here, we are taking dynamical time as a starting point
  let(:calculation) { Lunation::Calculation.new(DateTime.now) }
  let(:dynamical_time) { DateTime.new(1987, 4, 10, 0, 0, 0, "+00:00") }

  specify "it calculates julian_ephemeris_day (JDE) correctly" do
    expect(calculation.julian_ephemeris_day).to eq(2_446_895.5)
  end

  specify "it calculates time (T) correctly" do
    expect(calculation.time).to eq(-0.127296372348)
  end

  specify "it calculates the moon's mean elongation from the sun correctly" do
    expect(calculation.moon_mean_elongation_from_sun.decimal_degrees.round(4)).to eq(136.9623)
  end

  specify "it calculates the Sun's mean anomaly (M) correctly" do
    expect(calculation.sun_mean_anomaly.decimal_degrees.round(4)).to eq(94.9792)
  end

  specify "it calculates the moon's mean anomaly (M') correctly" do
    expect(calculation.moon_mean_anomaly.decimal_degrees.round(4)).to eq(229.2784)
  end

  specify "it calculates the moon's argument of latitude (F)" do
    expect(calculation.moon_argument_of_latitude.decimal_degrees.round(4)).to eq(143.4079)
  end

  specify "it calculates the longitude of the ascending node of the moon's orbit \"
      (omega) correctly" do
    expect(calculation.longitude_of_ascending_node.decimal_degrees.round(4)).to eq(11.2531)
  end

  specify "it calculates the earth's nutation in longitude (Δψ) correctly" do
    expect(calculation.nutation_in_longitude.decimal_arcseconds.round(3)).to eq(-3.788)
  end

  specify "it calculates the earth's nutation in obliquity (Δε) correctly" do
    expect(calculation.nutation_in_obliquity.decimal_arcseconds.round(3)).to eq(9.443)
  end

  specify "it calculates the mean obliquity of the ecliptic (ε0) correctly" do
    expect(calculation.mean_obliquity_of_ecliptic.decimal_degrees.round(6)).to eq(23.440946)
  end

  specify "it calculates the true obliquity of the ecliptic (ε) correctly" do
    expect(calculation.obliquity_of_ecliptic.decimal_degrees.round(6)).to eq(23.443569)
  end
end
