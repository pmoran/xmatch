require 'erb'

module Matcher

  class HtmlFormatter

    TEMPLATE = File.dirname(__FILE__) + '/report.html.erb'
    REPORT = File.dirname(__FILE__) + '/../../reports/index.html'

    def format(xml)
      html = ERB.new(File.read(TEMPLATE))
      result = html.result(binding)
      File.open(REPORT, 'w') { |f|  f.write(result) }
      
      # xml.lhs.traverse do | elem |
      #   mismatch = xml.mismatches[elem.path]
      #   print "#{elem.line}: #{elem.path}"
      #   print " <========== #{mismatch}" if mismatch
      #   puts
      # end
      
      # mismatch = xml.mismatches[elem.path]
      # puts elem.path
      # puts "*******#{mismatch}" if mismatch

    end

  end

end
