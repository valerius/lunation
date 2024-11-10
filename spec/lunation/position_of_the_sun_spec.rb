RSpec.describe "Position of the sun" do
  # This spec tests the values described in example 25.a (A.A. p. 165)

  before { allow(calculation).to receive(:dynamical_time).and_return(dynamical_time) }

  # datetime does not matter here, we are taking dynamical time as a starting point
  let(:calculation) { Lunation::Calculation.new(DateTime.now) }
  let(:dynamical_time) { DateTime.new(1992, 10, 13, 0, 0, 0, "+00:00") }

  specify "it calculates julian_ephemeris_day (JDE) correctly" do
    expect(calculation.julian_ephemeris_day).to eq(2_448_908.5)
  end

  specify "it calculates time (T) correctly" do
    expect(calculation.time.round(9)).to eq(-0.072183436)
  end

  specify "it calculates the sun's geometric mean longitude (L0) correctly" do
    expect(calculation.calculate_sun_geocentric_mean_longitude.decimal_degrees.round(5)).to eq(201.80720)
  end

  specify "it calculates the Sun's mean anomaly (M) correctly" do
    expect(calculation.calculate_sun_mean_anomaly.decimal_degrees.round(5)).to eq(278.99397)
  end

  specify "it calculates the eccentricity of earth's orbit (e) correctly" do
    expect(calculation.calculate_earth_eccentricity.round(9)).to eq(0.016711668)
  end

  specify "it calculates the sun's equation of the center (C) correctly" do
    expect(calculation.calculate_sun_equation_center.decimal_degrees.round(5)).to eq(-1.89732)
  end

  # value in example is 199.90988
  specify "it calculates the sun's true longitude (symbol of the sun) correctly" do
    expect(calculation.calculate_sun_true_longitude.decimal_degrees.round(5)).to eq(199.90987)
  end

  specify "it calculates the distance between the earth and the sun (R) correctly" do
    expect(calculation.calculate_earth_sun_distance.round(5)).to eq(0.99766)
  end

  specify "it calculates the longitude of the ascending node of the moon's orbit \"
      (omega) correctly" do
    expect(calculation.calculate_moon_orbital_longitude_mean_ascending_node2.decimal_degrees.round(2)).to eq(264.65)
  end

  # value in example is 199.90895
  specify "it calculates sun's apparent longitude (lambda) correctly" do
    expect(calculation.calculate_sun_ecliptical_longitude.decimal_degrees.round(5)).to eq(199.90894)
  end

  specify "it calculates the ecliptic's mean obliquity (ε0) correctly" do
    expect(calculation.calculate_ecliptic_mean_obliquity.decimal_degrees.round(5)).to eq(23.44023)
  end

  specify "it calculates the ecliptic's true obliquity (ε) correctly" do
    expect(calculation.calculate_corrected_ecliptic_true_obliquity.decimal_degrees.round(5)).to eq(23.43999)
  end

  specify "it calculates sun's geocentric (apparent) right ascension (α) correctly" do
    expect(calculation.calculate_sun_geocentric_right_ascension.decimal_degrees.round(5)).to eq(198.38083)
  end

  specify "it calculates sun's geocentric (apparent) declination (delta0) correctly" do
    expect(calculation.calculate_sun_geocentric_declination.decimal_degrees.round(5)).to eq(-7.78507)
  end
end
