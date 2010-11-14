module Matcher

  class TextFormatter

    def format(matcher)
      if matcher.mismatches.empty?
        puts "Documents matched"
      else
        puts "Documents didn't match:"
        puts matcher.mismatches.to_a.join(' : ')
        puts 
        matcher.lhs.traverse do |e|
          print e.path
          mismatch = matcher.mismatches[e.path]
          if mismatch
            puts " <====== #{mismatch}"
          else
            puts
          end
        end
      end
    end

  end

end
