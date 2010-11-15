require 'matcher/nokogiri_extensions'

module Matcher

  class Xml

    attr_reader :lhs, :rhs

    def initialize(lhs)
      @lhs = parse(lhs)
      @results = {}
    end

    def match(rhs)
      @results.clear
      @rhs = parse(rhs)
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
        return xml if xml.instance_of?(Nokogiri::XML::Document)
        Nokogiri::XML(xml) { |config| config.noblanks }
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
