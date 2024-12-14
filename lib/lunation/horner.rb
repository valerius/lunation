module Lunation
  class Horner
    def initialize(variable, constants)
      @variable = variable
      @constants = constants
    end

    def compute
      @constants.reverse_each.each_with_index.inject(0.0) do |sum, (constant, index)|
        if index.zero?
          constant
        else
          constant + @variable * sum
        end
      end
    end

    class << self
      def compute(variable, constants)
        new(variable, constants).compute
      end
    end
  end
end
