require 'matcher/nokogiri_extensions'

module Matcher

  class Xml

    attr_reader :lhs, :rhs, :mismatches

    def initialize(lhs)
      @lhs = parse(lhs)
      @mismatches = {}
    end

    def match(rhs)
      @mismatches.clear
      @rhs = parse(rhs)
      compare(@lhs, @rhs)
    end

    private

      def parse(xml)
        return xml if xml.instance_of?(Nokogiri::XML::Document)
        Nokogiri::XML(xml) { |config| config.noblanks }
      end

      def compare(lhs, rhs)
        return false unless lhs && rhs
        match = lhs.match?(rhs, @mismatches)
        lhs.children.each_with_index do |child, i|
          match = match & compare(child, rhs.children[i])
        end
        match
      end

  end

end

