require 'nokogiri'

module Nokogiri

  module XML

    class Element

      def match?(other, matcher)
        @matcher = matcher
        other_elem = other.at_xpath(path)
        unless other_elem
          @matcher.record(self, false, "not found")
          return false
        end
        children_match?(other_elem) & attributes_match?(other_elem)
      end

      private

        def children_match?(other)
          match = children.size == other.children.size
          @matcher.record(self, match, "expected #{children.size} children, got #{other.children.size}")
          match
        end

        def attributes_match?(other)
          match = attributes.size == other.attributes.size
          if match
            attributes.values.each do |attr|
              match = match & attr.match?(other, @matcher)
            end
          else
            @matcher.record(self, match, "expected #{attributes.size} attributes, got #{other.attributes.size}")
          end
          match
        end

    end

    class Document
      
      def match?(other, matcher = nil)
        true
      end
      
    end

    class Text
      
      def match?(other, matcher)
        @matcher = matcher
        other_elem = other.at_xpath(path)
        unless other_elem
          @matcher.record(self, false, "not found")
          return false
        end

        custom_matcher = matcher.custom_matchers[path]
        match = custom_matcher ? custom_matcher.call(other_elem) : (content == other_elem.content)
        @matcher.record(self, match, "expected '#{content}', got '#{other_elem.content}'")
        match
      end
      
    end

    class Attr
      def match?(other, matcher)
        other_elem = other.at_xpath(path)
        unless other_elem
          matcher.record(self, false, "not found")
          return false
        end
        
        custom_matcher = matcher.custom_matchers[path]
        match = custom_matcher ? custom_matcher.call(other_elem) : (value == other_elem.value)
        matcher.record(self, match, "expected '#{value}', got '#{other_elem.value}'")
        match
      end
    end

  end

end
