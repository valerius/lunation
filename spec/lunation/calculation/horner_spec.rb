RSpec.describe Lunation::Calculation::Horner do
  # Method to calculate Moon mean_elongation (D) (47.2, A.A. p. 338)
  #
  specify "it implements Horner's method correctly" do
    variable = -0.077221081451
    constants = [
      297.8501921,
      445_267.1114034,
      -0.0018819,
      1 / 545_868.0,
      -1 / 113_065_000.0
    ]
    result = described_class.compute(variable, constants) % 360

    expect(result.round(6)).to eq(113.842304)
  end
end
