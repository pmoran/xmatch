require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'nokogiri'
require 'matcher/xml'

describe Matcher::Xml do

  def verify_mismatch(path, message)
    @xml.match(@rhs).should be_false
    @xml.mismatches.should have(1).mismatch
    @xml.mismatches[path].should == message
  end

  context "attributes" do

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

  context "matching" do

    it "should be true when documents match" do
      Matcher::Xml.new(@lhs).match(@lhs.clone).should be_true
    end

    it "should provide empty mismatches on match" do
      @xml.match(@lhs.clone).should be_true
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

    context "elements" do

      it "should not match when rhs has an extra element" do
        @rhs = <<-eos
        <bookstore>
        <book category="COOKING">
        <title lang="en">Everyday Italian</title>
        </book>
        <book></book>
        </bookstore>
        eos
        verify_mismatch("/bookstore", "expected 1 children, got 2")
      end

      it "should not match when rhs has a missing element" do
        @lhs = <<-eos
        <bookstore>
        <book category="COOKING">
        <title lang="en">Everyday Italian</title>
        </book>
        </bookstore>
        eos

        @rhs = <<-eos
        <bookstore>
        <book category="COOKING">
        </book>
        </bookstore>
        eos
        verify_mismatch("/bookstore/book/title", "expected 1 children, got 0")
      end

    end

    context "names" do

      it "should not match when rhs has a different element name" do
        @rhs = <<-eos
        <bookstore>
        <bookx category="COOKING">
        <title lang="en">Everyday Italian</title>
        </bookx>
        </bookstore>
        eos
        verify_mismatch("/bookstore/book", "expected element 'book', got 'bookx'")
      end

    end

    context "attributes" do

      it "should not match when an attribute names don't match" do
        @rhs = <<-eos
        <bookstore>
        <book categoryx="COOKING">
        <title lang="en">Everyday Italian</title>
        </book>
        </bookstore>
        eos
        verify_mismatch("/bookstore/book", "expected attribute missing")
      end

      it "should not match when an attribute value doesn't match" do
        @rhs = <<-eos
        <bookstore>
        <book category="COOKINGx">
        <title lang="en">Everyday Italian</title>
        </book>
        </bookstore>
        eos
        verify_mismatch("/bookstore/book", "attribute 'category' expected 'COOKING', got 'COOKINGx'")
      end

      it "should not match when rhs has an extra attribute" do
        @rhs = <<-eos
        <bookstore>
        <book category="COOKING" foo="bar">
        <title lang="en">Everyday Italian</title>
        </book>
        </bookstore>
        eos
        verify_mismatch("/bookstore/book", "expected 1 attributes, got 2")
      end

      it "should not match when rhs has less attributes" do
        @rhs = <<-eos
        <bookstore>
        <book category="COOKING">
        <title>Everyday Italian</title>
        </book>
        </bookstore>
        eos
        verify_mismatch("/bookstore/book/title", "expected 1 attributes, got 0")
      end

      it "should not match when rhs has more attributes" do
        @rhs = <<-eos
        <bookstore>
        <book category="COOKING">
        <title lang="en" foo="bar">Everyday Italian</title>
        </book>
        </bookstore>
        eos
        verify_mismatch("/bookstore/book/title", "expected 1 attributes, got 2")
      end

    end

    context "contents" do

      it "should not match when inner text contents don't match" do
        @rhs = <<-eos
        <bookstore>
        <book category="COOKING">
        <title lang="en">Everyday Italianx</title>
        </book>
        </bookstore>
        eos
        verify_mismatch("/bookstore/book/title/text()", "expected 'Everyday Italian', got 'Everyday Italianx'")
      end

    end

  end

  context "mismatches" do

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
      @xml.mismatches.should have(2).mismatches
    end

    it "should contain parent's path when an attribute doesn't match" do

      lhs = <<-eos
      <bookstore>
      <book category="COOKING">
      <title lang="en">Everyday Italian</title>
      </book>
      <book category="FOO">
      <title lang="en">Everyday French</title>
      </book>
      </bookstore>
      eos


      @rhs = <<-eos
      <bookstore>
      <book category="COOKING">
      <title lang="en">Everyday Italian</title>
      </book>
      <book foo="bar">
      <title lang="en">Everyday French</title>
      </book>
      </bookstore>
      eos

      @xml = Matcher::Xml.new(lhs)
      verify_mismatch("/bookstore/book[2]", "expected attribute missing")
    end

    context 'matches' do

      it "should provide matches" do
        lhs = "<bookstore><book></book></bookstore>"
        xml = Matcher::Xml.new(lhs)
        xml.match(lhs)
        xml.matches.should have(2).matches
        xml.matches.values.all? {|m| m == true}.should be_true
      end

    end

  end

  context "match_result" do
    
    it "returns 'matched' for a path that was matched" do
      lhs = "<bookstore></bookstore>"
      xml = Matcher::Xml.new(lhs)
      xml.match(lhs)
      xml.result_for("/bookstore").should == "matched"
    end
    
    it "returns 'mismatched' for a path that was not matched" do
      lhs = "<bookstore></bookstore>"
      xml = Matcher::Xml.new(lhs)
      xml.match("<bookstorex></bookstorex>")
      xml.result_for("/bookstore").should == "mismatched"
    end
    
  end

end
