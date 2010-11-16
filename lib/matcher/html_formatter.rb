require 'erb'
require 'fileutils'

module Matcher

  class HtmlFormatter

    TEMPLATE = File.dirname(__FILE__) + '/xmatch.html.erb'

    def initialize(matcher, args = {})
      @matcher = matcher
      @report_dir = args[:report_dir] || File.dirname(__FILE__) + '/../../reports'
      @expected_file = args[:expected_file]
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
        # TODO: create file if expected was a string, not a filename
        expected_filename = File.join(@report_dir, "expected.xml")
        FileUtils.cp(File.expand_path(@expected_file), expected_filename)
        expected_filename
      end

      def create_actual_file
        actual_filename = File.join(@report_dir, "actual.xml")
        File.open(actual_filename, 'w') { |f| f.write(@matcher.rhs)}
        actual_filename
      end

  end

end
