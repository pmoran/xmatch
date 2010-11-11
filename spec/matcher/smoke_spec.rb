require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'matcher/xml'

describe Matcher::Xml do
  
  it "should compare files" do
    1.upto(10) do |i|
      instance_variable_set("@xml#{i}", open(File.expand_path(File.join(__FILE__, "../../fixtures/books#{i}.xml"))).read)
    end

    xml = Matcher::Xml.new(@xml1)
    xml.match(@xml2).should be_true
    xml.match(@xml3).should be_false
    xml.match(@xml4).should be_false
    xml.match(@xml5).should be_false
    xml.match(@xml6).should be_false
    xml.match(@xml7).should be_false
    xml.match(@xml9).should be_false
    xml.match(@xml10).should be_false
    xml.match(@xml8).should be_true
    
    Matcher::Xml.new(@xml7).match(@xml1).should be_false
  end
  
end