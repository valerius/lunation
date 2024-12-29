# Lunation

Lunation provides a library of algorithms for computing positions and ephemeris of
celestial objects using Jean Meeus's astronomical algorithms.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add lunation

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install lunation

## Usage

### Basic Usage

```ruby
require "lunation"

calculation = Lunation::Calculation.new(DateTime.parse("2024-01-01 00:01"))
calculation.moon_illuminated_fraction # 0.7803
calculation.to_h # {...} Full report as Hash
calculation.to_s # DATE AND TIME (UT)... Full report as String
```

### Available Functions

| Name                                                   | Symbol        | Description                                               | Unit                               | Reference                                            |
| ------------------------------------------------------ | ------------- | --------------------------------------------------------- | ---------------------------------- | ---------------------------------------------------- |
| `corrected_obliquity_of_ecliptic`                      | `corrected ε` | Corrected true obliquity of the ecliptic                  | Angle                              | A.A. p. 165                                          |
| `correction_eccentricity_of_earth`                     | `E`           | Earth eccentricity                                        | -                                  | A.A. p. 338 (47.6)                                   |
| `correction_jupiter`                                   | `A2`          | Jupiter correction                                        | Angle                              | A.A. p. 338                                          |
| `correction_latitude`                                  | `A3`          | Latitude correction                                       | Angle                              | A.A. p. 338                                          |
| `correction_venus`                                     | `A1`          | Venus correction                                          | Angle                              | A.A. p. 338                                          |
| `delta_t`                                              | `ΔT`          | Difference between TD and UT                              | Seconds                            | https://eclipse.gsfc.nasa.gov/SEcat5/deltatpoly.html |
| `distance_between_earth_and_moon`                      | `Δ`           | Earth-moon distance                                       | Kilometers (KM)                    | A.A. p. 342                                          |
| `distance_between_earth_and_sun_in_astronomical_units` | `R`           | Distance between the earth and the sun                    | Astronomical Units (AU)            | A.A. p. 164 (25.5)                                   |
| `distance_between_earth_and_sun_in_kilometers`         | `R`           | Distance between the earth and the sun                    | Kilometers (KM)                    | A.A. p. 164 (25.5)                                   |
| `dynamical_time`                                       | `TD`          | Dynamical Time                                            | ISO 8601 Date and time with offset | A.A. p. 77                                           |
| `earth_orbit_eccentricity`                             | `e`           | Eccentricity of the earth's orbit                         | Astronomical Units (AU)            | A.A. p. 163 (25.4)                                   |
| `ecliptic_latitude_of_earth_using_vsop87`              | `B`           | Ecliptical latitude of the earth                          | Angle                              | A.A. p. 219, (32.2)                                  |
| `ecliptic_longitude_of_earth_using_vsop87`             | `L`           | Ecliptical longitude of the earth                         | Angle                              | A.A. p. 219, (32.2)                                  |
| `equatorial_horizontal_parallax`                       | `π`           | Moon equitorial horizontal parallax                       | Angle                              | A.A. p. 337                                          |
| `julian_ephemeris_day`                                 | `JDE`         | Julian Ephemeris Day                                      | Days, expressed as Float           | A.A. p. 59                                           |
| `longitude_of_ascending_node_low_precision`            | `Ω`           | Longitude of the ascending node of the Moon's mean orbit  | Angle                              | A.A. p. 164                                          |
| `longitude_of_ascending_node`                          | `Ω`           | Longitude of the ascending node of the Moon's mean orbit  | Angle                              | A.A. p. 144                                          |
| `mean_obliquity_of_ecliptic`                           | `ε0`          | Mean obliquity of the ecliptic                            | Angle                              | A.A. p. 147 (22.3)                                   |
| `moon_apparent_ecliptic_longitude`                     | `apparent λ`  | Moon apparent longitude                                   | Angle                              | A.A. p. 343                                          |
| `moon_argument_of_latitude_high_precision`             | `F`           | Moon argument of latitude (high precision)                | Angle                              | A.A. p. 338 (47.5)                                   |
| `moon_argument_of_latitude`                            | `F`           | Moon argument of latitude                                 | Angle                              | A.A. p. 144                                          |
| `moon_declination`                                     | `δ`           | Geocentric (apparent) declination of the moon             | Angle                              | A.A. p. 93 (13.4)                                    |
| `moon_ecliptic_latitude`                               | `β`           | Ecliptical latitude                                       | Angle                              | A.A. p. 342                                          |
| `moon_ecliptic_longitude`                              | `λ`           | Ecliptical longitude                                      | Angle                              | A.A. p. 342                                          |
| `moon_elongation_from_sun`                             | `ψ`           | Geocentric elongation of the moon                         | Angle                              | A.A. p. 345 (48.2)                                   |
| `moon_heliocentric_distance`                           | `Σr`          | Moon heliocentric distance                                | 1000 kilometers                    | A.A. p. 338                                          |
| `moon_heliocentric_latitude`                           | `Σb`          | Moon heliocentric latitude                                | Degrees (decimal)                  | A.A. p. 338                                          |
| `moon_heliocentric_longitude`                          | `Σl`          | Moon heliocentric longitude                               | Degrees (decimal)                  | A.A. p. 338                                          |
| `moon_illuminated_fraction`                            | `k`           | Illuminated fraction of the moon                          | Fraction (decimal)                 | A.A. p. 345 (48.1)                                   |
| `moon_mean_anomaly_high_precision`                     | `M'`          | Moon mean_anomaly (high precision)                        | Angle                              | A.A. p. 338 (47.4)                                   |
| `moon_mean_anomaly`                                    | `M'`          | Moon mean_anomaly                                         | Angle                              | A.A. p. 149                                          |
| `moon_mean_elongation_from_sun`                        | `D`           | Mean elongation of the moon from the sun                  | Angle                              | A.A. p. 144                                          |
| `moon_mean_elongation_from_sun_high_precision`         | `D`           | Mean elongation of the moon from the sun (high precision) | Angle                              | A.A. p. 338 (47.2)                                   |
| `moon_mean_longitude`                                  | `L'`          | Moon mean_longitude                                       | Angle                              | A.A. p. 338 (47.1)                                   |
| `moon_phase_angle`                                     | `i`           | Phase angle of the moon                                   | Angle                              | A.A. p. 346 (48.3)                                   |
| `moon_position_angle_of_bright_limb`                   | `χ`           | Position angle of the moon's bright limb                  | Angle                              | A.A. p. 346 (48.5)                                   |
| `moon_right_ascension`                                 | `α`           | Geocentric (apparent) right ascension of the moon         | Angle                              | A.A. p. 93 (13.3)                                    |
| `nutation_in_longitude`                                | `Δψ`          | Nutation in longitude                                     | Angle                              | A.A. p. 144                                          |
| `nutation_in_obliquity`                                | `Δε`          | Nutation in obliquity                                     | Angle                              | A.A. p. 144                                          |
| `obliquity_of_ecliptic`                                | `ε`           | True obliquity of the ecliptic                            | Angle                              | A.A. p. 147                                          |
| `radius_vector_of_earth_using_vsop87`                  | `R`           | Radius vector (distance to sun) of the earth              | Astronomical Units (AU)            | A.A. p. 219 (32.2)                                   |
| `sun_anomaly`                                          | `v`           | True anomaly of the sun                                   | Angle                              | A.A. p. 164                                          |
| `sun_declination`                                      | `δ0`          | Geocentric declination (of the sun)                       | Angle                              | A.A. p. 93 (13.4)                                    |
| `sun_ecliptic_longitude`                               | `apparent λ0` | Sun apparent longitude                                    | Angle                              | A.A. p. 169                                          |
| `sun_equation_of_center`                               | `C`           | Sun's equation of the center                              | Angle                              | A.A. p. 164                                          |
| `sun_mean_anomaly`                                     | `M`           | Sun mean_anomaly (version 1)                              | Angle                              | A.A. p. 144                                          |
| `sun_mean_anomaly2`                                    | `M`           | Sun mean_anomaly (version 2)                              | Angle                              | A.A. p. 163 (25.3)                                   |
| `sun_mean_longitude`                                   | `L0`          | Geometric mean longitude of the sun                       | Angle                              | A.A. p. 163 (25.2)                                   |
| `sun_right_ascension`                                  | `α0`          | Geocentric (apparent) right ascension of the sun          | Angle                              | A.A. p. 165 (25.6)                                   |
| `sun_true_longitude`                                   | `☉`          | True longitude of the sun                                 | Angle                              | A.A. p. 164                                          |
| `time_millennia`                                       | `t`           | Time, from the Epoch J2000.0                              | Millennia                          | A.A. p. 218 (32.1)                                   |
| `time_myriads`                                         | `U`           | Time, from the Epoch J2000.0                              | 10K years (myriads)                | A.A. p. 147                                          |
| `time`                                                 | `T`           | Time, from the Epoch J2000.0                              | Centuries                          | A.A. p. 143 (22.1)                                   |
A.A.: J. Meeus, Astronomical Algorithms, 2nd ed. Richmond, VA: Willmann-Bell, 1998

## Accuracy

A simple validation script was written for the `moon_illuminated_fraction` method (see `bin/validation`). The true values for the period of 1950 to 2050 were taken from the [JPL Horizons system](https://ssd.jpl.nasa.gov/horizons/app.html) (date of access: 2024-12-14). At the moment of the initial release of this Gem, the results are as follows:

- Mean Absolute Error (MAE): `0.000022`
- Mean Squared Error (MSE): `0.000000`
- Root Mean Squared Error (RMSE): `0.000050`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/valerius/lunation.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Copyright

Copyright (c) 2023 Ivo Kalverboer (see LICENSE).
