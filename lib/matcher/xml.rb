require 'matcher/nokogiri_extensions'
require 'ostruct'

module Matcher

  class Xml

    attr_reader :lhs, :rhs

    def initialize(lhs)
      @lhs = parse(lhs)
      @results = {}
    end

    def match(actual)
      @results.clear
      @rhs = parse(actual)
      compare(@lhs, @rhs)
    end

    def record(path, result, message = nil)
      @results[path] = OpenStruct.new(:result => result, :message => message)
    end

    def result_for(path)
      @results[path].result ? "matched" : "mismatched"
    end

    def matches
      match_info = {}
      @results.each_pair { |k, v| match_info[k] = '' if v.result }
      match_info
    end
    
    def mismatches
      match_info = {}
      @results.each_pair { |k, v| match_info[k] = v.message unless v.result }
      match_info
    end

    private

      def parse(xml)
        xml_as_string = xml.instance_of?(Nokogiri::XML::Document) ? xml.to_xml : xml
        Nokogiri::XML(xml_as_string) { |config| config.noblanks }
      end

      def compare(lhs, rhs)
        return false unless lhs && rhs
        match = lhs.match?(rhs, self)
        lhs.children.each_with_index do |child, i|
          match = match & compare(child, rhs.children[i])
        end
        match
      end

  end

end
