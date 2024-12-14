RSpec.describe "Illuminated fraction of the moon" do
  # This spec tests the values described in example 48.a (A.A. p. 347)

  before do
    allow(calculation).to receive_messages(
      dynamical_time: dynamical_time,
      calculate_sun_geocentric_right_ascension: sun_geocentric_right_ascension,
      calculate_sun_geocentric_declination: sun_geocentric_declination,
      calculate_earth_sun_distance_in_km: earth_sun_distance_in_km
    )
  end

  # datetime does not matter here, we are taking dynamical time as a starting point
  let(:calculation) { Lunation::Calculation.new(DateTime.now) }
  let(:dynamical_time) { DateTime.new(1992, 4, 12, 0, 0, 0, "+00:00") }

  # The position of the sun seems to have been calculated using the complete VSOP 87
  #   theory, that is not given in the book (A.A. 347). The abridged VSOP 87 yields a
  #   slightly different result. In this test the given values for the sun's position are
  #   used.
  let(:sun_geocentric_right_ascension) { Lunation::Angle.from_decimal_degrees(20.6579) }
  let(:sun_geocentric_declination) { Lunation::Angle.from_decimal_degrees(8.6964) }
  let(:earth_sun_distance_in_km) { 149_971_520 }

  specify "it calculates the moon's apparent right ascension (α) correctly" do
    expect(calculation.calculate_moon_geocentric_right_ascension.decimal_degrees.round(4)).to eq(134.6885)
  end

  specify "it calculates the moon's apparent declination (delta) correctly" do
    expect(calculation.calculate_moon_geocentric_declination.decimal_degrees.round(4)).to eq(13.7684)
  end

  specify "it calculates the distance between the earth and the moon (Delta) correctly" do
    expect(calculation.calculate_earth_moon_distance.round).to eq(368_410)
  end

  specify "it calculates the geocentric elongation of the moon (psi) correctly" do
    expect(calculation.calculate_moon_geocentric_elongation.decimal_degrees.round(4)).to eq(110.7929)
  end

  specify "it calculates the moon's phase angle (i) correctly" do
    # The value in the test is 69.0756
    expect(calculation.calculate_moon_phase_angle.decimal_degrees.round(4)).to eq(69.0757)
  end

  specify "it calculates the moon's illuminated fraction (k) correctly" do
    expect(calculation.calculate_moon_illuminated_fraction).to eq(0.6786)
  end
end
