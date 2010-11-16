require 'erb'
require 'fileutils'

module Matcher

  class HtmlFormatter

    TEMPLATE = File.dirname(__FILE__) + '/xmatch.html.erb'

    def initialize(args = {})
      @report_dir = args[:report_dir] || File.dirname(__FILE__) + '/../reports'
      @expected_file = File.expand_path(args[:expected_file])
    end

    def format(xml)
      FileUtils.mkdir_p(@report_dir)
      actual_filename = create_actual_file(xml)
      expected_filename = create_expected_file

      html = ERB.new(File.read(TEMPLATE))
      result = html.result(binding)
      File.open(File.join(@report_dir, "xmatch.html"), 'w') { |f|  f.write(result) }
    end

    private
    
      def create_expected_file
        @expected_file
      end

      def create_actual_file(xml)
        actual_filename = File.join(@report_dir, "actual.xml")
        File.open(actual_filename, 'w') { |f| f.write(xml.rhs)}
        actual_filename
      end

  end

end
