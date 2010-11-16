require 'matcher/nokogiri_extensions'

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
      if result
        @results[path] = result
      else
        @results[path] = message
      end
    end

    def result_for(path)
      if (@results[path] == true)
        return "matched"
      else
        return "mismatched"
      end
    end

    def matches
      results(true)
    end

    def mismatches
      mismatches = {}
      @results.each_pair {|k, v| mismatches[k] = v unless v == true }
      mismatches
    end

    private

      def results(success)
        requested_results = {}
        @results.each_pair {|k, v| requested_results[k] = v if v == success }
        requested_results
      end

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
