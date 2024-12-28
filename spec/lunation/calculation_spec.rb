RSpec.describe Lunation::Calculation do
  let(:calculation) { described_class.new(datetime) }
  let(:datetime) { DateTime.new(1987, 4, 10, 0, 0, 0, "+00:00") }

  specify "to_s works correctly" do
    expect(calculation.to_s).to be_a(String)
  end

  specify "to_h works correctly" do
    expect(calculation.to_h).to be_a(Hash)
  end

  specify "it calculates moon_illuminated_fraction correctly" do
    # example 48.a (A.A. p. 347)
    allow(calculation)
      .to receive(:moon_phase_angle)
      .and_return(described_class::Angle.from_decimal_degrees(69.0756))

    expect(calculation.moon_illuminated_fraction).to eq(0.6786)
  end

  specify "it calculates moon_phase_angle correctly" do
    # example 48.a (A.A. p. 347)
    allow(calculation).to receive_messages(
      distance_between_earth_and_sun_in_kilometers: 149_971_520, # R
      distance_between_earth_and_moon: 368_410, # Delta
      moon_elongation_from_sun: described_class::Angle.from_decimal_degrees(110.7929) # ψ
    )

    expect(calculation.moon_phase_angle.decimal_degrees.round(4)).to eq(69.0756)
  end

  specify "it calculates distance_between_earth_and_sun_in_astronomical_units correctly" do
    allow(calculation).to receive_messages(
      earth_orbit_eccentricity: 0.016711668, # (e) A.A. p. 165
      sun_anomaly: described_class::Angle.from_decimal_degrees(278.99397 - 1.89732) # (v = M + C) A.A. p. 165
    )

    # 1992-10-13 at 0 TD
    # (R) A.A. p. 165
    expect(calculation.distance_between_earth_and_sun_in_astronomical_units.round(5))
      .to eq(0.99766)
  end

  specify "it calculates distance_between_earth_and_sun_in_kilometers correctly" do
    allow(calculation).to receive_messages(
      distance_between_earth_and_sun_in_astronomical_units: 1.0024977
    )

    # example 48.a, A.A. p. 347
    expect(calculation.distance_between_earth_and_sun_in_kilometers).to eq(149_971_520)
  end

  specify "it calculates earth_orbit_eccentricity correctly" do
    allow(calculation).to receive_messages(time: -0.072183436) # 1992-10-13 at 0 TD

    # example 25.a, A.A. p. 165
    expect(calculation.earth_orbit_eccentricity).to eq(0.016711668)
  end

  specify "it calculates correction_eccentricity_of_earth correctly" do
    allow(calculation).to receive(:time).and_return(-0.077221081451) # 1992-04-12 0h TD

    # example 47.a (A.A. p. 342)
    expect(calculation.correction_eccentricity_of_earth).to eq(1.000194)
  end

  specify "it calculates sun_anomaly correctly" do
    allow(calculation).to receive_messages(
      sun_mean_anomaly2: 278.99397, # (M)
      sun_equation_of_center: -1.89732 # (C)
    )

    expect(calculation.sun_anomaly).to eq(277.09665) # example 25.a A.A. p. 165
  end

  specify "it calculates sun_mean_anomaly2 correctly" do
    allow(calculation).to receive(:time).and_return(-0.072183436) # 1992-10-13 0h TD

    # example 25.a (A.A. p. 165)
    expect(calculation.sun_mean_anomaly2.decimal_degrees.round(5)).to eq(278.99397)
  end

  specify "it calculates sun_mean_anomaly correctly" do
    allow(calculation).to receive(:time).and_return(-0.127296372348) # 1987-04-10 0h TD

    # example 22.a (A.A. p. 148)
    expect(calculation.sun_mean_anomaly.decimal_degrees.round(5)).to eq(94.9792)
  end

  specify "it calculates sun_equation_of_center correctly" do
    allow(calculation).to receive_messages(
      sun_mean_anomaly: described_class::Angle.from_decimal_degrees(278.99397), # (M)
      time: -0.072183436 # (T) 1992-10-13 0h TD
    )

    # example 25.a A.A. p. 165
    expect(calculation.sun_equation_of_center.decimal_degrees.round(5)).to eq(-1.89732)
  end

  specify "it calculates moon_elongation_from_sun correctly" do
    allow(calculation).to receive_messages(
      sun_right_ascension: described_class::Angle.from_decimal_degrees(20.6579), # (alpha zero)
      sun_declination: described_class::Angle.from_decimal_degrees(8.6964), # (δ zero)
      moon_right_ascension: described_class::Angle.from_decimal_degrees(134.6885), # (alpha)
      moon_declination: described_class::Angle.from_decimal_degrees(13.7684) # δ
    )

    # example 48.a A.A. p. 347 (ψ)
    expect(calculation.moon_elongation_from_sun.decimal_degrees.round(4)).to eq(110.7929)
  end

  specify "it calculates sun_declination correctly" do
    allow(calculation).to receive_messages(
      corrected_obliquity_of_ecliptic: described_class::Angle.from_decimal_degrees(23.43999), # true epsilon
      sun_ecliptic_longitude: described_class::Angle.from_decimal_degrees(199.90895) # λ
    )

    # example 25.b A.A. p. 169
    expect(calculation.sun_declination.decimal_degrees.round(5)).to eq(-7.78507)
  end

  specify "it calculates distance_between_earth_and_moon correctly" do
    allow(calculation).to receive_messages(moon_heliocentric_distance: -16_590_875) # Σr

    # example 47.a A.A. p. 343
    expect(calculation.distance_between_earth_and_moon).to eq(368_409.7)
  end

  specify "it calculates moon_mean_longitude correctly" do
    allow(calculation).to receive(:time).and_return(-0.077221081451) # 1992-04-12 0h TD

    # A.A. p. 342
    expect(calculation.moon_mean_longitude.decimal_degrees.round(6)).to eq(134.290182)
  end

  specify "it calculates moon_mean_elongation correctly" do
    allow(calculation).to receive(:time).and_return(-0.077221081451) # 1992-04-12 0h TD

    expect(calculation.moon_mean_elongation.decimal_degrees.round(6)).to eq(113.842304)
  end

  specify "it calculates moon_mean_anomaly_high_precision correctly" do
    allow(calculation).to receive(:time).and_return(-0.077221081451) # 1992-04-12 0h TD

    expect(calculation.moon_mean_anomaly_high_precision.decimal_degrees.round(6)).to eq(5.150833)
  end

  specify "it calculates moon_mean_anomaly correctly" do
    allow(calculation).to receive(:time).and_return(-0.127296372348) # 1987-04-10 0h TD

    # example 22.a, A.A. p. 148
    expect(calculation.moon_mean_anomaly.decimal_degrees.round(4)).to eq(229.2784)
  end

  specify "it calculates moon_argument_of_latitude_high_precision correctly" do
    allow(calculation).to receive(:time).and_return(-0.077221081451) # 1992-04-12 0h TD

    expect(calculation.moon_argument_of_latitude_high_precision.decimal_degrees.round(6)).to eq(219.889721)
  end

  specify "it calculates moon_argument_of_latitude correctly" do
    allow(calculation).to receive(:time).and_return(-0.127296372348) # 1987-04-10 0h TD

    # example 22.a, A.A. p. 148
    expect(calculation.moon_argument_of_latitude.decimal_degrees.round(4)).to eq(143.4079)
  end

  specify "it calculates correction_venus correctly" do
    allow(calculation).to receive(:time).and_return(-0.077221081451) # 1992-04-12 0h TD

    # example 47.a (A.A. p. 342)
    expect(calculation.correction_venus.decimal_degrees.round(2)).to eq(109.57)
  end

  specify "it calculates correction_jupiter correctly" do
    allow(calculation).to receive(:time).and_return(-0.077221081451) # 1992-04-12 0h TD

    expect(calculation.correction_jupiter.decimal_degrees.round(2)).to eq(123.78)
  end

  specify "it calculates correction_latitude correctly" do
    allow(calculation).to receive(:time).and_return(-0.077221081451) # 1992-04-12 0h TD

    # example 47.a (A.A. p. 342)
    expect(calculation.correction_latitude.decimal_degrees.round(2)).to eq(229.53)
  end

  specify "it calculates moon_heliocentric_longitude correctly" do
    # example 47.a A.A. p. 342
    allow(calculation).to receive_messages(
      correction_jupiter: described_class::Angle.from_decimal_degrees(123.78), # (A2)
      correction_venus: described_class::Angle.from_decimal_degrees(109.57), # (A1)
      correction_eccentricity_of_earth: 1.000194, # (E)
      moon_argument_of_latitude_high_precision: described_class::Angle.from_decimal_degrees(219.889721), # (F)
      moon_mean_anomaly_high_precision: described_class::Angle.from_decimal_degrees(5.150833), # (M')
      moon_mean_elongation: described_class::Angle.from_decimal_degrees(113.842304), # (D)
      moon_mean_longitude: described_class::Angle.from_decimal_degrees(134.290182), # (L')
      sun_mean_anomaly2: described_class::Angle.from_decimal_degrees(97.643514) # (M)
    )

    expect(calculation.moon_heliocentric_longitude).to eq(-1_127_527)
  end

  specify "it calculates moon_heliocentric_distance correctly" do
    # example 47.a A.A. p. 342
    allow(calculation).to receive_messages(
      correction_eccentricity_of_earth: 1.000194, # (E)
      moon_argument_of_latitude_high_precision: described_class::Angle.from_decimal_degrees(219.889721), # (F)
      moon_mean_anomaly_high_precision: described_class::Angle.from_decimal_degrees(5.15083), # (M')
      moon_mean_elongation: described_class::Angle.from_decimal_degrees(113.842304), # (D)
      sun_mean_anomaly2: described_class::Angle.from_decimal_degrees(97.643514) # (M)
    )

    expect(calculation.moon_heliocentric_distance).to eq(-16_590_875)
  end

  specify "it calculates moon_heliocentric_latitude correctly" do
    allow(calculation).to receive_messages(
      correction_latitude: described_class::Angle.from_decimal_degrees(229.53), # (A3)
      correction_venus: described_class::Angle.from_decimal_degrees(109.57), # (A1)
      correction_eccentricity_of_earth: 1.000194, # (E)
      moon_argument_of_latitude_high_precision: described_class::Angle.from_decimal_degrees(219.889721), # (F)
      moon_mean_anomaly_high_precision: described_class::Angle.from_decimal_degrees(5.150833), # (M')
      moon_mean_elongation: described_class::Angle.from_decimal_degrees(113.842304), # (D)
      moon_mean_longitude: described_class::Angle.from_decimal_degrees(134.290182), # (L')
      sun_mean_anomaly2: described_class::Angle.from_decimal_degrees(97.643514) # (M)
    )

    expect(calculation.moon_heliocentric_latitude).to eq(-3_229_126)
  end

  specify "it calculates moon_ecliptic_longitude correctly" do
    allow(calculation).to receive_messages(
      moon_heliocentric_longitude: -1_127_527, # (Σl)
      moon_mean_longitude: described_class::Angle.from_decimal_degrees(134.290182) # (L')
    )

    expect(calculation.moon_ecliptic_longitude.decimal_degrees).to eq(133.162655)
  end

  specify "it calculates moon_ecliptic_latitude correctly" do
    allow(calculation).to receive_messages(moon_heliocentric_latitude: -3_229_126) # (Σb)

    expect(calculation.moon_ecliptic_latitude.decimal_degrees).to eq(-3.229126)
  end

  specify "it calculates equatorial_horizontal_parallax correctly" do
    allow(calculation).to receive_messages(
      distance_between_earth_and_moon: 368_409.7 # (Σr) example 47.a, A.A. p. 342
    )

    # A.A. p. 343
    expect(calculation.equatorial_horizontal_parallax.decimal_degrees.round(5)).to eq(0.991990)
  end

  specify "it calculates nutation_in_longitude correctly" do
    allow(calculation).to receive_messages(
      time: -0.127296372348, # T, 1987-04-10
      moon_mean_elongation: described_class::Angle.from_decimal_degrees(136.9623), # D
      sun_mean_anomaly: described_class::Angle.from_decimal_degrees(94.9792), # M
      moon_mean_anomaly: described_class::Angle.from_decimal_degrees(229.2784), # M'
      moon_argument_of_latitude: described_class::Angle.from_decimal_degrees(143.4079), # F
      longitude_of_ascending_node: described_class::Angle.from_decimal_degrees(11.2531) # Omega
    )

    expect(calculation.nutation_in_longitude.decimal_arcseconds.round(3)).to eq(-3.788)
  end

  specify "it calculates moon_apparent_ecliptic_longitude correctly" do
    allow(calculation).to receive_messages(
      moon_ecliptic_longitude: described_class::Angle.from_decimal_degrees(133.162655), # (λ)
      nutation_in_longitude: described_class::Angle.from_decimal_arcseconds(16.595) # (Δψ)
    )

    # example 47.a A.A. p. 343
    expect(calculation.moon_apparent_ecliptic_longitude.decimal_degrees.round(6))
      .to eq(133.167265)
  end

  specify "it calculates sun_ecliptic_longitude correctly" do
    allow(calculation).to receive_messages(
      sun_true_longitude: described_class::Angle.from_decimal_degrees(199.90988), # ☉
      longitude_of_ascending_node_low_precision: described_class::Angle.from_decimal_degrees(264.65) # Omega
    )

    # example 25.a A.A. p. 165
    expect(calculation.sun_ecliptic_longitude.decimal_degrees.round(5)).to eq(199.90895)
  end

  specify "it calculates sun_mean_longitude correctly" do
    allow(calculation).to receive_messages(time: -0.072183436) # T, 1992-10-13 0h TD

    # example 25.a A.A. p. 165
    expect(calculation.sun_mean_longitude.decimal_degrees.round(5)).to eq(201.80720)
  end

  specify "it calculates sun_true_longitude correctly" do
    allow(calculation).to receive_messages(
      sun_mean_longitude: described_class::Angle.from_decimal_degrees(201.80720), # L0
      sun_equation_of_center: described_class::Angle.from_decimal_degrees(-1.89732, normalize: false) # C
    )

    # example 25.a A.A. p. 165
    expect(calculation.sun_true_longitude.decimal_degrees.round(5)).to eq(199.90988)
  end

  specify "it calculates nutation_in_obliquity correctly" do
    allow(calculation).to receive_messages(
      time: -0.127296372348, # 1987-04-10 0h TD
      moon_mean_elongation: described_class::Angle.from_decimal_degrees(136.9623), # (D) A.A. p. 148
      sun_mean_anomaly: described_class::Angle.from_decimal_degrees(94.9792), # (M) A.A. p. 148
      moon_mean_anomaly: described_class::Angle.from_decimal_degrees(229.2784), # (M') A.A. p. 148
      moon_argument_of_latitude: described_class::Angle.from_decimal_degrees(143.4079), # (F) A.A. p. 148
      longitude_of_ascending_node: described_class::Angle.from_decimal_degrees(11.2531) # (Ω) A.A. p. 148
    )

    # example 22.a A.A. p. 148
    expect(calculation.nutation_in_obliquity.decimal_arcseconds.round(3)).to eq(9.443)
  end

  # (Ω) A.A. p. 148
  specify "it calculates longitude_of_ascending_node correctly" do
    allow(calculation).to receive_messages(time: -0.127296372348) # 1987-04-10 0h TD

    # example 22.a A.A. p. 148
    # (Δε) A.A. p. 148
    expect(calculation.longitude_of_ascending_node.decimal_degrees.round(4)).to eq(11.2531)
  end

  specify "it calculates longitude_of_ascending_node_low_precision correctly" do
    allow(calculation).to receive_messages(time: -0.072183436) # 1992-10-13 0h TD)

    # example 25.a A.A. p. 165
    expect(calculation.longitude_of_ascending_node_low_precision.decimal_degrees.round(2))
      .to eq(264.65) # (Ω) A.A. p. 165
  end

  specify "it calculates mean_obliquity_of_ecliptic correctly" do
    allow(calculation).to receive_messages(time_myriads: -0.00127296372348) # (U)

    # example 22.a A.A. p. 148
    expect(calculation.mean_obliquity_of_ecliptic.degrees).to eq(23)
    expect(calculation.mean_obliquity_of_ecliptic.arcminutes).to eq(26)
    expect(calculation.mean_obliquity_of_ecliptic.decimal_arcseconds.round(3)).to eq(27.407)
  end

  specify "it calculates obliquity_of_ecliptic correctly" do
    allow(calculation).to receive_messages(
      mean_obliquity_of_ecliptic: described_class::Angle.from_decimal_degrees(23.440946), # (ε0)
      nutation_in_obliquity: described_class::Angle.from_decimal_arcseconds(9.443) # (Δε)
    )

    # converted from 23deg26'36".850 (example 22.a A.A. p. 148)
    expect(calculation.obliquity_of_ecliptic.degrees).to eq(23)
    expect(calculation.obliquity_of_ecliptic.arcminutes).to eq(26)
    expect(calculation.obliquity_of_ecliptic.decimal_arcseconds.round(3)).to eq(36.849)
  end

  specify "it calculates corrected_obliquity_of_ecliptic correctly" do
    allow(calculation).to receive_messages(
      # (ε0)
      mean_obliquity_of_ecliptic: described_class::Angle.from_degrees(
        degrees: 23,
        arcminutes: 26,
        decimal_arcseconds: 24.83
      ),
      longitude_of_ascending_node: described_class::Angle.from_decimal_degrees(264.65) # (omega)
    )

    # example 25.a, A.A. p. 165
    expect(calculation.corrected_obliquity_of_ecliptic.decimal_degrees.round(5)).to eq(23.43999)
  end

  describe "moon_right_ascension" do
    subject(:moon_right_ascension) { calculation.moon_right_ascension }

    before do
      allow(calculation).to receive_messages(
        moon_apparent_ecliptic_longitude: moon_apparent_ecliptic_longitude,
        obliquity_of_ecliptic: obliquity_of_ecliptic,
        moon_ecliptic_latitude: moon_ecliptic_latitude
      )
    end

    context "when example 13.a (A.A. p. 95)" do
      # λ
      let(:moon_apparent_ecliptic_longitude) do
        described_class::Angle.from_decimal_degrees(113.215630)
      end
      # ε
      let(:obliquity_of_ecliptic) do
        described_class::Angle.from_decimal_degrees(23.4392911)
      end
      # β
      let(:moon_ecliptic_latitude) do
        described_class::Angle.from_decimal_degrees(6.684170)
      end

      it { expect(moon_right_ascension.decimal_degrees.round(6)).to eq(116.328942) }
    end

    context "when example 47.a (A.A. p. 343)" do
      # apparent λ
      let(:moon_apparent_ecliptic_longitude) do
        described_class::Angle.from_decimal_degrees(133.167265)
      end
      # ε
      let(:obliquity_of_ecliptic) do
        described_class::Angle.from_decimal_degrees(23.440636)
      end
      # β
      let(:moon_ecliptic_latitude) do
        described_class::Angle.from_decimal_degrees(-3.229126)
      end

      it { expect(moon_right_ascension.decimal_degrees.round(6)).to eq(134.688470) }
    end
  end

  specify "it calculates sun_right_ascension correctly" do
    allow(calculation).to receive_messages(
      corrected_obliquity_of_ecliptic: described_class::Angle.from_decimal_degrees(23.43999), # ε
      sun_ecliptic_longitude: described_class::Angle.from_decimal_degrees(199.90895) # λ
    )

    # example 25.a, A.A. p. 165
    expect(calculation.sun_right_ascension.decimal_degrees.round(5)).to eq(198.38083)
  end

  specify "it calculates moon_declination correctly" do
    allow(calculation).to receive_messages(
      moon_apparent_ecliptic_longitude: described_class::Angle.from_decimal_degrees(133.167265), # apparent λ
      obliquity_of_ecliptic: described_class::Angle.from_decimal_degrees(23.440636), # ε
      moon_ecliptic_latitude: described_class::Angle.from_decimal_degrees(-3.229126) # β
    )

    expect(calculation.moon_declination.decimal_degrees.round(6)).to eq(13.768368)
  end

  specify "it calculates moon_mean_elongation_from_sun correctly" do
    allow(calculation).to receive(:time).and_return(-0.127296372348) # 1987-04-10 0h TD

    expect(calculation.moon_mean_elongation_from_sun.decimal_degrees.round(4)).to eq(136.9623)
  end

  specify "it calculates moon_position_angle_of_bright_limb correctly" do
    allow(calculation).to receive_messages(
      moon_declination: described_class::Angle.from_decimal_degrees(13.7684),
      moon_right_ascension: described_class::Angle.from_decimal_degrees(134.6885),
      sun_declination: described_class::Angle.from_decimal_degrees(8.6964),
      sun_right_ascension: described_class::Angle.from_decimal_degrees(20.6579)
    )

    expect(calculation.moon_position_angle_of_bright_limb.decimal_degrees.round(1)).to eq(285.0)
  end
end
