require 'erb'
require 'fileutils'
require 'ostruct'

module Matcher

  class HtmlFormatter

    TEMPLATE = File.dirname(__FILE__) + '/xmatch.html.erb'

    def initialize(matcher, args = {})
      @matcher = matcher
      @report_dir = args[:report_dir] || '/tmp/xmatch'
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
      File.open(File.join(@report_dir, "xmatch.html"), 'w') { |f|  f.write(generate_html(match_data)) }
    end

    private
      
      def match_info_for(elem)
        result = @matcher.result_for(elem.path)
        message = result == "unmatched" ? "Unmatched" : @matcher.mismatches[elem.path]
        OpenStruct.new(:result => result, :line => elem.line, :path => elem.path, :message => message)
      end
    
      def generate_html(data)
        actual_filename = create_actual_file
        expected_filename = create_expected_file
        xml = @matcher        
        match_info = data
        html = ERB.new(File.read(TEMPLATE))
        html.result(binding)        
      end
    
      def create_expected_file
        write_xml("expected.xml", @matcher.lhs)
      end

      def create_actual_file
        write_xml("actual.xml", @matcher.rhs)
      end

      def write_xml(name, xml)
        File.open(File.join(@report_dir, name), 'w') { |f| f.write(xml)}
        name
      end

      
      
  end

end
