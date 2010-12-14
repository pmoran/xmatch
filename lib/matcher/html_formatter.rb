require 'erb'
require 'fileutils'
require 'ostruct'

module Matcher

  class HtmlFormatter

    TEMPLATE = File.dirname(__FILE__) + '/xmatch.html.erb'

    def initialize(matcher, args = {})
      @matcher = matcher
      @report_dir = args[:report_dir] || '/tmp/xmatch'
      @generated_xml_dir = File.join(@report_dir, "generated_xml")
      @prefix = args[:prefix]
    end

    def format
      match_data = []
      @matcher.lhs.traverse do |elem|
        next if elem.xml?
        match_data << match_info_for(elem)
        elem.attributes.values.each { | attr | match_data << match_info_for(attr) }
      end
      create_report(match_data.sort {|a, b| a.line <=> b.line})
    end

    private

      def create_report(match_data)
        FileUtils.mkdir_p(@generated_xml_dir)
        html = generate_html(match_data, create_expected_file, create_actual_file)
        File.open(File.join(@report_dir, prefixed("xmatch.html")), 'w') { |f|  f.write(html) }
      end

      def match_info_for(elem)
        info = @matcher.results[elem.path]
        result = @matcher.result_for(elem.path)
        OpenStruct.new(:result => result,
                       :line => elem.line,
                       :path => elem.path,
                       :expected => info ? info.expected : Matcher::Xml::EXISTENCE,
                       :actual => info ? info.actual : Matcher::Xml::UNMATCHED,
                       :custom_matched => info ? info.was_custom_matched : false)
      end

      def generate_html(match_info, expected_filename, actual_filename)
        xml = @matcher
        completedness = compute_completedness
        html = ERB.new(File.read(TEMPLATE))
        html.result(binding)
      end

      def compute_completedness
        (@matcher.matches.size.to_f / @matcher.results.size.to_f * 100).to_i
      end

      def create_expected_file
        write_xml("expected", @matcher.lhs)
      end

      def create_actual_file
        write_xml("actual", @matcher.rhs)
      end

      def write_xml(name, xml)
        path = File.join(@generated_xml_dir,  prefixed("#{name}-#{Time.now.to_i}.xml"))
        File.open(path, 'w') { |f| f.write(xml)}
        path
      end

      def prefixed(name)
        @prefix ? "#{@prefix}-#{name}" : name
      end

  end

end
