module Matcher

  class TextFormatter

    def format(matcher)
      if matcher.mismatches.empty?
        puts "Documents matched"
      else
        puts "Documents didn't match:"
        puts matcher.mismatches
        matcher.lhs.traverse do |e|
          print e.path
          if matcher.mismatches[e.path]
            puts "<======" if matcher.mismatches[e.path]
          else
            puts
          end
        end
      end
    end

  end

end
