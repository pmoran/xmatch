XMatch
==============

XMatch is a Ruby library for comparing two XML documents and reporting on matches and mismatches. An XML document will match another if:

* elements have the same name
* elements have the same number of children
* elements have the same number of attributes
* attributes have the same value
* text elements have the same content

Blank elements are ignored.
XMatch uses Nokogiri for xml parsing.

Matching XML
------------
Given two XML documents as strings (or Nokogiri Documents), XMatch is run by:

	matcher = Matcher::Xml.new(expected)
	matcher.match(actual)

A matcher provides access to the match information by xpath values:

	matcher.matches
	matcher.mismatches

Custom matchers
---------------
The actual values of some xml elements are hard to know in advance (timestamps and ids being typical examples). XMatch allows custom matchers to be applied
to provide a good guess at a match in advance of the match being run. Custom matchers are predicates provided as Ruby Procs, identified by the xpath of the element they should be applied to.

	matcher = Matcher::Xml.new("<bookstore id='1'></bookstore>")
	matcher.on("/bookstore/@id") { |actual| actual =~ /\d+/ }
	matcher.match("<bookstore id='2'></bookstore>") # ==> true

Formatting match results
------------------------

The HTML formatter provides a cucumber-inspired report of the match results:

	Matcher::HtmlFormatter.new(xml).format

Installation
------------

XMatch is packaged as a Gem.  Install with:

    gem install xmatch

Copyright
---------

Copyright (c) 2009 Peter Moran. See LICENSE for details.