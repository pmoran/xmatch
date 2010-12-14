require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Matcher::HtmlFormatter do

  context "when configured" do

    before(:each) do
      xml = "<foo></foo>"
      @matcher = Matcher::Xml.new("<foo></foo>")
      @matcher.match(xml)
    end

    it "should create an html report in the default report directory" do
      Matcher::HtmlFormatter.new(@matcher).format
      File.exists?("/tmp/xmatch/xmatch.html").should be_true
    end

    %w[expected actual].each do |file|
      it "should create generated #{file} file" do
        now = Time.now
        Time.stub!(:now).and_return(now)
        Matcher::HtmlFormatter.new(@matcher).format
        File.exists?("/tmp/xmatch/generated_xml/#{file}-#{now.to_i}.xml").should be_true
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

end
