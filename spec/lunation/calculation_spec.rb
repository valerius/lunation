RSpec.describe Lunation::Calculation do
  let(:calculation) { described_class.new(datetime) }
  let(:datetime) { DateTime.new(1987, 4, 10, 0, 0, 0, "+00:00") }

  describe "calculate_moon_illuminated_fraction" do
    subject(:calculate_moon_illuminated_fraction) do
      calculation.calculate_moon_illuminated_fraction(moon_phase_angle: moon_phase_angle)
    end

    # example 48.a (A.A. p. 347)
    let(:moon_phase_angle) { Lunation::Angle.from_decimal_degrees(69.0756) }

    it { expect(calculate_moon_illuminated_fraction).to eq(0.6786) }
  end

  describe "calculate_moon_phase_angle" do
    subject(:calculate_moon_phase_angle) do
      calculation.calculate_moon_phase_angle(
        distance_between_earth_and_sun_in_kilometers: 149_971_520, # R
        distance_between_earth_and_moon: 368_410, # Delta
        moon_elongation_from_sun: Lunation::Angle.from_decimal_degrees(110.7929) # ψ
      )
    end

    # example 48.a (A.A. p. 347)
    it { expect(calculate_moon_phase_angle.decimal_degrees.round(4)).to eq(69.0756) }
  end

  describe "calculate_distance_between_earth_and_sun_in_astronomical_units" do
    subject(:calculate_distance_between_earth_and_sun_in_astronomical_units) do
      calculation.calculate_distance_between_earth_and_sun_in_astronomical_units(
        earth_orbit_eccentricity: 0.016711668, # (e) A.A. p. 165
        sun_anomaly: sun_anomaly
      )
    end

    let(:sun_anomaly) do
      Lunation::Angle.from_decimal_degrees(278.99397 - 1.89732) # (v = M + C) A.A. p. 165
    end

    # 1992-10-13 at 0 TD
    it {
      expect(calculate_distance_between_earth_and_sun_in_astronomical_units.round(5)).to eq(0.99766)
    } # (R) A.A. p. 165
  end

  describe "calculate_distance_between_earth_and_sun_in_kilometers" do
    subject(:calculate_distance_between_earth_and_sun_in_kilometers) do
      calculation.calculate_distance_between_earth_and_sun_in_kilometers(earth_sun_distance: 1.0024977)
    end

    # example 48.a, A.A. p. 347
    it {
      expect(calculate_distance_between_earth_and_sun_in_kilometers).to eq(149_971_520)
    }
  end

  describe "calculate_earth_orbit_eccentricity" do
    subject(:calculate_earth_orbit_eccentricity) do
      calculation.calculate_earth_orbit_eccentricity
    end

    before { allow(calculation).to receive_messages(time: time) }

    let(:time) { -0.072183436 } # 1992-10-13 at 0 TD

    # example 25.a, A.A. p. 165
    it { expect(calculate_earth_orbit_eccentricity).to eq(0.016711668) }
  end

  describe "calculate_correction_eccentricity_of_earth" do
    subject(:calculate_correction_eccentricity_of_earth) do
      calculation.calculate_correction_eccentricity_of_earth
    end

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.077221081451 } # 1992-04-12 0h TD

    # example 47.a (A.A. p. 342)
    it { expect(calculate_correction_eccentricity_of_earth).to eq(1.000194) }
  end

  describe "calculate_sun_anomaly" do
    subject(:calculate_sun_anomaly) do
      calculation.calculate_sun_anomaly(
        sun_mean_anomaly: 278.99397, # (M)
        sun_equation_of_center: -1.89732 # (C)
      )
    end

    it { expect(calculate_sun_anomaly).to eq(277.09665) } # example 25.a A.A. p. 165
  end

  describe "calculate_sun_mean_anomaly2" do
    subject(:calculate_sun_mean_anomaly2) do
      calculation.calculate_sun_mean_anomaly2
    end

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.072183436 } # 1992-10-13 0h TD

    # example 25.a (A.A. p. 165)
    it {
      expect(calculate_sun_mean_anomaly2.decimal_degrees.round(5)).to eq(278.99397)
    }
  end

  describe "calculate_sun_mean_anomaly" do
    subject(:calculate_sun_mean_anomaly) { calculation.calculate_sun_mean_anomaly }

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.127296372348 } # 1987-04-10 0h TD

    # example 22.a (A.A. p. 148)
    it { expect(calculate_sun_mean_anomaly.decimal_degrees.round(5)).to eq(94.9792) }
  end

  describe "calculate_sun_equation_of_center" do
    subject(:calculate_sun_equation_of_center) do
      calculation.calculate_sun_equation_of_center(
        sun_mean_anomaly: Lunation::Angle.from_decimal_degrees(278.99397) # (M)
      )
    end

    before { allow(calculation).to receive_messages(time: time) }

    let(:time) { -0.072183436 } # (T) 1992-10-13 0h TD

    # example 25.a A.A. p. 165
    it {
      expect(calculate_sun_equation_of_center.decimal_degrees.round(5)).to eq(-1.89732)
    }
  end

  describe "calculate_moon_elongation_from_sun" do
    subject(:calculate_moon_elongation_from_sun) do
      calculation.calculate_moon_elongation_from_sun(
        sun_right_ascension: sun_right_ascension,
        sun_declination: sun_declination,
        moon_right_ascension: moon_right_ascension,
        moon_declination: moon_declination
      )
    end

    let(:sun_right_ascension) do
      Lunation::Angle.from_decimal_degrees(20.6579) # (alpha zero)
    end
    let(:sun_declination) do
      Lunation::Angle.from_decimal_degrees(8.6964) # (δ zero)
    end
    let(:moon_right_ascension) do
      Lunation::Angle.from_decimal_degrees(134.6885) # (alpha)
    end
    let(:moon_declination) do
      Lunation::Angle.from_decimal_degrees(13.7684) # δ
    end

    # example 48.a A.A. p. 347 (ψ)
    it { expect(calculate_moon_elongation_from_sun.decimal_degrees.round(4)).to eq(110.7929) } # rubocop:disable Layout/LineLength
  end

  describe "calculate_sun_declination" do
    subject(:calculate_sun_declination) do
      calculation.calculate_sun_declination(
        corrected_obliquity_of_ecliptic: corrected_obliquity_of_ecliptic,
        sun_ecliptic_longitude: sun_ecliptic_longitude
      )
    end

    # true eψlon
    let(:corrected_obliquity_of_ecliptic) do
      Lunation::Angle.from_decimal_degrees(23.43999)
    end
    # λ
    let(:sun_ecliptic_longitude) do
      Lunation::Angle.from_decimal_degrees(199.90895)
    end
    # example 25.b A.A. p. 169
    it {
      expect(calculate_sun_declination.decimal_degrees.round(5)).to eq(-7.78507)
    }
  end

  describe "calculate_distance_between_earth_and_moon" do
    subject(:calculate_distance_between_earth_and_moon) do
      calculation.calculate_distance_between_earth_and_moon(
        moon_heliocentric_distance: -16_590_875 # Σr
      )
    end

    # example 47.a A.A. p. 343
    it { expect(calculate_distance_between_earth_and_moon).to eq(368_409.7) }
  end

  describe "calculate_moon_mean_longitude" do
    subject(:calculate_moon_mean_longitude) do
      calculation.calculate_moon_mean_longitude
    end

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.077221081451 } # 1992-04-12 0h TD

    it {
      expect(calculate_moon_mean_longitude.decimal_degrees.round(6)).to eq(134.290182)
    } # A.A. p. 342
  end

  describe "calculate_moon_mean_elongation" do
    subject(:calculate_moon_mean_elongation) do
      calculation.calculate_moon_mean_elongation
    end

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.077221081451 } # 1992-04-12 0h TD

    it {
      expect(calculate_moon_mean_elongation.decimal_degrees.round(6)).to eq(113.842304)
    }
  end

  describe "calculate_moon_mean_anomaly_high_precision" do
    subject(:calculate_moon_mean_anomaly_high_precision) do
      calculation.calculate_moon_mean_anomaly_high_precision
    end

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.077221081451 } # 1992-04-12 0h TD

    it {
      expect(calculate_moon_mean_anomaly_high_precision.decimal_degrees.round(6)).to eq(5.150833)
    }
  end

  describe "calculate_moon_mean_anomaly" do
    subject(:calculate_moon_mean_anomaly) do
      calculation.calculate_moon_mean_anomaly
    end

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.127296372348 } # 1987-04-10 0h TD

    # example 22.a, A.A. p. 148
    it { expect(calculate_moon_mean_anomaly.decimal_degrees.round(4)).to eq(229.2784) }
  end

  describe "calculate_moon_argument_of_latitude_high_precision" do
    subject(:calculate_moon_argument_of_latitude_high_precision) do
      calculation.calculate_moon_argument_of_latitude_high_precision
    end

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.077221081451 } # 1992-04-12 0h TD

    it {
      expect(calculate_moon_argument_of_latitude_high_precision.decimal_degrees.round(6)).to eq(219.889721)
    }
  end

  describe "calculate_moon_argument_of_latitude" do
    subject(:calculate_moon_argument_of_latitude) do
      calculation.calculate_moon_argument_of_latitude
    end

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.127296372348 } # 1987-04-10 0h TD

    it {
      expect(calculate_moon_argument_of_latitude.decimal_degrees.round(4)).to eq(143.4079)
    } # example 22.a, A.A. p. 148
  end

  describe "calculate_correction_venus" do
    subject(:calculate_correction_venus) { calculation.calculate_correction_venus }

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.077221081451 } # 1992-04-12 0h TD

    it {
      expect(calculate_correction_venus.decimal_degrees.round(2)).to eq(109.57)
    } # example 47.a (A.A. p. 342)
  end

  describe "calculate_correction_jupiter" do
    subject(:calculate_correction_jupiter) { calculation.calculate_correction_jupiter }

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.077221081451 } # 1992-04-12 0h TD

    it { expect(calculate_correction_jupiter.decimal_degrees.round(2)).to eq(123.78) }
  end

  describe "calculate_correction_latitude" do
    subject(:calculate_correction_latitude) { calculation.calculate_correction_latitude }

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.077221081451 } # 1992-04-12 0h TD

    # example 47.a (A.A. p. 342)
    it { expect(calculate_correction_latitude.decimal_degrees.round(2)).to eq(229.53) }
  end

  describe "calculate_moon_heliocentric_longitude" do
    subject(:calculate_moon_heliocentric_longitude) do
      calculation.calculate_moon_heliocentric_longitude(
        correction_jupiter: correction_jupiter,
        correction_venus: correction_venus,
        correction_eccentricity_of_earth: correction_eccentricity_of_earth,
        moon_argument_of_latitude: moon_argument_of_latitude,
        moon_mean_anomaly: moon_mean_anomaly,
        moon_mean_elongation: moon_mean_elongation,
        moon_mean_longitude: moon_mean_longitude,
        sun_mean_anomaly: sun_mean_anomaly
      )
    end

    # example 47.a A.A. p. 342
    let(:correction_jupiter) { Lunation::Angle.from_decimal_degrees(123.78) } # (A2)
    let(:correction_venus) { Lunation::Angle.from_decimal_degrees(109.57) } # (A1)
    # (E)
    let(:correction_eccentricity_of_earth) { 1.000194 }
    # (F)
    let(:moon_argument_of_latitude) do
      Lunation::Angle.from_decimal_degrees(219.889721)
    end
    let(:moon_mean_anomaly) { Lunation::Angle.from_decimal_degrees(5.150833) } # (M')
    # (D)
    let(:moon_mean_elongation) do
      Lunation::Angle.from_decimal_degrees(113.842304)
    end
    # (L')
    let(:moon_mean_longitude) do
      Lunation::Angle.from_decimal_degrees(134.290182)
    end
    let(:sun_mean_anomaly) { Lunation::Angle.from_decimal_degrees(97.643514) } # (M)

    it { expect(calculate_moon_heliocentric_longitude).to eq(-1_127_527) }
  end

  describe "calculate_moon_heliocentric_distance" do
    subject(:calculate_moon_heliocentric_distance) do
      calculation.calculate_moon_heliocentric_distance(
        correction_eccentricity_of_earth: correction_eccentricity_of_earth,
        moon_argument_of_latitude: moon_argument_of_latitude,
        moon_mean_anomaly: moon_mean_anomaly,
        moon_mean_elongation: moon_mean_elongation,
        sun_mean_anomaly: sun_mean_anomaly
      )
    end

    # example 47.a A.A. p. 342
    # (E)
    let(:correction_eccentricity_of_earth) do
      1.000194
    end
    # (F)
    let(:moon_argument_of_latitude) do
      Lunation::Angle.from_decimal_degrees(219.889721)
    end
    let(:moon_mean_anomaly) { Lunation::Angle.from_decimal_degrees(5.15083) } # (M')
    # (D)
    let(:moon_mean_elongation) do
      Lunation::Angle.from_decimal_degrees(113.842304)
    end
    let(:sun_mean_anomaly) { Lunation::Angle.from_decimal_degrees(97.643514) } # (M)

    it { expect(calculate_moon_heliocentric_distance).to eq(-16_590_875) }
  end

  describe "calculate_moon_heliocentric_latitude" do
    subject(:calculate_moon_heliocentric_latitude) do
      calculation.calculate_moon_heliocentric_latitude(
        correction_latitude: correction_latitude,
        correction_venus: correction_venus,
        correction_eccentricity_of_earth: correction_eccentricity_of_earth,
        moon_argument_of_latitude: moon_argument_of_latitude,
        moon_mean_anomaly: moon_mean_anomaly,
        moon_mean_elongation: moon_mean_elongation,
        moon_mean_longitude: moon_mean_longitude,
        sun_mean_anomaly: sun_mean_anomaly
      )
    end

    let(:correction_latitude) { Lunation::Angle.from_decimal_degrees(229.53) } # (A3)
    let(:correction_venus) { Lunation::Angle.from_decimal_degrees(109.57) } # (A1)
    # (E)
    let(:correction_eccentricity_of_earth) { 1.000194 }
    # (F)
    let(:moon_argument_of_latitude) do
      Lunation::Angle.from_decimal_degrees(219.889721)
    end
    let(:moon_mean_anomaly) { Lunation::Angle.from_decimal_degrees(5.150833) } # (M')
    # (D)
    let(:moon_mean_elongation) do
      Lunation::Angle.from_decimal_degrees(113.842304)
    end
    # (L')
    let(:moon_mean_longitude) do
      Lunation::Angle.from_decimal_degrees(134.290182)
    end
    let(:sun_mean_anomaly) { Lunation::Angle.from_decimal_degrees(97.643514) } # (M)

    it { expect(calculate_moon_heliocentric_latitude).to eq(-3_229_126) }
  end

  describe "calculate_moon_ecliptic_longitude" do
    subject(:calculate_moon_ecliptic_longitude) do
      calculation.calculate_moon_ecliptic_longitude(
        moon_heliocentric_longitude: moon_heliocentric_longitude,
        moon_mean_longitude: moon_mean_longitude
      )
    end

    let(:moon_heliocentric_longitude) { -1_127_527 } # (Σl)
    # (L')
    let(:moon_mean_longitude) do
      Lunation::Angle.from_decimal_degrees(134.290182)
    end
    it { expect(calculate_moon_ecliptic_longitude.decimal_degrees).to eq(133.162655) }
  end

  describe "calculate_moon_ecliptic_latitude" do
    subject(:calculate_moon_ecliptic_latitude) do
      calculation.calculate_moon_ecliptic_latitude(
        moon_heliocentric_latitude: moon_heliocentric_latitude
      )
    end

    let(:moon_heliocentric_latitude) { -3_229_126 } # (Σb)

    it { expect(calculate_moon_ecliptic_latitude.decimal_degrees).to eq(-3.229126) }
  end

  describe "calculate_equatorial_horizontal_parallax" do
    subject(:calculate_equatorial_horizontal_parallax) do
      calculation.calculate_equatorial_horizontal_parallax(distance_between_earth_and_moon: distance_between_earth_and_moon)
    end

    let(:distance_between_earth_and_moon) { 368_409.7 } # (Σr) example 47.a, A.A. p. 342

    it {
      expect(calculate_equatorial_horizontal_parallax.decimal_degrees.round(5)).to eq(0.991990)
    } # A.A. p. 343
  end

  describe "calculate_nutation_in_longitude" do
    subject(:calculate_nutation_in_longitude) do
      calculation.calculate_nutation_in_longitude(
        moon_mean_elongation: moon_mean_elongation,
        sun_mean_anomaly: sun_mean_anomaly,
        moon_mean_anomaly: moon_mean_anomaly,
        moon_argument_of_latitude: moon_argument_of_latitude,
        longitude_of_ascending_node: longitude_of_ascending_node
      )
    end

    before do
      allow(calculation).to receive_messages(time: time)
    end

    let(:time) { -0.127296372348 } # T, 1987-04-10
    let(:moon_mean_elongation) { Lunation::Angle.from_decimal_degrees(136.9623) } # D
    let(:sun_mean_anomaly) { Lunation::Angle.from_decimal_degrees(94.9792) } # M
    let(:moon_mean_anomaly) { Lunation::Angle.from_decimal_degrees(229.2784) } # M'
    # F
    let(:moon_argument_of_latitude) do
      Lunation::Angle.from_decimal_degrees(143.4079)
    end
    # Omega
    let(:longitude_of_ascending_node) do
      Lunation::Angle.from_decimal_degrees(11.2531)
    end
    it {
      expect(calculate_nutation_in_longitude.decimal_arcseconds.round(3)).to eq(-3.788)
    }
  end

  describe "calculate_moon_apparent_ecliptic_longitude" do
    subject(:calculate_moon_apparent_ecliptic_longitude) do
      calculation.calculate_moon_apparent_ecliptic_longitude(
        moon_ecliptic_longitude: moon_ecliptic_longitude,
        nutation_in_longitude: nutation_in_longitude
      )
    end

    # example 47.a A.A. p. 343
    # (λ)
    let(:moon_ecliptic_longitude) do
      Lunation::Angle.from_decimal_degrees(133.162655)
    end
    # (Δψ)
    let(:nutation_in_longitude) do
      Lunation::Angle.from_decimal_arcseconds(16.595)
    end
    it {
      expect(calculate_moon_apparent_ecliptic_longitude.decimal_degrees.round(6)).to eq(133.167265)
    } # A.A. p. 343
  end

  describe "calculate_sun_ecliptic_longitude" do
    subject(:calculate_sun_ecliptic_longitude) do
      calculation.calculate_sun_ecliptic_longitude(
        sun_true_longitude: sun_true_longitude,
        longitude_of_ascending_node: longitude_of_ascending_node
      )
    end

    # ☉
    let(:sun_true_longitude) do
      Lunation::Angle.from_decimal_degrees(199.90988)
    end
    # Omega
    let(:longitude_of_ascending_node) do
      Lunation::Angle.from_decimal_degrees(264.65)
    end
    # example 25.a A.A. p. 165
    it {
      expect(calculate_sun_ecliptic_longitude.decimal_degrees.round(5)).to eq(199.90895)
    }
  end

  describe "calculate_sun_mean_longitude" do
    subject(:calculate_sun_mean_longitude) do
      calculation.calculate_sun_mean_longitude
    end

    before { allow(calculation).to receive_messages(time: time) }

    let(:time) { -0.072183436 } # T, 1992-10-13 0h TD

    # example 25.a A.A. p. 165
    it {
      expect(calculate_sun_mean_longitude.decimal_degrees.round(5)).to eq(201.80720)
    }
  end

  describe "calculate_sun_true_longitude" do
    subject(:calculate_sun_true_longitude) do
      calculation.calculate_sun_true_longitude(
        sun_mean_longitude: sun_mean_longitude,
        sun_equation_of_center: sun_equation_of_center
      )
    end

    # L0
    let(:sun_mean_longitude) do
      Lunation::Angle.from_decimal_degrees(201.80720)
    end
    # C
    let(:sun_equation_of_center) do
      Lunation::Angle.from_decimal_degrees(-1.89732, normalize: false)
    end
    # example 25.a A.A. p. 165
    it {
      expect(calculate_sun_true_longitude.decimal_degrees.round(5)).to eq(199.90988)
    }
  end

  describe "calculate_nutation_in_obliquity" do
    subject(:calculate_nutation_in_obliquity) do
      calculation.calculate_nutation_in_obliquity(
        moon_mean_elongation: moon_mean_elongation,
        sun_mean_anomaly: sun_mean_anomaly,
        moon_mean_anomaly: moon_mean_anomaly,
        moon_argument_of_latitude: moon_argument_of_latitude,
        longitude_of_ascending_node: longitude_of_ascending_node
      )
    end

    before do
      allow(calculation).to receive_messages(time: time)
    end

    # example 22.a A.A. p. 148
    let(:time) { -0.127296372348 } # 1987-04-10 0h TD
    # (D) A.A. p. 148
    let(:moon_mean_elongation) do
      Lunation::Angle.from_decimal_degrees(136.9623)
    end
    # (M) A.A. p. 148
    let(:sun_mean_anomaly) do
      Lunation::Angle.from_decimal_degrees(94.9792)
    end
    # (M') A.A. p. 148
    let(:moon_mean_anomaly) do
      Lunation::Angle.from_decimal_degrees(229.2784)
    end
    # (F) A.A. p. 148
    let(:moon_argument_of_latitude) do
      Lunation::Angle.from_decimal_degrees(143.4079)
    end
    # (Ω) A.A. p. 148
    let(:longitude_of_ascending_node) do
      Lunation::Angle.from_decimal_degrees(11.2531)
    end
    it {
      expect(calculate_nutation_in_obliquity.decimal_arcseconds.round(3)).to eq(9.443)
    }
  end

  # (Ω) A.A. p. 148
  describe "calculate_longitude_of_ascending_node" do
    subject(:calculate_longitude_of_ascending_node) do
      calculation.calculate_longitude_of_ascending_node
    end

    before { allow(calculation).to receive_messages(time: time) }

    # example 22.a A.A. p. 148
    let(:time) { -0.127296372348 } # 1987-04-10 0h TD

    # (Δε) A.A. p. 148
    it {
      expect(calculate_longitude_of_ascending_node.decimal_degrees.round(4)).to eq(11.2531)
    }
  end

  describe "calculate_longitude_of_ascending_node_low_precision" do
    subject(:calculate_longitude_of_ascending_node_low_precision) do
      calculation.calculate_longitude_of_ascending_node_low_precision
    end

    before { allow(calculation).to receive_messages(time: time) }

    # example 25.a A.A. p. 165
    let(:time) { -0.072183436 } # 1992-10-13 0h TD

    # (Ω) A.A. p. 165
    it {
      expect(calculate_longitude_of_ascending_node_low_precision.decimal_degrees.round(2)).to eq(264.65)
    }
  end

  describe "calculate_mean_obliquity_of_ecliptic" do
    subject(:calculate_mean_obliquity_of_ecliptic) do
      calculation.calculate_mean_obliquity_of_ecliptic
    end

    before do
      allow(calculation).to receive_messages(
        time_myriads: time_myriads
      )
    end

    # example 22.a A.A. p. 148
    let(:time_myriads) { -0.00127296372348 } # (U)

    it { expect(calculate_mean_obliquity_of_ecliptic.degrees).to eq(23) }
    it { expect(calculate_mean_obliquity_of_ecliptic.arcminutes).to eq(26) }
    it {
      expect(calculate_mean_obliquity_of_ecliptic.decimal_arcseconds.round(3)).to eq(27.407)
    }
  end

  describe "calculate_obliquity_of_ecliptic" do
    subject(:calculate_obliquity_of_ecliptic) do
      calculation.calculate_obliquity_of_ecliptic(
        mean_obliquity_of_ecliptic: mean_obliquity_of_ecliptic,
        nutation_in_obliquity: nutation_in_obliquity
      )
    end

    # (ε0)
    let(:mean_obliquity_of_ecliptic) do
      Lunation::Angle.from_decimal_degrees(23.440946)
    end
    let(:nutation_in_obliquity) { Lunation::Angle.from_decimal_arcseconds(9.443) } # (Δε)

    # converted from 23deg26'36".850 (example 22.a A.A. p. 148)
    it { expect(calculate_obliquity_of_ecliptic.degrees).to eq(23) }
    it { expect(calculate_obliquity_of_ecliptic.arcminutes).to eq(26) }
    it {
      expect(calculate_obliquity_of_ecliptic.decimal_arcseconds.round(3)).to eq(36.849)
    }
  end

  describe "calculate_corrected_obliquity_of_ecliptic" do
    subject(:calculate_corrected_obliquity_of_ecliptic) do
      calculation.calculate_corrected_obliquity_of_ecliptic(
        mean_obliquity_of_ecliptic: mean_obliquity_of_ecliptic,
        longitude_of_ascending_node: longitude_of_ascending_node
      )
    end

    # (ε0)
    let(:mean_obliquity_of_ecliptic) do
      Lunation::Angle.from_degrees(
        degrees: 23,
        arcminutes: 26,
        decimal_arcseconds: 24.83
      )
    end
    # (omega)
    let(:longitude_of_ascending_node) do
      Lunation::Angle.from_decimal_degrees(264.65)
    end
    # example 25.a, A.A. p. 165
    it {
      expect(calculate_corrected_obliquity_of_ecliptic.decimal_degrees.round(5)).to eq(23.43999)
    }
  end

  describe "calculate_moon_right_ascension" do
    subject(:calculate_moon_right_ascension) do
      calculation.calculate_moon_right_ascension(
        moon_apparent_ecliptic_longitude: moon_apparent_ecliptic_longitude,
        obliquity_of_ecliptic: obliquity_of_ecliptic,
        moon_ecliptic_latitude: moon_ecliptic_latitude
      )
    end

    context "when example 13.a (A.A. p. 95)" do
      # λ
      let(:moon_apparent_ecliptic_longitude) do
        Lunation::Angle.from_decimal_degrees(113.215630)
      end
      # ε
      let(:obliquity_of_ecliptic) do
        Lunation::Angle.from_decimal_degrees(23.4392911)
      end
      # β
      let(:moon_ecliptic_latitude) do
        Lunation::Angle.from_decimal_degrees(6.684170)
      end
      it {
        expect(calculate_moon_right_ascension.decimal_degrees.round(6)).to eq(116.328942)
      }
    end

    context "when example 47.a (A.A. p. 343)" do
      # apparent λ
      let(:moon_apparent_ecliptic_longitude) do
        Lunation::Angle.from_decimal_degrees(133.167265)
      end
      # ε
      let(:obliquity_of_ecliptic) do
        Lunation::Angle.from_decimal_degrees(23.440636)
      end
      # β
      let(:moon_ecliptic_latitude) do
        Lunation::Angle.from_decimal_degrees(-3.229126)
      end
      it {
        expect(calculate_moon_right_ascension.decimal_degrees.round(6)).to eq(134.688470)
      }
    end
  end

  describe "calculate_sun_right_ascension" do
    subject(:calculate_sun_right_ascension) do
      calculation.calculate_sun_right_ascension(
        corrected_obliquity_of_ecliptic: corrected_obliquity_of_ecliptic,
        sun_ecliptic_longitude: sun_ecliptic_longitude
      )
    end

    # ε
    let(:corrected_obliquity_of_ecliptic) do
      Lunation::Angle.from_decimal_degrees(23.43999)
    end
    # λ
    let(:sun_ecliptic_longitude) do
      Lunation::Angle.from_decimal_degrees(199.90895)
    end
    # example 25.a, A.A. p. 165
    it {
      expect(calculate_sun_right_ascension.decimal_degrees.round(5)).to eq(198.38083)
    }
  end

  describe "calculate_moon_declination" do
    subject(:calculate_moon_declination) do
      calculation.calculate_moon_declination(
        moon_apparent_ecliptic_longitude: moon_apparent_ecliptic_longitude,
        obliquity_of_ecliptic: obliquity_of_ecliptic,
        moon_ecliptic_latitude: moon_ecliptic_latitude
      )
    end

    # apparent λ
    let(:moon_apparent_ecliptic_longitude) do
      Lunation::Angle.from_decimal_degrees(133.167265)
    end
    # ε
    let(:obliquity_of_ecliptic) do
      Lunation::Angle.from_decimal_degrees(23.440636)
    end
    # β
    let(:moon_ecliptic_latitude) do
      Lunation::Angle.from_decimal_degrees(-3.229126)
    end
    it {
      expect(calculate_moon_declination.decimal_degrees.round(6)).to eq(13.768368)
    }
  end

  describe "calculate_moon_mean_elongation_from_sun" do
    subject(:calculate_moon_mean_elongation_from_sun) do
      calculation.calculate_moon_mean_elongation_from_sun
    end

    before { allow(calculation).to receive(:time).and_return(time) }

    let(:time) { -0.127296372348 } # 1987-04-10 0h TD

    it {
      expect(calculate_moon_mean_elongation_from_sun.decimal_degrees.round(4)).to eq(136.9623)
    }
  end

  describe "calculate_moon_position_angle_of_bright_limb" do
    subject(:calculate_moon_position_angle_of_bright_limb) do
      calculation.calculate_moon_position_angle_of_bright_limb(
        moon_declination: Lunation::Angle.from_decimal_degrees(13.7684),
        moon_right_ascension: Lunation::Angle.from_decimal_degrees(134.6885),
        sun_declination: Lunation::Angle.from_decimal_degrees(8.6964),
        sun_right_ascension: Lunation::Angle.from_decimal_degrees(20.6579)
      )
    end

    it "calculates the result correctly" do
      expect(calculate_moon_position_angle_of_bright_limb.decimal_degrees.round(1))
        .to eq(285.0)
    end
  end
end
