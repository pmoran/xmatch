require 'erb'
require 'fileutils'

module Matcher

  class HtmlFormatter

    TEMPLATE = File.dirname(__FILE__) + '/report.html.erb'
    REPORT_DIR = File.dirname(__FILE__) + '/../../reports'

    def format(xml, match_file)
      FileUtils.mkdir_p(REPORT_DIR)
      html = ERB.new(File.read(TEMPLATE))
      result = html.result(binding)
      File.open(File.join(REPORT_DIR, "index.html"), 'w') { |f|  f.write(result) }
    end

  end

end
