module Gyoku
  module XMLKey
    class << self

      # Converts a given +object+ with +options+ to an XML key.
      def create(key, options = {})
        xml_key = chop_special_characters key.to_s

        if unqualified = unqualify?(xml_key)
          xml_key = xml_key.split(":").last
        end

        xml_key = key_converter(options).call(xml_key) if Symbol === key

        if !unqualified && qualify?(options) && !xml_key.include?(":")
          xml_key = "#{options[:namespace]}:#{xml_key}"
        end

        xml_key
      end

    private

      def camel_case(string)
        string.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
      end

      def lower_camel_case(string)
        string[0].chr.downcase + camel_case(string)[1..-1]
      end

      def formulas
        {
          :lower_camelcase => lambda { |key| lower_camel_case(key) },
          :camelcase       => lambda { |key| camel_case(key) },
          :upcase          => lambda { |key| key.upcase },
          :none            => lambda { |key| key }
        }
      end

      # Returns the formula for converting Symbol keys.
      def key_converter(options)
        key_converter = options[:key_converter] || :lower_camelcase
        formulas[key_converter]
      end

      # Chops special characters from the end of a given +string+.
      def chop_special_characters(string)
        ["!", "/"].include?(string[-1, 1]) ? string.chop : string
      end

      # Returns whether to remove the namespace from a given +key+.
      def unqualify?(key)
        key[0, 1] == ":"
      end

      # Returns whether to namespace all keys (elementFormDefault).
      def qualify?(options)
        options[:element_form_default] == :qualified && options[:namespace]
      end

    end
  end
end
