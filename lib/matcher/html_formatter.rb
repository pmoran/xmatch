require 'erb'
require 'fileutils'

module Matcher

  class HtmlFormatter

    TEMPLATE = File.dirname(__FILE__) + '/xmatch.html.erb'

    def initialize(matcher, args = {})
      @matcher = matcher
      @report_dir = args[:report_dir] || File.dirname(__FILE__) + '/../../reports'
    end

    def format
      FileUtils.mkdir_p(@report_dir)
      File.open(File.join(@report_dir, "xmatch.html"), 'w') { |f|  f.write(generate_html) }
    end

    private
    
      def generate_html
        actual_filename = create_actual_file
        expected_filename = create_expected_file
        xml = @matcher        
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
