require 'nokogiri'

module Nokogiri

  module XML

    class Node

      def match?(other, matcher)
        matching(other, matcher) ? true : false
      end

      def matching(other, matcher)
        other_elem = other.at_xpath(path)
        matcher.record(self.path, false, Matcher::Xml::EXISTENCE, Matcher::Xml::NOT_FOUND) unless other_elem
        other_elem
      end

    end

    class Element

      def match?(other, matcher)
        @matcher = matcher
        return false unless other_elem = matching(other, matcher)
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
        return false unless other_elem = matching(other, matcher)
        matcher.evaluate(path, content, other_elem.content)
      end

    end

    class Attr

      def match?(other, matcher)
        return false unless other_elem = matching(other, matcher)
        matcher.evaluate(path, value, other_elem.value)
      end

    end

  end

end
