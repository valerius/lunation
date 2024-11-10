RSpec.describe "Position of the moon" do
  # This spec tests the values described in example 47.a (A.A. p. 342)

  before { allow(calculation).to receive(:dynamical_time).and_return(dynamical_time) }

  # datetime does not matter here, we are taking dynamical time as a starting point
  let(:calculation) { Lunation::Calculation.new(DateTime.now) }
  let(:dynamical_time) { DateTime.new(1992, 4, 12, 0, 0, 0, "+00:00") }

  specify "it calculates julian_ephemeris_day (JDE) correctly" do
    expect(calculation.julian_ephemeris_day).to eq(2_448_724.5)
  end

  specify "it calculates time (T) correctly" do
    expect(calculation.time).to eq(-0.077221081451)
  end

  specify "it calculates moon's mean longitude (L') correctly" do
    expect(calculation.calculate_moon_mean_longitude.decimal_degrees.round(6)).to eq(134.290182)
  end

  specify "it calculates the mean elongation of the moon (D) correctly" do
    expect(calculation.calculate_moon_mean_elongation.decimal_degrees.round(6)).to eq(113.842304)
  end

  specify "it calculates the Sun's mean anomaly (M) correctly" do
    expect(calculation.calculate_sun_mean_anomaly.decimal_degrees.round(6)).to eq(97.643514)
  end

  specify "it calculates the moon's mean anomaly (M') correctly" do
    expect(calculation.calculate_moon_mean_anomaly.decimal_degrees.round(6)).to eq(5.150833)
  end

  specify "it calculates the moon's argument of latitude (F)" do
    expect(calculation.calculate_moon_argument_of_latitude.decimal_degrees.round(6)).to eq(219.889721)
  end

  specify "it calculates the correction of Venus (A1) correctly" do
    expect(calculation.calculate_correction_venus.decimal_degrees.round(2)).to eq(109.57)
  end

  specify "it calculates the correction of Jupiter (A2) correctly" do
    expect(calculation.calculate_correction_jupiter.decimal_degrees.round(2)).to eq(123.78)
  end

  specify "it calculates the correction of latitude (A3) correctly" do
    expect(calculation.calculate_correction_latitude.decimal_degrees.round(2)).to eq(229.53)
  end

  specify "it calculates the Earth's eccentricity's correction (E) correctly" do
    expect(calculation.calculate_earth_eccentricity_correction.round(6)).to eq(1.000194)
  end

  specify "it calculates the moon's heliocentric longitude (Sigma l) correctly" do
    expect(calculation.calculate_moon_heliocentric_longitude.round).to eq(-1_127_527)
  end

  specify "it calculates the moon's heliocentric latitude (Sigma b) correctly" do
    expect(calculation.calculate_moon_heliocentric_latitude.round).to eq(-3_229_126)
  end

  specify "it calculates the moon's distance (Sigma r) correctly" do
    expect(calculation.calculate_moon_heliocentric_distance.round).to eq(-16_590_875)
  end

  specify "it calculates the moon's ecliptical longitude (lambda) correctly" do
    expect(calculation.calculate_moon_geocentric_longitude.decimal_degrees.round(6)).to eq(133.162655)
  end

  specify "it calculates the moon's ecliptical latitude (beta) correctly" do
    expect(calculation.calculate_moon_ecliptic_latitude.decimal_degrees).to eq(-3.229126)
  end

  specify "it calculates the distance between the earth and the moon (Delta) correctly" do
    expect(calculation.calculate_earth_moon_distance).to eq(368_409.7)
  end

  specify "it calculates the moon's equitorial horizontal parallax (pi) correctly" do
    expect(calculation.calculate_equitorial_horizontal_parallax.decimal_degrees.round(6)).to eq(0.991990)
  end

  specify "it calculates the earth's nutation in longitude (Delta psi)" do
    expect(calculation.calculate_earth_nutation_in_longitude.decimal_arcseconds.round(3)).to eq(16.595)
  end

  specify "it calculates the moon's apparent longitude (apparent lambda) correctly" do
    expect(calculation.calculate_moon_ecliptic_longitude.decimal_degrees.round(6)).to eq(133.167264) # should be 133.167265
  end

  specify "it calculates the true obliquity of the ecliptic (ε) correctly" do
    expect(calculation.calculate_ecliptic_true_obliquity.decimal_degrees.round(6)).to eq(23.440635) # should be 23.440636
  end

  specify "it calculates the moon's apparent right ascension (α) correctly" do
    expect(calculation.calculate_moon_geocentric_right_ascension.decimal_degrees.round(6)).to eq(134.688469) # should be 134.688470 rubocop:disable Layout/LineLength
  end

  specify "it calculates the moon's apparent declination (delta) correctly" do
    expect(calculation.calculate_moon_geocentric_declination.decimal_degrees.round(6)).to eq(13.768367) # should be 13.768368
  end
end
