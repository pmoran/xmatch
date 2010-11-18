require 'nokogiri'

module Nokogiri

  module XML

    class Element

      def match?(other, matcher)
        @matcher = matcher
        children_match?(other) &&
          name_matches?(other) &&
          attributes_match?(other)
      end

      private

        def children_match?(other)
          match = children.size == other.children.size
          @matcher.record(path, match, "expected #{children.size} children, got #{other.children.size}")
          match
        end

        def name_matches?(other)
          match = name == other.name
          @matcher.record(path, match, "expected element '#{name}', got '#{other.name}'")
          match
        end

        def attributes_match?(other)
          match = attributes.size == other.attributes.size
          if match
            attributes.each_pair do |name, lhs|
              match = match && lhs.match?(other.attributes[name], @matcher)
            end
          else
            @matcher.record(path, match, "expected #{attributes.size} attributes, got #{other.attributes.size}")
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
        custom_matcher = matcher.custom_matchers[path]
        match = custom_matcher ? custom_matcher.call(other) : (content == other.content)        
        matcher.record(path, match, "expected '#{content}', got '#{other.content}'")
        match
      end
    end

    class Attr
      def match?(other, matcher)
        if other.nil?
          # record parent's path: nokogiri's traverse won't find attrs as children, so formatter won't report on them
          matcher.record(parent.path, false, "expected attribute missing")
          return false
        end

        custom_matcher = matcher.custom_matchers[path]
        match = custom_matcher ? custom_matcher.call(other) : (value == other.value)
        matcher.record(parent.path, match, "attribute '#{name}' expected '#{value}', got '#{other.value}'")
        match
      end
    end

  end

end
