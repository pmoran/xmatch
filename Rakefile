$:.unshift(File.join(File.dirname(__FILE__), 'lib'))
require "rubygems"
require "rake"
require "rake/clean"

require 'xmatch'

require "spec/rake/spectask"

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
  # spec.spec_opts << "-Du"
  spec.spec_opts << "--color"
end

task :default => :spec

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
  spec.rcov = true
end

desc "Match two xml documents"
task :match, :lhs, :rhs do |t, args|
  puts "** Matching #{args[:lhs]} with #{args[:rhs]}"
  xml = Matcher::Xml.new(File.read(args[:lhs]))
  # xml.verbose
  xml.match(File.read(args[:rhs]))
  Matcher::HtmlFormatter.new(xml).format
end
