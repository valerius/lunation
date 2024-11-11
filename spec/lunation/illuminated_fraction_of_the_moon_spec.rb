RSpec.describe "Illuminated fraction of the moon" do
  # This spec tests the values described in example 48.a (A.A. p. 347)

  before { allow(calculation).to receive(:dynamical_time).and_return(dynamical_time) }

  # datetime does not matter here, we are taking dynamical time as a starting point
  let(:calculation) { Lunation::Calculation.new(DateTime.now) }
  let(:dynamical_time) { DateTime.new(1992, 4, 12, 0, 0, 0, "+00:00") }

  specify "it calculates the moon's apparent right ascension (α) correctly" do
    expect(calculation.calculate_moon_geocentric_right_ascension.decimal_degrees.round(4)).to eq(134.6885)
  end

  specify "it calculates the moon's apparent declination (delta) correctly" do
    expect(calculation.calculate_moon_geocentric_declination.decimal_degrees.round(4)).to eq(13.7684)
  end

  specify "it calculates the distance between the earth and the moon (Delta) correctly" do
    expect(calculation.calculate_earth_moon_distance.round).to eq(368_410)
  end

  # specify "it calculates the sun's apparent right ascension (α0) correctly" do
  #   # 20.6579 is the value in the example
  #   expect(calculation.calculate_sun_geocentric_right_ascension.decimal_degrees.round(4)).to eq(20.6579)
  # end

  # specify "it calculates the moon's illuminated fraction (k) correctly" do
  #   expect(calculation.calculate_moon_illuminated_fraction).to eq(0.6786)
  # end

  # specify "it calculates the geocentric elongation of the moon (psi) correctly" do
  #   expect(calculation.moon_geocentric_elongation).to eq(110.7929)
  # end

  # START WRONG

  # specify "it calculates the moon's phase angle (i) correctly" do
  #   expect(calculation.calculate_moon_phase_angle.decimal_degrees.round(4)).to eq(69.0756)
  # end

  # specify "it calculates the distance between the earth and the sun (R) correctly" do
  #   expect(calculation.earth_sun_distance.round(7)).to eq(1.0024977)
  # end

  # specify "it calculates the distance between the earth and the sun in km's (R) \"
  #   correctly" do
  #   expect(calculation.earth_sun_distance_in_km).to eq(149_971_520)
  # end

  # END WRONG

  # specify "it calculates the distance between the earth and the moon (Delta) correctly" do
  #   expect(calculation.earth_moon_distance.round).to eq(368_410)
  # end

  # specify "it calculates the ecliptic's true obliquity (epsilon) correctly" do
  #   # 23.440636 is the value in the example
  #   expect(calculation.ecliptic_true_obliquity).to eq(23.440635)
  # end

  # specify "it calculates sun's geocentric (apparent) declination (delta0) correctly" do
  #   # 8.6964 is the value in the example
  #   expect(calculation.sun_geocentric_declination.round(4)).to eq(8.6965)
  # end

  # specify "it calculates the moon's phase angle (i) correctly" do
  #   expect(calculation.moon_phase_angle.round(4)).to eq(69.0756)
  # end
end
