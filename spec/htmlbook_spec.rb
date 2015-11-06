# encoding: utf-8
require 'spec_helper.rb'

describe "HTMLBook Templates" do


	# Tests section.html.erb templates
	it "should convert part titles" do
	  html = Nokogiri::HTML(convert("
[part]
== Part Title

Some introductory part text"))
          html.xpath("//div[@data-type='part']/h1").text.should == "Part Title"
	end

	it "should convert chapter titles" do
	    html = Nokogiri::HTML(convert("== Chapter Title"))
		html.xpath("//section[@data-type='chapter']/h1").text.should == "Chapter Title"
	 end

	it "should convert preface titles" do
	    html = Nokogiri::HTML(convert("
[preface]
== Preface
"))
		html.xpath("//section[@data-type='preface']/h1").text.should == "Preface"
	end

	it "should convert appendix titles" do
	    html = Nokogiri::HTML(convert("
[appendix]
== Appendix
"))
		html.xpath("//section[@data-type='appendix']/h1").text.should == "Appendix"
	end

        it "should convert dedication titles" do
            html = Nokogiri::HTML(convert("== Dedication"))
                html.xpath("//section[@data-type='dedication']/h1").text.should == "Dedication"
        end

        it "should convert glossary titles" do
            html = Nokogiri::HTML(convert("== Glossary"))
                html.xpath("//section[@data-type='glossary']/h1").text.should == "Glossary"
        end

        it "should convert foreword titles" do
            html = Nokogiri::HTML(convert("
[preface]
== Foreword"))
                html.xpath("//section[@data-type='foreword']/h1").text.should == "Foreword"
        end

        it "should convert Introduction titles" do
            html = Nokogiri::HTML(convert("
[introduction]
== This is the Introduction"))
                html.xpath("//section[@data-type='introduction']/h1").text.should == "This is the Introduction"
        end

        it "should convert index titles" do
            html = Nokogiri::HTML(convert("== Index"))
                html.xpath("//section[@data-type='index']/h1").text.should == "Index"
        end

	it "should convert level 1 headings" do
	    html = Nokogiri::HTML(convert("=== Heading 1"))
		html.xpath("//section[@data-type='sect1']/h1").text.should == "Heading 1"
	end

	it "should convert level 2 headings" do
		html = Nokogiri::HTML(convert("==== Heading 2"))
		html.xpath("//section[@data-type='sect2']/h2").text.should == "Heading 2"
	end

	it "should convert level 3 headings" do
		html = Nokogiri::HTML(convert("===== Heading 3"))
		html.xpath("//section[@data-type='sect3']/h3").text.should == "Heading 3"
	end

	it "should convert level 4 headings" do
		html = Nokogiri::HTML(convert("====== Heading 4"))
		html.xpath("//section[@data-type='sect4']/h4").text.should == "Heading 4"
	end

	# Tests block_admonition template
	it "should convert notes with admonition block markup" do
		html = Nokogiri::HTML(convert("
[NOTE]
====
Here is a note with block markup.

Here is a second paragraph.
====
"))
		html.xpath("//div[@data-type='note']/p[1]").text.should == "Here is a note with block markup."
		html.xpath("//div[@data-type='note']/p[2]").text.should == "Here is a second paragraph."
	end

	# Tests block_admonition template alternate markup
	it "should convert notes with admonition paragraph markup" do
		html = Nokogiri::HTML(convert("
[NOTE]
Here is a note with paragraph markup.
"))
		html.xpath("//div[@data-type='note']/p").text.should == "Here is a note with paragraph markup."
	end

	# Tests block_admonition template second alternate markup
	it "should convert notes with alternate admonition paragraph markup" do
		html = Nokogiri::HTML(convert("
NOTE: Here is a note with alternate paragraph markup.
"))
		html.xpath("//div[@data-type='note']/p").text.should == "Here is a note with alternate paragraph markup."
	end


	it "should convert tips" do
	    html = Nokogiri::HTML(convert("
[TIP]
====
Here is some text inside a tip.
====
"))
		html.xpath("//div[@data-type='tip']/p").text.should == "Here is some text inside a tip."
	end


	it "should convert warnings" do
	    html = Nokogiri::HTML(convert("
[WARNING]
====
Here is some text inside a warning.
====
"))
		html.xpath("//div[@data-type='warning']/p").text.should == "Here is some text inside a warning."
	end

	it "should convert cautions" do
	    html = Nokogiri::HTML(convert("
[CAUTION]
====
Here is some text inside a caution.
====
"))
		html.xpath("//div[@data-type='caution']/p").text.should == "Here is some text inside a caution."
	end


	# Tests block_dlist template
	it "should convert definition/variable list terms" do
		html = Nokogiri::HTML(convert("First term:: This is a definition of the first term."))
		html.xpath("//dl/dt").text.should == "First term"
		html.xpath("//dl/dd/p").text.should == "This is a definition of the first term."
	end


	# Tests block_example template
	it "should convert formal examples" do
		html = Nokogiri::HTML(convert("
[[Example1]]
.A code block with a title
====
[source, php]
----
Hello world
----
====
"))
		html.xpath("//div[@data-type='example']/@id").text.should == "Example1"
		html.xpath("//div[@data-type='example']/h5").text.should == "A code block with a title"
		html.xpath("//div[@data-type='example']/pre[@data-type='programlisting']/@data-code-language").text.should == "php"
		html.xpath("//div[@data-type='example']/pre[@data-type='programlisting']").text.should == "Hello world"
	end


	# Tests block_image template
	it "should convert formal figures" do
		html = Nokogiri::HTML(convert("
[[unique_id1]]
.A Figure
image::images/tiger.png[]
"))
		html.xpath("//figure/@id").text.should == "unique_id1"
		html.xpath("//figure/figcaption").text.should == "A Figure"
		html.xpath("//figure/img/@src").text.should == "images/tiger.png"
		html.xpath("//figure/img/@alt").text.should == "tiger"
	end


	it "should convert informal figures" do
		html = Nokogiri::HTML(convert("image::images/duck.png[]"))
		html.xpath("//figure/figcaption").size.should == 1
		html.xpath("//figure/@id").size.should == 0
		html.xpath("//figure/img/@src").text.should == "images/duck.png"
	end

	it "should convert figures with alt-text" do
		html = Nokogiri::HTML(convert("image::images/lion.png['An image of a lion head']"))
		html.xpath("//figure/img/@alt").text.should == "An image of a lion head"
	end

	# Tests block_listing template
	it "should convert informal code blocks" do
		html = Nokogiri::HTML(convert("
[source, php]
----
Hello world
----
"))
		html.xpath("//pre[@data-type='programlisting']/@data-code-language").text.should == "php"
		html.xpath("//pre[@data-type='programlisting']").text.should == "Hello world"
	end

	# Tests block_literal template - first markup style
	it "should convert literal blocks" do
		html = Nokogiri::HTML(convert("
[literal]
This is a literal block.
"))
		html.xpath("//pre").text.should == "This is a literal block."
	end

	# Tests block_literal template - second markup style
	it "should convert literal blocks" do
		html = Nokogiri::HTML(convert(" This is also a literal block."))
		html.xpath("//pre").text.should == "This is also a literal block."
	end

	# Test block_math template
	it "should convert math blocks" do
		html = Nokogiri::HTML(convert("
[latexmath]
.Equation title
++++
\begin{equation}
{x = \frac{{ - b \pm \sqrt {b^2 - 4ac} }}{{2a}}}
\end{equation}
++++
"))
		html.xpath("//div[@data-type='equation']/h5").text.should == "Equation title"
		html.xpath("//div[@data-type='equation']/p[@data-type='latex']/text()") == "
\begin{equation}
{x = \frac{{ - b \pm \sqrt {b^2 - 4ac} }}{{2a}}}
\end{equation}
"
	end

	# Tests block_olist template
	it "should convert ordered lists" do
		html = Nokogiri::HTML(convert("
. Preparation
. Assembly
. Measure
+
Combine
+
Bake
+
. Applause
"))
		html.xpath("//ol/li[1]/p[1]").text.should == "Preparation"
		html.xpath("//ol/li[2]/p[1]").text.should == "Assembly"
		html.xpath("//ol/li[3]/p[1]").text.should == "Measure"
		html.xpath("//ol/li[3]/p[2]").text.should == "Combine"
		html.xpath("//ol/li[3]/p[3]").text.should == "Bake"
		html.xpath("//ol/li[4]/p[1]").text.should == "Applause"
	end

	# Tests block_paragraph template
	it "should convert regular paragraphs" do
		html = Nokogiri::HTML(convert("Here is a basic paragraph."))
		html.xpath("//p").text.should == "Here is a basic paragraph."
	end

	it "should convert paragraphs with role attributes" do
		html = Nokogiri::HTML(convert("
[role='right']
Here is a basic paragraph.
"))
		html.xpath("//p[@class='right']").text.should == "Here is a basic paragraph."
	end

	# Tests block_quote template
	it "should convert block quotes" do
		html = Nokogiri::HTML(convert("
[quote, Wilfred Meynell]
____
Many thanks; I shall lose no time in reading it.

This is a second paragraph in the quotation.
____
"))
		html.xpath("//blockquote/p[1]").text.should == "Many thanks; I shall lose no time in reading it."
		html.xpath("//blockquote/p[2]").text.should == "This is a second paragraph in the quotation."
		html.xpath("//blockquote/p[@data-type='attribution']").text.should == "Wilfred Meynell"
	end

	# Tests block_sidebar template
	it "should convert sidebars" do
		html = Nokogiri::HTML(convert("
.Sidebar Title
****
Sidebar text is surrounded by four asterisks.
****
"))
		html.xpath("//aside[@data-type='sidebar']/h5").text.should == "Sidebar Title"
		html.xpath("//aside[@data-type='sidebar']/p").text.should == "Sidebar text is surrounded by four asterisks."
	end

	# Tests block_table template
	it "should convert formal tables (with title and header)" do
		html = Nokogiri::HTML(convert("
.Table Title
[options='header']
|=======
|header1|header2
|row1|P^Q^
|row2|col2
|=======
"))
		html.xpath("//table/caption").text.should == "Table Title"
		html.xpath("//table/thead/tr/th[1]").text.should == "header1"
		html.xpath("//table/thead/tr/th[2]").text.should == "header2"
		html.xpath("//table/tbody/tr[1]/td[1]/p").text.should == "row1"
		html.xpath("//table/tbody/tr[1]/td[2]/p/text()").text.should == "P"
		html.xpath("//table/tbody/tr[1]/td[2]/p/sup").text.should == "Q"
		html.xpath("//table/tbody/tr[2]/td[1]/p").text.should == "row2"
		html.xpath("//table/tbody/tr[2]/td[2]/p").text.should == "col2"
	end

	it "should convert informal tables (no title or header)" do
		html = Nokogiri::HTML(convert("
|=======
|row1|P^Q^
|row2|col2
|=======
"))
		html.xpath("//table/tbody/tr[1]/td[1]/p").text.should == "row1"
		html.xpath("//table/tbody/tr[1]/td[2]/p/text()").text.should == "P"
		html.xpath("//table/tbody/tr[1]/td[2]/p/sup").text.should == "Q"
		html.xpath("//table/tbody/tr[2]/td[1]/p").text.should == "row2"
		html.xpath("//table/tbody/tr[2]/td[2]/p").text.should == "col2"
	end

	# Tests block_ulist template
	it "should convert itemized lists" do
		html = Nokogiri::HTML(convert("
* lions
* tigers
+
sabre-toothed
+
teapotted
+
* lions, tigers, and bears
"))
		html.xpath("//ul/li[1]/p[1]").text.should == "lions"
		html.xpath("//ul/li[2]/p[1]").text.should == "tigers"
		html.xpath("//ul/li[2]/p[2]").text.should == "sabre-toothed"
		html.xpath("//ul/li[2]/p[3]").text.should == "teapotted"
		html.xpath("//ul/li[3]/p[1]").text.should == "lions, tigers, and bears"
	end

	# Tests block_verse template
	it "should convert verse blocks" do
		html = Nokogiri::HTML(convert("
[verse, William Blake, Songs of Experience]
Tiger, tiger, burning bright
In the forests of the night
"))
		html.xpath("//blockquote/pre").text.should == "Tiger, tiger, burning bright
In the forests of the night"
		html.xpath("//blockquote/p[@data-type='attribution']").text.should == "— William Blake, Songs of Experience"
	end

	# Tests block_video template
	it "should convert video blocks - first markup style" do
		html = Nokogiri::HTML(convert("
video::gizmo.ogv[width=200]
"))
		html.xpath("//video[@width='200']/source/@src").text.should == "gizmo.ogv"
		html.xpath("//video/text()").text.should == "\nSorry, the <video> element is not supported in your reading system.\n"
	end

	# Tests inline_anchor template
	it "should convert inline anchors" do
		html = Nokogiri::HTML(convert("
This is a reference to an <<inlineanchor>>.

See <<inlineanchor, Awesome Chapter>>
"))
		html.xpath("//p[1]/a/@href").text.should == "#inlineanchor"
		html.xpath("//p[1]/a").text.should == ""
		html.xpath("//p[2]/a/@href").text.should == "#inlineanchor"
		html.xpath("//p[2]/a").text.should == "Awesome Chapter"
	end

        it "should convert inline anchors" do
                html = Nokogiri::HTML(convert("
This is a link without a text node: http://www.oreilly.com

This is a link with a text node: http://www.oreilly.com[check out this text node]
"))
                html.xpath("//p[1]/a/@href").text.should == "http://www.oreilly.com"
                html.xpath("//p[1]/a/em[@class='hyperlink']").text.should == "http://www.oreilly.com"
                html.xpath("//p[2]/a/@href").text.should == "http://www.oreilly.com"
                html.xpath("//p[2]/a[not(*)]").text.should == "check out this text node"
        end

	# PENDING: Tests block_colist template
	it "should convert calloutlists"

	# PENDING: Tests inline_callout template 
	it "should convert inline callouts in code" 
# 	it "should convert inline callouts in code" do
# 		html = Nokogiri::HTML(convert("
# == Chapter Title
# ----
# Roses are red, <1>
#    Violets are blue. <2>
# ----
# <1> This is a fact.
# <2> This poem uses the literary device known as a surprise ending.
# "))
# 		html.xpath("//pre[@data-type='programlisting']/text()").text.should == "Roses are red, 
#    Violets are blue. "
#    		html.xpath("//pre[@data-type='programlisting']/a[1]").text.should == "(1)"
#    		html.xpath("//pre[@data-type='programlisting']/b[2]").text.should == "(2)"
#    		html.xpath("//ol[@class='calloutlist']/li[1]/p").text.should == "➊ This is a fact."
#    		html.xpath("//ol[@class='calloutlist']/li[2]/p").text.should == "➋ This poem uses the literary device known as a surprise ending."
# 	end

	# Tests inline_footnote template
	it "should convert footnotes and footnoterefs" do
		html = Nokogiri::HTML(convert("
A footnote.footnote:[An example footnote.]

A second footnote with a reference ID.footnoteref:[note2,Second footnote.]

Finally a reference to the second footnote.footnoteref:[note2]
"))
		html.xpath("//p[1]/span[@data-type='footnote']").text.should == "An example footnote."
		html.xpath("//p[1]/span[@data-type='footnote']/@id").size.should == 0
		html.xpath("//p[2]/span[@data-type='footnote']").text.should == "Second footnote."
		html.xpath("//p[2]/span[@data-type='footnote']/@id").text.should == "note2"
		html.xpath("//p[3]/a[@data-type='footnoteref']/text()").size.should == 0
		html.xpath("//p[3]/a[@data-type='footnoteref']/@href").text.should == "#note2"
	end

	# Tests inline_image template
	it "should convert inline images" do
		html = Nokogiri::HTML(convert("Here is an inline figure: image:images/logo.png[]"))
		html.xpath("//p/img/@src").text.should == "images/logo.png"
	end

	# Tests inline_quoted template
	it "should convert inline formatting" do
		html = Nokogiri::HTML(convert("This para has __emphasis__, *bold**, ++literal++, ^superscript^, ~subscript~, __++replaceable++__, and *+userinput+*."))
		html.xpath("//p/em[1]").text.should == "emphasis"
		html.xpath("//p/strong[1]").text.should == "bold"
		html.xpath("//p/code[1]").text.should == "literal"
		html.xpath("//p/sup").text.should == "superscript"
		html.xpath("//p/sub").text.should == "subscript"
		html.xpath("//p/em/code").text.should == "replaceable"
		html.xpath("//p/strong/code").text.should == "userinput"
	end

	# Tests math in inline_quoted template
	it "should convert inline equations" do
		html = Nokogiri::HTML(convert("The Pythagorean Theorem is latexmath:[$a^2 + b^2 = c^2$]"))
		html.xpath("//p/span[@data-type='tex']").text.should == "$a^2 + b^2 = c^2$"
	end

	# Tests inline_indexterm template - source markup is in files/indexterm_testing.asciidoc
	it "should convert inline indexterms with one term" do
		html = Nokogiri::HTML(convert_indexterm_tests)
		# Primary only, with quation marks
		html.xpath("//section[@data-type='sect1'][1]/section[@data-type='sect2'][1]/p[1]/a/@data-type").text.should == "indexterm"
		html.xpath("//section[@data-type='sect1'][1]/section[@data-type='sect2'][1]/p[1]/a/@data-primary").text.should == "metaclass"
		# Primary only, without quotation marks
		html.xpath("//section[@data-type='sect1'][1]/section[@data-type='sect2'][1]/p[2]/a/@data-type").text.should == "indexterm"
		html.xpath("//section[@data-type='sect1'][1]/section[@data-type='sect2'][1]/p[2]/a/@data-primary").text.should == "accessibility"
	end

	it "should convert inline indexterms with two terms" do
		html = Nokogiri::HTML(convert_indexterm_tests)
		# Primary only
		html.xpath("//section[@data-type='sect1'][2]/section[@data-type='sect2'][1]/p[1]/a/@data-see").text.should == "aspect-oriented"
		html.xpath("//section[@data-type='sect1'][2]/section[@data-type='sect2'][1]/p[2]/a/@data-seealso").text.should == "namespace"
		html.xpath("//section[@data-type='sect1'][2]/section[@data-type='sect2'][1]/p[3]/a/@data-primary-sortas").text.should == "patterns"
		html.xpath("//section[@data-type='sect1'][2]/section[@data-type='sect2'][1]/p[4]/a/@id").text.should == "dynamic"
		html.xpath("//section[@data-type='sect1'][2]/section[@data-type='sect2'][1]/p[5]/a/@data-startref").text.should == "dynamic"
		# Secondary
		html.xpath("//section[@data-type='sect1'][2]/section[@data-type='sect2'][2]/p[1]/a/@data-secondary").text.should == "eigenclass"
	end

	it "should convert inline indexterms with three terms" do
		html = Nokogiri::HTML(convert_indexterm_tests)
		# Primary only
		html.xpath("//section[@data-type='sect1'][3]/section[@data-type='sect2'][1]/p[1]/a/@id").text.should == "orthogonality"
		html.xpath("//section[@data-type='sect1'][3]/section[@data-type='sect2'][1]/p[2]/a/@data-see").text.should == "destructor"
		html.xpath("//section[@data-type='sect1'][3]/section[@data-type='sect2'][1]/p[2]/a/@data-seealso").text.should == "factory method"
		# Secondary
		html.xpath("//section[@data-type='sect1'][3]/section[@data-type='sect2'][2]/p[1]/a/@data-secondary").text.should == "immutable"
		html.xpath("//section[@data-type='sect1'][3]/section[@data-type='sect2'][2]/p[1]/a/@data-see").text.should == "instance method"
		html.xpath("//section[@data-type='sect1'][3]/section[@data-type='sect2'][2]/p[2]/a/@data-seealso").text.should == "partial class"
		html.xpath("//section[@data-type='sect1'][3]/section[@data-type='sect2'][2]/p[3]/a/@data-secondary-sortas").text.should == "iterator"
		# Tertiary, with quotation marks
		html.xpath("//section[@data-type='sect1'][3]/section[@data-type='sect2'][3]/p[1]/a/@data-secondary").text.should == "virtual class"
		html.xpath("//section[@data-type='sect1'][3]/section[@data-type='sect2'][3]/p[1]/a/@data-tertiary").text.should == "subtype"
		# Tertiary, without quotation marks
		html.xpath("//section[@data-type='sect1'][3]/section[@data-type='sect2'][3]/p[2]/a/@data-secondary").text.should == "test-driven development"
		html.xpath("//section[@data-type='sect1'][3]/section[@data-type='sect2'][3]/p[2]/a/@data-tertiary").text.should == "weak reference"		
	end

	it "should convert inline indexterms with four terms" do
		html = Nokogiri::HTML(convert_indexterm_tests)
		# Primary only
		html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][1]/p[1]/a/@id").text.should == "slicing"
		html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][1]/p[1]/a/@data-see").text.should == "access control"
		html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][1]/p[2]/a/@data-seealso").text.should == "hybrid"
		html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][1]/p[3]/a/@data-primary-sortas").text.should == "uninitialized"
		html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][1]/p[4]/a/@data-see").text.should == "mutator method"
		html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][1]/p[4]/a/@data-seealso").text.should == "policy-based design"
		# Secondary
		html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][2]/p[1]/a/@data-secondary").text.should == "viscosity"
		html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][2]/p[1]/a/@id").text.should == "encapsulation"
		html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][2]/p[2]/a/@data-secondary").text.should == "superclass"
		html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][2]/p[2]/a/@data-see").text.should == "typecasting"
		html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][2]/p[2]/a/@data-seealso").text.should == "virtual inheritance"
		# Tertiary
		html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][3]/p[1]/a/@data-secondary").text.should == "shadowed name"
		html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][3]/p[1]/a/@data-tertiary").text.should == "function"
		html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][3]/p[1]/a/@data-see").text.should == "late binding"
		html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][3]/p[2]/a/@data-secondary").text.should == "array"
		html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][3]/p[2]/a/@data-tertiary").text.should == "compiler"
		html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][3]/p[2]/a/@data-seealso").text.should == "subroutine"
		html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][3]/p[3]/a/@data-secondary").text.should == "stack"
		html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][3]/p[3]/a/@data-tertiary").text.should == "paradigm"
		html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][3]/p[3]/a/@data-tertiary-sortas").text.should == "enumerable"
	end

	it "should convert inline indexterms with five terms" do
		html = Nokogiri::HTML(convert_indexterm_tests)
		# Primary only
		html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][1]/p[1]/a/@id").text.should == "mapping"
		html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][1]/p[1]/a/@data-see").text.should == "overload"
		html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][1]/p[1]/a/@data-seealso").text.should == "parse"
		# Secondary
		html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][2]/p[1]/a/@data-secondary").text.should == "token"
		html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][2]/p[1]/a/@id").text.should == "syntax"
		html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][2]/p[1]/a/@data-see").text.should == "binary"
		html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][2]/p[2]/a/@data-secondary").text.should == "conditional"
		html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][2]/p[2]/a/@id").text.should == "collection"
		html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][2]/p[2]/a/@data-seealso").text.should == "alias"
		html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][2]/p[3]/a/@data-secondary").text.should == "operation"
		html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][2]/p[3]/a/@id").text.should == "semantics"
		html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][2]/p[3]/a/@data-secondary-sortas").text.should == "parameter"
		html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][2]/p[4]/a/@data-secondary").text.should == "abstraction"
		html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][2]/p[4]/a/@id").text.should == "constant"
		html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][2]/p[4]/a/@data-see").text.should == "arithmetic operator"
		html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][2]/p[4]/a/@data-seealso").text.should == "base type"
		# Tertiary
		html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][3]/p[1]/a/@data-secondary").text.should == "deprecated"
		html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][3]/p[1]/a/@data-tertiary").text.should == "finalization"
		html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][3]/p[1]/a/@id").text.should == "little-endian"
		html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][3]/p[2]/a/@data-secondary").text.should == "parallel"
		html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][3]/p[2]/a/@data-tertiary").text.should == "scheme"
		html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][3]/p[2]/a/@data-see").text.should == "ternary"
		html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][3]/p[2]/a/@data-seealso").text.should == "exception"
	end

	it "should convert inline indexterms with six terms" do
		html = Nokogiri::HTML(convert_indexterm_tests)
		# Secondary
		html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][1]/p[1]/a/@data-secondary").text.should == "while loop"
		html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][1]/p[1]/a/@id").text.should == "retro"
		html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][1]/p[1]/a/@data-see").text.should == "top-level class"
		html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][1]/p[1]/a/@data-seealso").text.should == "unary"
		# Tertiary
		html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][2]/p[1]/a/@data-secondary").text.should == "precedence"
		html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][2]/p[1]/a/@data-tertiary").text.should == "overriding"
		html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][2]/p[1]/a/@id").text.should == "lightweight"
		html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][2]/p[1]/a/@data-see").text.should == "infinite"
		html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][2]/p[2]/a/@data-secondary").text.should == "encapsulation"
		html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][2]/p[2]/a/@data-tertiary").text.should == "condition"
		html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][2]/p[2]/a/@id").text.should == "aggregation"
		html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][2]/p[2]/a/@data-seealso").text.should == "boundary"
		html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][2]/p[3]/a/@data-secondary").text.should == "classpath"
		html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][2]/p[3]/a/@data-tertiary").text.should == "import"
		html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][2]/p[3]/a/@id").text.should == "datagram"
		html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][2]/p[3]/a/@data-tertiary-sortas").text.should == "method"
	end

	it "should convert inline indexterms with seven terms" do
		html = Nokogiri::HTML(convert_indexterm_tests)
		# Tertiary
		html.xpath("//section[@data-type='sect1'][7]/p[1]/a/@data-secondary").text.should == "public"
		html.xpath("//section[@data-type='sect1'][7]/p[1]/a/@data-tertiary").text.should == "relational"
		html.xpath("//section[@data-type='sect1'][7]/p[1]/a/@id").text.should == "cascaded"
		html.xpath("//section[@data-type='sect1'][7]/p[1]/a/@data-see").text.should == "inline"
		html.xpath("//section[@data-type='sect1'][7]/p[1]/a/@data-seealso").text.should == "private"
	end

	it "should convert inline indexterm next-gen sortas attributes properly (primary-sortas, secondary-sortas, tertiary-sortas)" do
		html = Nokogiri::HTML(convert_indexterm_tests)
		html.xpath("//section[@id='sortas_tests']/p[1]/a/@data-primary-sortas").text.should == "one"
		html.xpath("//section[@id='sortas_tests']/p[1]/a/@data-secondary-sortas").text.should == "two"
		html.xpath("//section[@id='sortas_tests']/p[1]/a/@data-tertiary-sortas").text.should == "three"
	end

        it "should ignore legacy sortas when primary, secondary, or tertiary sortas are present" do
               html = Nokogiri::HTML(convert_indexterm_tests)
               html.xpath("//section[@id='sortas_tests']/p[position() > 1]/a/@*[contains(., 'ignoreme')]").length.should == 0
               html.xpath("//section[@id='sortas_tests']/p[2]/a/@data-primary-sortas").text.should == "one"
               html.xpath("//section[@id='sortas_tests']/p[3]/a/@data-secondary-sortas").text.should == "two"
               html.xpath("//section[@id='sortas_tests']/p[4]/a/@data-tertiary-sortas").text.should == "three"
        end

        it "should ignore badly formed indexterms" do 
               expect { Nokogiri::HTML(convert('This indexterm has unbalanced parens((("primary", "secondary"))')) }.not_to raise_error
        end

	it "should properly convert text-term hybrids" do
	       html = Nokogiri::HTML(convert_indexterm_tests)
	       indexterm_p = html.xpath("//section[@id='text-term-hybrid']//p[1]")
	       indexterms = html.xpath("//section[@id='text-term-hybrid']//p[1]//a[@data-type='indexterm']")
	       indexterm_p.text.should == "Ruby is my favorite programming language."
	       indexterms.length.should == 1
	       indexterms.xpath("./@data-primary").text.should == "Ruby"
	end

	# Passthrough tests - moving these tests to Atlas app

	# it "should convert inline DocBook passthroughs to HTMLBook" do
	# 	html = Nokogiri::HTML(convert_passthrough_tests)
	# 	html.xpath("//section[@data-type='sect1'][1]/p[1]/span[@class='keep-together']").text.should == "DocBook phrase element"
	# 	html.xpath("//section[@data-type='sect1'][1]/p[2]/code").text.should == "DocBook code element"
	# end

	# it "should convert block DocBook passthroughs to HTMLBook" do
	# 	html = Nokogiri::HTML(convert_passthrough_tests)
	# 	html.xpath("//section[@data-type='sect1'][2]/pre[@data-type='programlisting']/strong/code").text.should == "first line of code here"
	# 	html.xpath("//section[@data-type='sect1'][2]/figure/figcaption").text.should == "DocBook Figure Markup"
	# 	html.xpath("//section[@data-type='sect1'][2]/figure/img/@src").text.should == "images/docbook.png"
	# 	html.xpath("//section[@data-type='sect1'][2]/blockquote/p[@data-type='attribution']").text.should == "Lewis Carroll"
	# 	html.xpath("//section[@data-type='sect1'][2]/blockquote/p").text.should start_with "Alice was beginning to get very tired"
	# end

	# it "should not convert inline HTML block passthroughs" do
	# 	html = Nokogiri::HTML(convert_passthrough_tests)
	# 	html.xpath("//section[@data-type='sect1'][3]/p[1]/strong").text.should == "HTML strong element"
	# 	html.xpath("//section[@data-type='sect1'][3]/p[2]/code").text.should == "HTML code element"
	# end

	# it "should not convert block HTML passthroughs" do
	# 	html = Nokogiri::HTML(convert_passthrough_tests)
	# 	html.xpath("//section[@data-type='sect1'][4]/p[2]").text.should == "Some text in an HTML p element."
	# 	html.xpath("//section[@data-type='sect1'][4]/figure/figcaption").text.should == "HTML Figure Markup"
	# 	html.xpath("//section[@data-type='sect1'][4]/figure/img/@src").text.should == "images/html.png"
	# 	html.xpath("//section[@data-type='sect1'][4]/blockquote/p").text.should start_with "So she was considering in her own mind"
	# end

	# it "should ignore processing instruction passthroughs" do
	# 	html = Nokogiri::HTML(convert_passthrough_tests)
	# 	html.xpath("//section[@data-type='sect1'][5]/p[1]").text.should == "Processing instruction in inline passthroughs should be ignored entirely."
	# 	html.xpath("//section[@data-type='sect1'][5]/p[2]/span").text.should == "should be subbed out."
	# 	html.xpath("//section[@data-type='sect1'][5]").text.should_not include '<?hard-pagebreak?>'
	# 	html.xpath("//section[@data-type='sect1'][5]/p[5]").text.should == "text before  text after"
	# end

end
