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
to provide a good guess at a match in advance of the match being run. Custom matchers are predicates provided as Ruby Procs, identified by the xpath of the element they should be applied to. They can be applied to text and attribute values.

	matcher = Matcher::Xml.new("<bookstore id='1'></bookstore>")
	matcher.on("/bookstore/@id") { |actual| actual =~ /\d+/ }
	matcher.match("<bookstore id='2'></bookstore>") # ==> true
	
An alternate syntax allows a pattern to be excluded from the match.  This is useful if values are mostly matching but differ by a pattern that cannot be know in advance (e.g. id's):

    matcher = Matcher::Xml.new("<book>This is book 123</book>")
	matcher.on("/book/text()", :excluding => /\d{3}$/)
	matcher.match("<book>This is book 456</book>") # ==> true

will exclude the first three digits from the actual match. A single capture group used in the pattern:

	matcher = Matcher::Xml.new("<book>Book 123 is here</book>")
	matcher.on("/book/text()", :excluding => /\.*s(\d{3,6})\s.*/)
	matcher.match("<book>Book 123456 is here</book>") # ==> true
	
will exclude only the matching capture.

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