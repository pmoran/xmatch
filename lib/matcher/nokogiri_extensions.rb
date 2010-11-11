require 'nokogiri'

module Nokogiri

  module XML

    class Element
      
      def match?(other, messages = {})
        @messages = messages
        children_match?(other) &&
          name_matches?(other) &&
          attributes_match?(other)
      end

      private

        def children_match?(other)
          match = children.size == other.children.size
          @messages[path] = "expected #{children.size} children, got #{other.children.size}" unless match
          match
        end

        def name_matches?(other)
          match = name == other.name
          @messages[path] = "expected element '#{name}', got '#{other.name}'" unless match
          match
        end

        def attributes_match?(other)
          match = attributes.size == other.attributes.size
          if match
            attributes.each_pair do |name, lhs|
              match = match && lhs.match?(other.attributes[name], @messages)
            end
          else
            @messages[path] = "expected #{attributes.size} attributes, got #{other.attributes.size}"
          end
          match
        end

    end

    class Document
      def match?(other, messages = {})
        true
      end
    end

    class Text
      def match?(other, messages = {})
        match = content == other.content
        messages[path] = "expected '#{content}', got '#{other.content}'" unless match
        match
      end
    end

    class Attr
      def match?(other, messages = {})
        if other.nil?
          messages[parent.path] = "expected attribute missing"
          return false
        end
        match = value == other.value
        messages[parent.path] = "attribute '#{name}' expected '#{value}', got '#{other.value}'" unless match
        match
      end
    end

  end

end
