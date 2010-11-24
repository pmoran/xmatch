require 'nokogiri'

module Nokogiri

  module XML

    class Node
      
      def matching(other, matcher)
        other_elem = other.at_xpath(path)
        matcher.record(self.path, false, Matcher::Xml::EXISTENCE, Matcher::Xml::NOT_FOUND) unless other_elem
        other_elem
      end
    end

    class Document

      def match?(other, matcher)
        matching(other, matcher)
      end

    end

    class Element

      def match?(other, matcher)
        @matcher = matcher
        other_elem = matching(other, matcher)
        return false unless other_elem
        children_match?(other_elem) & attributes_match?(other_elem)
      end

      private

        def children_match?(other)
          match = children.size == other.children.size
          @matcher.record(self.path, match, "#{children.size} children", "#{other.children.size} children")
          match
        end

        def attributes_match?(other)
          match = attributes.size == other.attributes.size
          unless match
            @matcher.record(self.path, match, "#{attributes.size} attributes", "#{other.attributes.size} attributes")
            return false
          end

          attributes.values.each { |attr|  match = match & attr.match?(other, @matcher) }
          match
        end

    end

    class Text

      def match?(other, matcher)
        @matcher = matcher
        other_elem = matching(other, matcher)
        return false unless other_elem

        custom_matcher = matcher.custom_matchers[path]
        match = custom_matcher ? custom_matcher.call(other_elem.content) : (content == other_elem.content)
        @matcher.record(self.path, match, content, other_elem.content)
        match
      end

    end

    class Attr

      def match?(other, matcher)
        other_elem = matching(other, matcher)
        return false unless other_elem

        custom_matcher = matcher.custom_matchers[path]
        match = custom_matcher ? custom_matcher.call(other_elem.value) : (value == other_elem.value)
        matcher.record(self.path, match, value, other_elem.value)
        match
      end

    end

  end

end
