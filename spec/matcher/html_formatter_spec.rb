require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'fileutils'

describe Matcher::HtmlFormatter do

  before(:each) do
    FileUtils.rm_r("/tmp/xmatch") if File.exists?("/tmp/xmatch")
    @expected_xml = "<foo><bar1></bar1></foo>"
    @matcher = Matcher::Xml.new(@expected_xml)
    @matcher.match("<foo><bar1></bar1><bar2></bar2></foo>")
    @now = Time.now
    Time.stub!(:now).and_return(@now)
  end

  context "when configured" do

    it "should create an html report in the default report directory" do
      Matcher::HtmlFormatter.new(@matcher).format
      File.exists?("/tmp/xmatch/xmatch.html").should be_true
    end

    %w[expected actual].each do |file|
      it "should create generated #{file} file" do
        Matcher::HtmlFormatter.new(@matcher).format
        File.exists?("/tmp/xmatch/generated_xml/#{file}-#{@now.to_i}.xml").should be_true
      end
    end

    it "should create an html file in a configured directory" do
      Matcher::HtmlFormatter.new(@matcher, :report_dir => "/tmp/xmatch/mydir").format
      File.exists?("/tmp/xmatch/mydir/xmatch.html").should be_true
    end

    it "should create an html file with a configured prefix" do
      Matcher::HtmlFormatter.new(@matcher, :prefix => "myprefix").format
      File.exists?("/tmp/xmatch/myprefix-xmatch.html").should be_true
    end

  end

  describe "generating html" do

    before(:each) do
      Matcher::HtmlFormatter.new(@matcher).format
      @html = File.read("/tmp/xmatch/xmatch.html")
    end

    it "should show the number of mismatches" do
      @html.should include  "1 mismatches found from 2 elements."
    end
    
    it "should show the mismatch percentage when there are no mismatches" do
      @matcher.match(@expected_xml)
      Matcher::HtmlFormatter.new(@matcher).format
      html = File.read("/tmp/xmatch/xmatch.html")
      html.should include "<b>100%</b>"
    end

    it "should show the mismatch percentage when there are mismatches" do
      @html.should include "<b>50%</b>"
    end

    context 'linking to generated xml files' do

      %w[expected actual].each do |file|
        it "should render a link to the #{file} file" do
          @html.should include "href='/tmp/xmatch/generated_xml/#{file}-#{@now.to_i}.xml'"
        end
      end

    end

    context "displaying match results" do

      it "should display a match" do
        @html.should include '<tr class="matched">'
      end

      it "should display a mismatch" do
        @html.should include '<tr class="mismatched">'
      end

    end

  end

end
