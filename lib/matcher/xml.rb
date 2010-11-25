require 'matcher/nokogiri_extensions'
require 'ostruct'

module Matcher

  class Xml
    
    NOT_FOUND = "[Not found]"
    EXISTENCE = "[Existence]"
    UNMATCHED = "[Unmatched]"

    attr_reader :lhs, :rhs, :custom_matchers, :results

    def initialize(lhs, custom_matchers = {})
      @lhs = parse(lhs)
      @custom_matchers = custom_matchers
      @results = {}
    end

    def match_on(path, &blk)
      @custom_matchers[path] = blk
    end
    
    alias_method :on, :match_on

    def match(actual)
      @results.clear
      @rhs = parse(actual)
      compare(@lhs, @rhs)
    end

    def record(path, result, expected, actual)
      # support 0 as true (for regex matches)
      r = (!result || result.nil?) ? false : true
      was_custom_matched = @custom_matchers[path] ? true : false
      @results[path] = OpenStruct.new(:result => r, :expected => expected, :actual => actual, :was_custom_matched => was_custom_matched)
    end

    def result_for(path)
      return "matched" if matches[path]
      return "mismatched" if mismatches[path]
      "unmatched"
    end
    
    def matches
      results_that_are(true)
    end
    
    def mismatches
      results_that_are(false)
    end

    private
    
      def results_that_are(value)
        match_info = {}
        @results.each { |path, info| match_info[path] = info if info.result == value}
        match_info
      end

      def parse(xml)
        xml_as_string = xml.instance_of?(Nokogiri::XML::Document) ? xml.to_xml : xml
        Nokogiri::XML(xml_as_string) { |config| config.noblanks }
      end

      def compare(lhs, rhs)
        return false unless lhs && rhs
        match = true
        lhs.traverse { |node| match = match & node.match?(rhs, self) }
        match
      end

  end

end
