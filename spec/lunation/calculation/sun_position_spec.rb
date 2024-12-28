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
    expect(calculation.sun_mean_longitude.decimal_degrees.round(5)).to eq(201.80720)
  end

  specify "it calculates the Sun's mean anomaly (M) correctly" do
    expect(calculation.sun_mean_anomaly2.decimal_degrees.round(5)).to eq(278.99397)
  end

  specify "it calculates the eccentricity of earth's orbit (e) correctly" do
    expect(calculation.earth_orbit_eccentricity.round(9)).to eq(0.016711668)
  end

  specify "it calculates the sun's equation of the center (C) correctly" do
    expect(calculation.sun_equation_of_center.decimal_degrees.round(5)).to eq(-1.89732)
  end

  # value in example is 199.90988
  specify "it calculates the sun's true longitude (symbol of the sun) correctly" do
    expect(calculation.sun_true_longitude.decimal_degrees.round(5)).to eq(199.90987)
  end

  specify "it calculates the distance between the earth and the sun (R) correctly" do
    expect(calculation.distance_between_earth_and_sun_in_astronomical_units.round(5)).to eq(0.99766)
  end

  specify "it calculates the longitude of the ascending node of the moon's orbit \"
      (omega) correctly" do
    expect(calculation.longitude_of_ascending_node_low_precision.decimal_degrees.round(2)).to eq(264.65)
  end

  # value in example is 199.90895
  specify "it calculates sun's apparent longitude (λ) correctly" do
    expect(calculation.sun_ecliptic_longitude.decimal_degrees.round(5)).to eq(199.90894)
  end

  specify "it calculates the ecliptic's mean obliquity (ε0) correctly" do
    expect(calculation.mean_obliquity_of_ecliptic.decimal_degrees.round(5)).to eq(23.44023)
  end

  specify "it calculates the ecliptic's true obliquity (ε) correctly" do
    expect(calculation.corrected_obliquity_of_ecliptic.decimal_degrees.round(5)).to eq(23.43999)
  end

  specify "it calculates sun's geocentric (apparent) right ascension (α) correctly" do
    expect(calculation.sun_right_ascension.decimal_degrees.round(5)).to eq(198.38083)
  end

  specify "it calculates sun's geocentric (apparent) declination (δ0) correctly" do
    expect(calculation.sun_declination.decimal_degrees.round(5)).to eq(-7.78507)
  end
end
