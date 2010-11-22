require 'erb'
require 'fileutils'
require 'ostruct'

module Matcher

  class HtmlFormatter

    TEMPLATE = File.dirname(__FILE__) + '/xmatch.html.erb'

    def initialize(matcher, args = {})
      @matcher = matcher
      @report_dir = args[:report_dir] || '/tmp/xmatch'
      @prefix = args[:prefix]
    end

    def format
      match_data = []
      @matcher.lhs.traverse do |elem|
        next if elem.xml?
        match_data << match_info_for(elem)
        elem.attributes.values.each { | attr | match_data << match_info_for(attr) }
      end
      match_data.sort! {|a, b| a.line <=> b.line}

      FileUtils.mkdir_p(@report_dir)
      filename = @prefix ? "#{@prefix}-xmatch.html" : "xmatch.html"
      File.open(File.join(@report_dir, filename), 'w') { |f|  f.write(generate_html(match_data)) }
    end

    private

      def match_info_for(elem)
        info = @matcher.results[elem.path]
        result = @matcher.result_for(elem.path)
        OpenStruct.new(:result => result,
                       :line => elem.line,
                       :path => elem.path,
                       :expected => info ? info.expected : Matcher::Xml::EXISTENCE,
                       :actual => info ? info.actual : Matcher::Xml::UNMATCHED)
      end

      def generate_html(data)
        actual_filename = create_actual_file
        expected_filename = create_expected_file
        xml = @matcher
        completedness = compute_completedness
        match_info = data
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
        file_name = "#{name}-#{Time.now.to_i}.xml"
        file_name = "#{@prefix}-#{file_name}" if @prefix
        File.open(File.join(@report_dir, file_name), 'w') { |f| f.write(xml)}
        file_name
      end

  end

end
