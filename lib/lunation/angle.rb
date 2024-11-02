module Lunation
  class Angle
    attr_reader :radians, :decimal_degrees

    def initialize(
      radians: nil,
      decimal_degrees: nil,
      decimal_arcseconds: nil,
      arcminutes: nil,
      degrees: nil,
      hours: nil,
      minutes: nil,
      decimal_seconds: nil
    )
      @radians = radians
      @decimal_degrees = decimal_degrees
      @decimal_arcseconds = decimal_arcseconds
      @arcminutes = arcminutes
      @degrees = degrees
      @hours = hours
      @minutes = minutes
      @decimal_seconds = decimal_seconds
    end

    def decimal_arcminutes
      @decimal_arcminutes ||= (decimal_degrees - degrees) * 60
    end

    def decimal_arcseconds
      @decimal_arcseconds ||= ((decimal_arcminutes - arcminutes) * 60).round(6)
    end

    def degrees
      @degrees ||= decimal_degrees.to_i
    end

    def arcminutes
      @arcminutes ||= decimal_arcminutes.to_i
    end

    def decimal_hours
      @decimal_hours ||= decimal_degrees / 15.0
    end

    def decimal_minutes
      @decimal_minutes ||= (decimal_hours - hours) * 60
    end

    def decimal_seconds
      @decimal_seconds ||= ((decimal_minutes - minutes) * 60).round(6)
    end

    def hours
      @hours ||= decimal_hours.to_i
    end

    def minutes
      @minutes ||= decimal_minutes.to_i
    end

    def +(other)
      self.class.new(decimal_degrees: decimal_degrees + other.decimal_degrees)
    end

    class << self
      def from_radians(radians, normalize: true)
        new(
          radians: radians,
          decimal_degrees: radians_to_decimal_degrees(radians, normalize: normalize)
        )
      end

      def from_decimal_degrees(decimal_degrees, normalize: true)
        new(
          decimal_degrees: (normalize ? decimal_degrees % 360 : decimal_degrees).round(9),
          radians: decimal_degrees_to_radians(decimal_degrees, normalize: normalize)
        )
      end

      def from_degrees(degrees:, arcminutes:, decimal_arcseconds:, normalize: true)
        decimal_degrees = degrees_arcminutes_decimal_arcseconds_to_decimal_degrees(
          degrees,
          arcminutes,
          decimal_arcseconds,
          normalize: normalize
        )
        new(
          decimal_degrees: decimal_degrees,
          degrees: degrees,
          arcminutes: arcminutes,
          decimal_arcseconds: decimal_arcseconds
        )
      end

      def from_hours_minutes_decimal_seconds(
        hours:,
        minutes:,
        decimal_seconds:,
        normalize: true
      )
        decimal_degrees = hours_minutes_decimal_seconds_to_decimal_degrees(
          hours,
          minutes,
          decimal_seconds,
          normalize: normalize
        )
        new(
          decimal_degrees: decimal_degrees,
          hours: hours,
          minutes: minutes,
          decimal_seconds: decimal_seconds
        )
      end

      def from_decimal_arcseconds(decimal_arcseconds, normalize: true)
        decimal_degrees = decimal_arcseconds_to_decimal_degrees(
          decimal_arcseconds,
          normalize: normalize
        )
        new(decimal_degrees: decimal_degrees, decimal_arcseconds: decimal_arcseconds)
      end

      private def radians_to_decimal_degrees(radians, normalize: true)
        result = radians / Math::PI * 180
        (normalize ? result % 360 : result).round(9)
      end

      private def decimal_degrees_to_radians(decimal_degrees, normalize: true)
        result = (normalize ? decimal_degrees % 360 : decimal_degrees) * Math::PI / 180.0
        result.round(9)
      end

      private def degrees_arcminutes_decimal_arcseconds_to_decimal_degrees(
        degrees,
        arcminutes,
        decimal_arcseconds,
        normalize: true
      )
        result = degrees + arcminutes / 60.0 + decimal_arcseconds / 3600.0
        (normalize ? result % 360 : result).round(9)
      end

      private def hours_minutes_decimal_seconds_to_decimal_degrees(
        hours,
        minutes,
        decimal_seconds,
        normalize: true
      )
        result = hours * 15.0 + minutes / 4.0 + decimal_seconds / 240.0
        (normalize ? result % 360 : result).round(9)
      end

      private def decimal_arcseconds_to_decimal_degrees(
        decimal_arcseconds,
        normalize: true
      )
        result = decimal_arcseconds / 3600.0
        (normalize ? result % 360 : result).round(9)
      end
    end
  end
end
