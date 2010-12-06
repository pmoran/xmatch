require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'nokogiri'

describe Matcher::Xml do

  def verify_mismatch(path, expected, actual, count = 1)
    match = @xml.match(@rhs)
    @xml.mismatches.should have(count).mismatch
    mismatch = @xml.mismatches[path]
    mismatch.result.should be_false
    mismatch.expected.should == expected.to_s
    mismatch.actual.should == actual
  end

  context "when being created" do

    before(:each) do
      @xml = Matcher::Xml.new("<foo></foo>")
    end

    it "should initialise with a string" do
      @xml.lhs.should be_a_kind_of(Nokogiri::XML::Document)
    end

    it "should initialise with a document" do
      @xml.lhs.should be_a_kind_of(Nokogiri::XML::Document)
    end

    it "should provide the rhs after a match" do
      @xml.match("<bar></bar>")
      @xml.rhs.should be_a_kind_of(Nokogiri::XML::Document)
    end

  end


  context "matching" do

    before(:each) do
      @lhs = <<-eos
      <bookstore>
      <book category="COOKING">
      <title lang="en">Everyday Italian</title>
      </book>
      </bookstore>
      eos
      @xml = Matcher::Xml.new(@lhs)
    end

    it "should be true when documents match" do
      Matcher::Xml.new(@lhs).match(@lhs.clone).should be_true
    end

    it "should provide empty mismatches on match" do
      @xml.match(@lhs.clone)
      @xml.mismatches.should be_empty
    end

    it "should ignore blank elements" do
      rhs = <<-eos
      <bookstore>
      <book category="COOKING">
      <title lang="en">Everyday Italian</title>
      </book>


      </bookstore>
      eos
      @xml.match(rhs).should be_true
    end

    it "should be true when a string is matched with a parsed document" do
      rhs = <<-eos
      <bookstore>
      <book category="COOKING">
      <title lang="en">Everyday Italian</title>
      </book>


      </bookstore>
      eos

      Matcher::Xml.new(@lhs).match(Nokogiri::XML(rhs)).should be_true
    end

    context "against elements" do

      it "should not match when rhs has an extra element" do
        @rhs = <<-eos
        <bookstore>
        <book category="COOKING">
        <title lang="en">Everyday Italian</title>
        </book>
        <book></book>
        </bookstore>
        eos
        verify_mismatch("/bookstore", "1 children", "2 children")
      end

      it "should not match when rhs has a missing element" do
        @rhs = <<-eos
        <bookstore>
        <book category="COOKING">
        </book>
        </bookstore>
        eos
        verify_mismatch("/bookstore/book/title", Matcher::Xml::EXISTENCE, Matcher::Xml::NOT_FOUND, 2)
      end

    end

    context "against element names" do

      it "should not match when rhs has a different element name" do
        @rhs = <<-eos
        <bookstore>
        <bookx category="COOKING">
        <title lang="en">Everyday Italian</title>
        </bookx>
        </bookstore>
        eos
        verify_mismatch("/bookstore/book", Matcher::Xml::EXISTENCE, Matcher::Xml::NOT_FOUND, 3)
      end

    end

    context "against attributes" do

      it "should not match when an attribute names don't match" do
        @rhs = <<-eos
        <bookstore>
        <book categoryx="COOKING">
        <title lang="en">Everyday Italian</title>
        </book>
        </bookstore>
        eos
        verify_mismatch("/bookstore/book/@category", Matcher::Xml::EXISTENCE, Matcher::Xml::NOT_FOUND)
      end

      it "should not match when an attribute value doesn't match" do
        @rhs = <<-eos
        <bookstore>
        <book category="COOKINGx">
        <title lang="en">Everyday Italian</title>
        </book>
        </bookstore>
        eos
        verify_mismatch("/bookstore/book/@category", 'COOKING', "COOKINGx")
      end

      it "should not match when rhs has an extra attribute" do
        @rhs = <<-eos
        <bookstore>
        <book category="COOKING" foo="bar">
        <title lang="en">Everyday Italian</title>
        </book>
        </bookstore>
        eos
        verify_mismatch("/bookstore/book", "1 attributes", "2 attributes")
      end

      it "should not match when rhs has less attributes" do
        @rhs = <<-eos
        <bookstore>
        <book category="COOKING">
        <title>Everyday Italian</title>
        </book>
        </bookstore>
        eos
        verify_mismatch("/bookstore/book/title", "1 attributes", "0 attributes")
      end

      it "should not match when rhs has more attributes" do
        @rhs = <<-eos
        <bookstore>
        <book category="COOKING">
        <title lang="en" foo="bar">Everyday Italian</title>
        </book>
        </bookstore>
        eos
        verify_mismatch("/bookstore/book/title", "1 attributes", "2 attributes")
      end

    end

    context "against text element contents" do

      it "should not match when contents don't match" do
        @rhs = <<-eos
        <bookstore>
        <book category="COOKING">
        <title lang="en">Everyday Italianx</title>
        </book>
        </bookstore>
        eos
        verify_mismatch("/bookstore/book/title/text()", "Everyday Italian", "Everyday Italianx")
      end

    end

    it "should provides all results empty by default" do
      Matcher::Xml.new(@lhs).results.should be_empty
    end

  end

  context "with mismatches" do

    before(:each) do
      @lhs = <<-eos
      <bookstore>
      <book category="COOKING">
      <title lang="en">Everyday Italian</title>
      </book>
      </bookstore>
      eos
      @xml = Matcher::Xml.new(@lhs)
    end

    it "should be empty to start with" do
      Matcher::Xml.new(@lhs).mismatches.should be_empty
    end

    it "should be reset when rematching" do
      rhs = <<-eos
      <bookstore>
      <book category="COOKING">
      </book>
      </bookstore>
      eos
      @xml.match(rhs)
      @xml.mismatches.should_not be_empty
      @xml.match(@lhs)
      @xml.mismatches.should be_empty
    end

    it 'can have multiple mismatches' do
      rhs = <<-eos
      <bookstorex>
      <book>
      <title lang="en">Everyday Italian</title>
      </book>
      </bookstore>
      eos
      @xml.match(rhs)
      @xml.mismatches.should have(4).mismatches
    end

    it "should contain parent's path when an attribute doesn't match" do
      lhs = <<-eos
      <bookstore>
      <book category="FOO">
      <title lang="en">Everyday French</title>
      </book>
      </bookstore>
      eos


      @rhs = <<-eos
      <bookstore>
      <book foo="bar">
      <title lang="en">Everyday French</title>
      </book>
      </bookstore>
      eos

      @xml = Matcher::Xml.new(lhs)
      verify_mismatch("/bookstore/book/@category", Matcher::Xml::EXISTENCE, Matcher::Xml::NOT_FOUND)
    end
  end

  context 'with matches' do

    before(:each) do
      lhs = "<bookstore><book>foo</book></bookstore>"
      @xml = Matcher::Xml.new(lhs)
      @xml.match(lhs).should be_true
    end

    it "should contain each match" do
      @xml.matches.should have(3).matches
    end

    it "should have expected and actual results" do
      match_info = @xml.matches["/bookstore"]
      match_info.expected.should == "1 children"
      match_info.actual.should == "1 children"
    end

  end

  context "retrieving match results" do

    before(:each) do
      @xml = Matcher::Xml.new("<bookstore></bookstore>")
    end

    it "returns 'matched' for a path that matched correctly" do
      @xml.match("<bookstore></bookstore>")
      @xml.result_for("/bookstore").should == "matched"
    end

    it "returns 'unmatched' for a path that was not found" do
      @xml.match("<bookstorex></bookstorex>")
      @xml.result_for("/bookstore").should == "mismatched"
    end

  end

  describe "with custom matchers" do

    context "provided at create time" do

      it "should be stored" do
        Matcher::Xml.new("<bookstore</bookstore>", {"my path" => "my predicate"}).custom_matchers.should have(1).matcher
      end

      it "can be used on an attribute value" do
        custom_matchers = { "/bookstore/@id" => lambda {|actual| actual == '2'} }
        xml = Matcher::Xml.new("<bookstore id='1'></bookstore>", custom_matchers)
        xml.match("<bookstore id='2'></bookstore>").should be_true
      end

      it "can be used on an element value" do
        custom_matchers = { "/bookstore/book/text()" => lambda {|actual| actual == 'bar'} }
        xml = Matcher::Xml.new("<bookstore><book>foo</book></bookstore", custom_matchers)
        xml.match("<bookstore><book>bar</book></bookstore").should be_true
      end

    end

    context "using match_on" do

      before(:each) do
        @matcher = Matcher::Xml.new("<bookstore><book>foo text</book></bookstore")
      end

      it "supports match_on with a regex predicate" do
        @matcher.match_on("/bookstore/book/text()") { |actual| actual =~ /bar/ }
        @matcher.match("<bookstore><book>bar</book></bookstore").should be_true
      end

      it "supports match_on with an equality predicate" do
        @matcher.match_on("/bookstore/book/text()") { |actual| actual == "foo text" }
        @matcher.match("<bookstore><book>foo text</book></bookstore").should be_true
      end

      it "tells if a custom matcher was used" do
        @matcher.match_on("/bookstore/book/text()") { |actual| actual =~ /bar/ }
        @matcher.match("<bookstore><book>bar</book></bookstore")
        @matcher.matches["/bookstore/book/text()"].was_custom_matched.should be_true
        @matcher.matches["/bookstore/book"].was_custom_matched.should be_false
      end

      it "supports 'on' style" do
        @matcher.on("/bookstore/book/text()") { |actual| actual =~ /bar/ }
        @matcher.match("<bookstore><book>bar</book></bookstore").should be_true
      end

      it "handles a match with no predicate" do
        @matcher.on("/bookstore/book/text()")
        @matcher.should be_true
      end

      context "with excluding option" do

        [/^\w{3}/, /^.*\s/].each do |regex|
          it "supports regex matching like #{regex}" do
            @matcher.on("/bookstore/book/text()", :excluding => regex)
            @matcher.match("<bookstore><book>bar text</book></bookstore").should be_true
          end
        end

        it "should fail a mismatching exclude" do
          @matcher.on("/bookstore/book/text()", :excluding => /^\w{1}/)
          @matcher.match("<bookstore><book>bar text</book></bookstore").should be_false
        end
        
        it "throws an error when a non-regex value" do
          lambda { @matcher.on("/bookstore/book/text()", :excluding => "foo") }.should raise_error(ArgumentError)
        end

        it "should not allow both a block and options" do
          lambda { @matcher.on("foo", :excluding => /bar/) {|actual| actual =~ /foo/} }.should raise_error(ArgumentError)
        end

      end

    end

  end

end
