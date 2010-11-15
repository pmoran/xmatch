require 'erb'
require 'fileutils'

module Matcher

  class HtmlFormatter

    TEMPLATE = File.dirname(__FILE__) + '/report.html.erb'
    REPORT_DIR = File.dirname(__FILE__) + '/../../reports'

    def format(xml, expected = "")
      expected_filename = File.expand_path(expected)
      actual_filename = File.join(REPORT_DIR, "actual.xml")
      FileUtils.mkdir_p(REPORT_DIR)
      File.open(actual_filename, 'w') { |f| f.write(xml.rhs)}
      
      html = ERB.new(File.read(TEMPLATE))
      result = html.result(binding)
      File.open(File.join(REPORT_DIR, "index.html"), 'w') { |f|  f.write(result) }
    end

  end

end
