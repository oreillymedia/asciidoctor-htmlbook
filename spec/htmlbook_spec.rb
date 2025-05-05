# encoding: utf-8
require 'spec_helper.rb'

describe "HTMLBook Templates" do


	# Tests section.html.erb templates
	it "should convert part titles" do
	  html = Nokogiri::HTML(convert("
[part]
== Part Title

Some introductory part text"))
          expect(html.xpath("//div[@data-type='part']/h1").text).to eq("Part Title")
	end

	it "should convert chapter titles" do
	    html = Nokogiri::HTML(convert("== Chapter Title"))
		expect(html.xpath("//section[@data-type='chapter']/h1").text).to eq("Chapter Title")
	 end

	it "should convert preface titles" do
	    html = Nokogiri::HTML(convert("
[preface]
== Preface
"))
		expect(html.xpath("//section[@data-type='preface']/h1").text).to eq("Preface")
	end

	it "should convert appendix titles" do
	    html = Nokogiri::HTML(convert("
[appendix]
== Appendix
"))
		expect(html.xpath("//section[@data-type='appendix']/h1").text).to eq("Appendix")
	end

        it "should convert dedication titles" do
            html = Nokogiri::HTML(convert("== Dedication"))
                expect(html.xpath("//section[@data-type='dedication']/h1").text).to eq("Dedication")
        end

        it "should convert glossary titles" do
            html = Nokogiri::HTML(convert("== Glossary"))
                expect(html.xpath("//section[@data-type='glossary']/h1").text).to eq("Glossary")
        end

        it "should convert foreword titles" do
            html = Nokogiri::HTML(convert("
[preface]
== Foreword"))
                expect(html.xpath("//section[@data-type='foreword']/h1").text).to eq("Foreword")
        end

        # New foreword handling test 5/4/2016 DESK#52924
        it "should convert foreword titles with new syntax" do
            html = Nokogiri::HTML(convert("
[foreword]
== This is my title"))
                expect(html.xpath("//section[@data-type='foreword']/h1").text).to eq("This is my title")
        end

        it "should convert Introduction titles" do
            html = Nokogiri::HTML(convert("
[introduction]
== This is the Introduction"))
                expect(html.xpath("//section[@data-type='introduction']/h1").text).to eq("This is the Introduction")
        end

        it "should convert index titles" do
            html = Nokogiri::HTML(convert("== Index"))
                expect(html.xpath("//section[@data-type='index']/h1").text).to eq("Index")
        end

	it "should convert level 1 headings" do
	    html = Nokogiri::HTML(convert("=== Heading 1"))
		expect(html.xpath("//section[@data-type='sect1']/h1").text).to eq("Heading 1")
	end

	it "should convert level 2 headings" do
		html = Nokogiri::HTML(convert("==== Heading 2"))
		expect(html.xpath("//section[@data-type='sect2']/h2").text).to eq("Heading 2")
	end

	it "should convert level 3 headings" do
		html = Nokogiri::HTML(convert("===== Heading 3"))
		expect(html.xpath("//section[@data-type='sect3']/h3").text).to eq("Heading 3")
	end

	it "should convert level 4 headings" do
		html = Nokogiri::HTML(convert("====== Heading 4"))
		expect(html.xpath("//section[@data-type='sect4']/h4").text).to eq("Heading 4")
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
		expect(html.xpath("//div[@data-type='note']/p[1]").text).to eq("Here is a note with block markup.")
		expect(html.xpath("//div[@data-type='note']/p[2]").text).to eq("Here is a second paragraph.")
	end

	# Tests block_admonition template alternate markup
	it "should convert notes with admonition paragraph markup" do
		html = Nokogiri::HTML(convert("
[NOTE]
Here is a note with paragraph markup.
"))
		expect(html.xpath("//div[@data-type='note']/p").text).to eq("Here is a note with paragraph markup.")
	end

	# Tests block_admonition template second alternate markup
	it "should convert notes with alternate admonition paragraph markup" do
		html = Nokogiri::HTML(convert("
NOTE: Here is a note with alternate paragraph markup.
"))
		expect(html.xpath("//div[@data-type='note']/p").text).to eq("Here is a note with alternate paragraph markup.")
	end


	it "should convert tips" do
	    html = Nokogiri::HTML(convert("
[TIP]
====
Here is some text inside a tip.
====
"))
		expect(html.xpath("//div[@data-type='tip']/p").text).to eq("Here is some text inside a tip.")
	end


	it "should convert warnings" do
	    html = Nokogiri::HTML(convert("
[WARNING]
====
Here is some text inside a warning.
====
"))
		expect(html.xpath("//div[@data-type='warning']/p").text).to eq("Here is some text inside a warning.")
	end

	it "should convert cautions" do
	    html = Nokogiri::HTML(convert("
[CAUTION]
====
Here is some text inside a caution.
====
"))
		expect(html.xpath("//div[@data-type='caution']/p").text).to eq("Here is some text inside a caution.")
	end


	# Tests block_dlist template
	it "should convert definition/variable list terms" do
		html = Nokogiri::HTML(convert("First term:: This is a definition of the first term."))
		expect(html.xpath("//dl/dt").text).to eq("First term")
		expect(html.xpath("//dl/dd/p").text).to eq("This is a definition of the first term.")
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
		expect(html.xpath("//div[@data-type='example']/@id").text).to eq("Example1")
		expect(html.xpath("//div[@data-type='example']/h5").text).to eq("A code block with a title")
		expect(html.xpath("//div[@data-type='example']/pre[@data-type='programlisting']/@data-code-language").text).to eq("php")
		expect(html.xpath("//div[@data-type='example']/pre[@data-type='programlisting']").text).to eq("Hello world")
	end

	# Test linenumbering attribute
	it "should convert line numbering attribute in code listing in formal example" do
		html = Nokogiri::HTML(convert("
[[Example2]]
.Another code block with a title
====
[source, php, linenums]
----
Hello world again
----
====

"))
		expect(html.xpath("//div[@data-type='example'][1]/@id").text).to eq("Example2")
		expect(html.xpath("//div[@data-type='example'][1]/h5").text).to eq("Another code block with a title")
		expect(html.xpath("//div[@data-type='example'][1]/pre[@data-type='programlisting']").text).to eq("Hello world again")
		html.xpath("//pre[1]/@data-line-numbering").text.should_not == ""
		expect(html.xpath("//div[@data-type='example'][1]/pre/@data-line-numbering").text).to eq("numbered")
		expect(html.xpath("//div[@data-type='example'][1]/pre[@data-type='programlisting']/@data-code-language").text).to eq("php")
	end

	it "should convert line numbering attribute in informal code listing" do
		html = Nokogiri::HTML(convert("
[source, php, linenums]
----
Hello world again
----

"))
		expect(html.xpath("//pre[@data-type='programlisting'][1]").text).to eq("Hello world again")
		html.xpath("//pre[1]/@data-line-numbering").text.should_not == ""
		expect(html.xpath("//pre[1]/@data-line-numbering").text).to eq("numbered")
		expect(html.xpath("//pre[@data-type='programlisting'][1]/@data-code-language").text).to eq("php")
	end

	# Tests span nested in source block
	it "should convert spans nested in source blocks" do
		html = Nokogiri::HTML(convert('
[source,sql,subs="verbatim,quotes"]
----
[.nohighlight]#greg@127.0.0.1:44913># SHOW DATABASES;
----
		'))

		listing = html.xpath("//pre[@data-type='programlisting'][1]")
		spans = listing.xpath("//span")
		span = spans[0]
		
		listing.text.should == "greg@127.0.0.1:44913> SHOW DATABASES;"
		spans.count == 1
		span.text.should == "greg@127.0.0.1:44913>"
		span.xpath("//@class") == "nohighlight"
	end

	# Tests block_image template
	it "should convert formal figures" do
		html = Nokogiri::HTML(convert("
[[unique_id1]]
.A Figure
image::images/tiger.png[]
"))
		expect(html.xpath("//figure/@id").text).to eq("unique_id1")
		expect(html.xpath("//figure/figcaption").text).to eq("A Figure")
		expect(html.xpath("//figure/img/@src").text).to eq("images/tiger.png")
		expect(html.xpath("//figure/img/@alt").text).to eq("tiger")
	end


	it "should convert informal figures" do
		html = Nokogiri::HTML(convert("image::images/duck.png[]"))
		html.xpath("//figure/figcaption").size.should == 1
		html.xpath("//figure/@id").size.should == 0
		expect(html.xpath("//figure/img/@src").text).to eq("images/duck.png")
	end

	it "should convert figures with alt-text" do
		html = Nokogiri::HTML(convert("image::images/lion.png['An image of a lion head']"))
		expect(html.xpath("//figure/img/@alt").text).to eq("An image of a lion head")
	end

	it "should convert figures with a width attributes" do
		html = Nokogiri::HTML(convert("image::images/lion.png[width='99in']"))
		expect(html.xpath("//figure/img/@width").text).to eq("99in")
	end

	it "should convert figures with a width attributes when other attributes are present" do
		html = Nokogiri::HTML(convert("image::images/lion.png[width='4in', height='2in']"))
		expect(html.xpath("//figure/img/@width").text).to eq("4in")
	end

	it "should convert figures with a height attributes" do
		html = Nokogiri::HTML(convert("image::images/lion.png[height='3in']"))
		expect(html.xpath("//figure/img/@height").text).to eq("3in")
	end

	it "should convert figures with a height attributes when other attributes are present" do
		html = Nokogiri::HTML(convert("image::images/lion.png[width='5in', height='2in']"))
		expect(html.xpath("//figure/img/@height").text).to eq("2in")
	end


	# Tests block_listing template
	it "should convert informal code blocks" do
		html = Nokogiri::HTML(convert("
[source, php]
----
Hello world
----
"))
		expect(html.xpath("//pre[@data-type='programlisting']/@data-code-language").text).to eq("php")
		expect(html.xpath("//pre[@data-type='programlisting']").text).to eq("Hello world")
	end

	it "should add translate='no' attribute to code blocks" do
		html = Nokogiri::HTML(convert("
[source, ruby]
----
def hello
  puts 'Hello, world!'
end
----
"))
		html.xpath("//pre[@data-type='programlisting']/@translate").text.should == "no"
	end

	# Tests block_literal template - first markup style
	it "should convert literal blocks" do
		html = Nokogiri::HTML(convert("
[literal]
This is a literal block.
"))
		expect(html.xpath("//pre").text).to eq("This is a literal block.")
	end

	# Tests block_literal template - second markup style
	it "should convert literal blocks" do
		html = Nokogiri::HTML(convert(" This is also a literal block."))
		expect(html.xpath("//pre").text).to eq("This is also a literal block.")
	end
	
	it "should add translate='no' attribute to literal blocks" do
		html = Nokogiri::HTML(convert("
....
This is text in a literal block
that should not be translated.
....
"))
		html.xpath("//pre/@translate").text.should == "no"
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
		expect(html.xpath("//div[@data-type='equation']/h5").text).to eq("Equation title")
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
		expect(html.xpath("//ol/li[1]/p[1]").text).to eq("Preparation")
		expect(html.xpath("//ol/li[2]/p[1]").text).to eq("Assembly")
		expect(html.xpath("//ol/li[3]/p[1]").text).to eq("Measure")
		expect(html.xpath("//ol/li[3]/p[2]").text).to eq("Combine")
		expect(html.xpath("//ol/li[3]/p[3]").text).to eq("Bake")
		expect(html.xpath("//ol/li[4]/p[1]").text).to eq("Applause")
	end

	# Tests block_paragraph template
	it "should convert regular paragraphs" do
		html = Nokogiri::HTML(convert("Here is a basic paragraph."))
		expect(html.xpath("//p").text).to eq("Here is a basic paragraph.")
	end

	it "should convert paragraphs with role attributes" do
		html = Nokogiri::HTML(convert("
[role='right']
Here is a basic paragraph.
"))
		expect(html.xpath("//p[@class='right']").text).to eq("Here is a basic paragraph.")
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
		expect(html.xpath("//blockquote/p[1]").text).to eq("Many thanks; I shall lose no time in reading it.")
		expect(html.xpath("//blockquote/p[2]").text).to eq("This is a second paragraph in the quotation.")
		expect(html.xpath("//blockquote/p[@data-type='attribution']").text).to eq("Wilfred Meynell")
	end

	# Tests block_sidebar template
	it "should convert sidebars" do
		html = Nokogiri::HTML(convert("
.Sidebar Title
****
Sidebar text is surrounded by four asterisks.
****
"))
		expect(html.xpath("//aside[@data-type='sidebar']/h1").text).to eq("Sidebar Title")
		expect(html.xpath("//aside[@data-type='sidebar']/p").text).to eq("Sidebar text is surrounded by four asterisks.")
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
		expect(html.xpath("//table/caption").text).to eq("Table Title")
		expect(html.xpath("//table/thead/tr/th[1]").text).to eq("header1")
		expect(html.xpath("//table/thead/tr/th[2]").text).to eq("header2")
		expect(html.xpath("//table/tbody/tr[1]/td[1]/p").text).to eq("row1")
		expect(html.xpath("//table/tbody/tr[1]/td[2]/p/text()").text).to eq("P")
		expect(html.xpath("//table/tbody/tr[1]/td[2]/p/sup").text).to eq("Q")
		expect(html.xpath("//table/tbody/tr[2]/td[1]/p").text).to eq("row2")
		expect(html.xpath("//table/tbody/tr[2]/td[2]/p").text).to eq("col2")
	end

	it "should convert informal tables (no title or header)" do
		html = Nokogiri::HTML(convert("
|=======
|row1|P^Q^
|row2|col2
|=======
"))
		expect(html.xpath("//table/tbody/tr[1]/td[1]/p").text).to eq("row1")
		expect(html.xpath("//table/tbody/tr[1]/td[2]/p/text()").text).to eq("P")
		expect(html.xpath("//table/tbody/tr[1]/td[2]/p/sup").text).to eq("Q")
		expect(html.xpath("//table/tbody/tr[2]/td[1]/p").text).to eq("row2")
		expect(html.xpath("//table/tbody/tr[2]/td[2]/p").text).to eq("col2")
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
		expect(html.xpath("//ul/li[1]/p[1]").text).to eq("lions")
		expect(html.xpath("//ul/li[2]/p[1]").text).to eq("tigers")
		expect(html.xpath("//ul/li[2]/p[2]").text).to eq("sabre-toothed")
		expect(html.xpath("//ul/li[2]/p[3]").text).to eq("teapotted")
		expect(html.xpath("//ul/li[3]/p[1]").text).to eq("lions, tigers, and bears")
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
		expect(html.xpath("//blockquote/p[@data-type='attribution']").text).to eq("— William Blake, Songs of Experience")
	end

	# Tests block_video template
	it "should convert video blocks - first markup style" do
		pending "Not sure why it's failing"
		html = Nokogiri::HTML(convert("
video::gizmo.ogv[width=200]
"))
		expect(html.xpath("//video[@width='200']/source/@src").text).to eq("gizmo.ogv")
		expect(html.xpath("//video/text()").text).to eq("\nSorry, the <video> element is not supported in your reading system.\n")
	end

	# Tests inline_anchor template
	it "should convert inline anchors" do
		html = Nokogiri::HTML(convert("
This is a reference to an <<inlineanchor>>.

See <<inlineanchor, Awesome Chapter>>
"))
		expect(html.xpath("//p[1]/a/@href").text).to eq("#inlineanchor")
		expect(html.xpath("//p[1]/a").text).to eq("")
		expect(html.xpath("//p[2]/a/@href").text).to eq("#inlineanchor")
		expect(html.xpath("//p[2]/a").text).to eq("Awesome Chapter")
	end

        it "should convert inline anchors" do
                html = Nokogiri::HTML(convert("
This is a link without a text node: http://www.oreilly.com

This is a link with a text node: http://www.oreilly.com[check out this text node]
"))
                expect(html.xpath("//p[1]/a/@href").text).to eq("http://www.oreilly.com")
                expect(html.xpath("//p[1]/a/em[@class='hyperlink']").text).to eq("http://www.oreilly.com")
                expect(html.xpath("//p[2]/a/@href").text).to eq("http://www.oreilly.com")
                expect(html.xpath("//p[2]/a[not(*)]").text).to eq("check out this text node")
        end

    # Callout handling

    it "should convert inline callouts while preserving whitespace" do
		html = Nokogiri::HTML(convert("
== Required title

----
Hello World <1>
Hello Again <2>

Thrice Hello <3>
{
   Blah
}

Fourth Hello <4>
----


"))		
		expect(html.xpath("//pre[@data-type='programlisting']").text).to eq("Hello World \nHello Again \n\nThrice Hello \n{\n   Blah\n}\n\nFourth Hello ")
		end

	# Tests block_colist template
	it "should convert calloutlists with a code example preceding" do
		html = Nokogiri::HTML(convert("
== Required title

----
Hello World <1>
Hello Again <2>
----

<1> First time.
<2> Second time.
"))
		expect(html.xpath("//dl/dt[1]/a/@class").text).to eq("co")
		expect(html.xpath("//dl/dt[1]/a/@href").text).to eq("#co_required_title_CO1-1")
		expect(html.xpath("//dl/dt[1]/a/@id").text).to eq("callout_required_title_CO1-1")
		expect(html.xpath("//dl/dt[1]/a/img/@src").text).to eq("callouts/1.png")
		expect(html.xpath("//dl/dt[1]/a/img/@alt").text).to eq("1")

		expect(html.xpath("//dl/dt[2]/a/@class").text).to eq("co")
		expect(html.xpath("//dl/dt[2]/a/@href").text).to eq("#co_required_title_CO1-2")
		expect(html.xpath("//dl/dt[2]/a/@id").text).to eq("callout_required_title_CO1-2")
		expect(html.xpath("//dl/dt[2]/a/img/@src").text).to eq("callouts/2.png")
		expect(html.xpath("//dl/dt[2]/a/img/@alt").text).to eq("2")
		end

		it "should convert calloutlists with a code example preceding with duplicate callouts in code" do
			html = Nokogiri::HTML(convert("
== Required title

----
Hello World <1>
IVE BEEN DUPED <1>
Hello Again <2>
----

<1> First time.
<2> Second time.
"))			
			expect(html.xpath("//dl/dt[1]/a/@class").text).to eq("co")
			expect(html.xpath("//dl/dt[1]/a/@href").text).to eq("#co_required_title_CO1-1")
			expect(html.xpath("//dl/dt[1]/a/@id").text).to eq("callout_required_title_CO1-1")
			expect(html.xpath("//dl/dt[1]/a/img/@src").text).to eq("callouts/1.png")
			expect(html.xpath("//dl/dt[1]/a/img/@alt").text).to eq("1")

			expect(html.xpath("//dl/dt[2]/a/@class").text).to eq("co")
			expect(html.xpath("//dl/dt[2]/a/@href").text).to eq("#co_required_title_CO1-3")
			expect(html.xpath("//dl/dt[2]/a/@id").text).to eq("callout_required_title_CO1-2")
			expect(html.xpath("//dl/dt[2]/a/img/@src").text).to eq("callouts/2.png")
			expect(html.xpath("//dl/dt[2]/a/img/@alt").text).to eq("2")
			end

		it "should convert calloutlists with a code example preceding with callouts out of order" do
			html = Nokogiri::HTML(convert("
== Required title

----
Second is the best <2>
Hey you cheated! <1>
What evs. <1>
----

<1> First time.
<2> Second time.
"))
			expect(html.xpath("//dl/dt[1]/a/@class").text).to eq("co")
			expect(html.xpath("//dl/dt[1]/a/@href").text).to eq("#co_required_title_CO1-2")
			expect(html.xpath("//dl/dt[1]/a/@id").text).to eq("callout_required_title_CO1-1")
			expect(html.xpath("//dl/dt[1]/a/img/@src").text).to eq("callouts/1.png")
			expect(html.xpath("//dl/dt[1]/a/img/@alt").text).to eq("1")

			expect(html.xpath("//dl/dt[2]/a/@class").text).to eq("co")
			expect(html.xpath("//dl/dt[2]/a/@href").text).to eq("#co_required_title_CO1-1")
			expect(html.xpath("//dl/dt[2]/a/@id").text).to eq("callout_required_title_CO1-2")
			expect(html.xpath("//dl/dt[2]/a/img/@src").text).to eq("callouts/2.png")
			expect(html.xpath("//dl/dt[2]/a/img/@alt").text).to eq("2")
			end

		it "should convert calloutlists with a code example preceding with duplicate callouts with callouts out of order" do
			html = Nokogiri::HTML(convert("
== Required title

----
Second is the best <2>
Hey you cheated! <1>
Yeah me too. <2>
----

<1> First time.
<2> Second time.
"))
			expect(html.xpath("//dl/dt[1]/a/@class").text).to eq("co")
			expect(html.xpath("//dl/dt[1]/a/@href").text).to eq("#co_required_title_CO1-2")
			expect(html.xpath("//dl/dt[1]/a/@id").text).to eq("callout_required_title_CO1-1")
			expect(html.xpath("//dl/dt[1]/a/img/@src").text).to eq("callouts/1.png")
			expect(html.xpath("//dl/dt[1]/a/img/@alt").text).to eq("1")

			expect(html.xpath("//dl/dt[2]/a/@class").text).to eq("co")
			expect(html.xpath("//dl/dt[2]/a/@href").text).to eq("#co_required_title_CO1-1")
			expect(html.xpath("//dl/dt[2]/a/@id").text).to eq("callout_required_title_CO1-2")
			expect(html.xpath("//dl/dt[2]/a/img/@src").text).to eq("callouts/2.png")
			expect(html.xpath("//dl/dt[2]/a/img/@alt").text).to eq("2")
			end

		it "should convert calloutlists with a code example preceding when a number in the calloutlist does not correspond to a code callout" do
			html = Nokogiri::HTML(convert("
== Required title

----
We good, we good <1>
I suppose. <2>
----

<1> This is true.
<3> Third time is a... mistake.
"))
			expect(html.xpath("//dl/dt[1]/a/@class").text).to eq("co")
			expect(html.xpath("//dl/dt[1]/a/@href").text).to eq("#co_required_title_CO1-1")
			expect(html.xpath("//dl/dt[1]/a/@id").text).to eq("callout_required_title_CO1-1")
			expect(html.xpath("//dl/dt[1]/a/img/@src").text).to eq("callouts/1.png")
			expect(html.xpath("//dl/dt[1]/a/img/@alt").text).to eq("1")

			expect(html.xpath("//dl/dt[2]/a/@class").text).to eq("co")
			expect(html.xpath("//dl/dt[2]/a/@href").text).to eq("#co_required_title_CO1-2")
			expect(html.xpath("//dl/dt[2]/a/@id").text).to eq("callout_required_title_CO1-2")
			expect(html.xpath("//dl/dt[2]/a/img/@src").text).to eq("callouts/2.png")
			expect(html.xpath("//dl/dt[2]/a/img/@alt").text).to eq("2")
			end

	it "should convert calloutlists without a code example preceding" do
		html = Nokogiri::HTML(convert("
== Required title

Friends, Dean Roman, and countrymen. It's time for an IT meeting.

<1> This is a calloutlist item.
<2> Maybe we should have waited for some code.
"))
			expect(html.xpath("//dl/dt[1]/a/@class").text).to eq("co")
			expect(html.xpath("//dl/dt[1]/a/@href").text).to eq("#co_required_title_")
			expect(html.xpath("//dl/dt[1]/a/@id").text).to eq("callout_required_title_")
			expect(html.xpath("//dl/dt[1]/a/img/@src").text).to eq("callouts/1.png")
			expect(html.xpath("//dl/dt[1]/a/img/@alt").text).to eq("1")

			expect(html.xpath("//dl/dt[2]/a/@class").text).to eq("co")
			expect(html.xpath("//dl/dt[2]/a/@href").text).to eq("#co_required_title_")
			expect(html.xpath("//dl/dt[2]/a/@id").text).to eq("callout_required_title_")
			expect(html.xpath("//dl/dt[2]/a/img/@src").text).to eq("callouts/2.png")
			expect(html.xpath("//dl/dt[2]/a/img/@alt").text).to eq("2")
		end

	it "should convert calloutlists without a code example preceding with non sequential list numbering" do
		html = Nokogiri::HTML(convert("
== Required title

MINOR TWEAK ON PREVIOUS TEST... one more time shall we?
Friends, Dean Roman, and countrymen. It's time for an IT meeting.

<1> This is a calloutlist item.
<3> Maybe we should have waited for some code.
"))
			expect(html.xpath("//dl/dt[1]/a/@class").text).to eq("co")
			expect(html.xpath("//dl/dt[1]/a/@href").text).to eq("#co_required_title_")
			expect(html.xpath("//dl/dt[1]/a/@id").text).to eq("callout_required_title_")
			expect(html.xpath("//dl/dt[1]/a/img/@src").text).to eq("callouts/1.png")
			expect(html.xpath("//dl/dt[1]/a/img/@alt").text).to eq("1")

			expect(html.xpath("//dl/dt[2]/a/@class").text).to eq("co")
			expect(html.xpath("//dl/dt[2]/a/@href").text).to eq("#co_required_title_")
			expect(html.xpath("//dl/dt[2]/a/@id").text).to eq("callout_required_title_")
			expect(html.xpath("//dl/dt[2]/a/img/@src").text).to eq("callouts/2.png")
			expect(html.xpath("//dl/dt[2]/a/img/@alt").text).to eq("2")
		end

	# Tests inline_callout template 
	it "should convert inline callouts in code with a calloutlist following"  do
		html = Nokogiri::HTML(convert("
== Required title

----
Hello World <1>
Hello Again <2>
----

<1> First time.
<2> Second time.
"))
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/@class").text).to eq("co")
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/@href").text).to eq("#callout_required_title_CO1-1")
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/@id").text).to eq("co_required_title_CO1-1")
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/img/@src").text).to eq("callouts/1.png")
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/img/@alt").text).to eq("1")

			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/@class").text).to eq("co")
			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/@href").text).to eq("#callout_required_title_CO1-2")
			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/@id").text).to eq("co_required_title_CO1-2")
			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/img/@src").text).to eq("callouts/2.png")
			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/img/@alt").text).to eq("2")
		end

		it "should convert inline callouts in code with duplicate callouts in code with a calloutlist following" do
		html = Nokogiri::HTML(convert("
== Required title

----
Hello World <1>
Hello Again <2>
Hello THRICE <2>
----

<1> First time.
<2> Second time.
"))
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/@class").text).to eq("co")
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/@href").text).to eq("#callout_required_title_CO1-1")
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/@id").text).to eq("co_required_title_CO1-1")
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/img/@src").text).to eq("callouts/1.png")
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/img/@alt").text).to eq("1")

			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/@class").text).to eq("co")
			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/@href").text).to eq("#callout_required_title_CO1-2")
			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/@id").text).to eq("co_required_title_CO1-2")
			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/img/@src").text).to eq("callouts/2.png")
			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/img/@alt").text).to eq("2")

			expect(html.xpath("//pre[@data-type='programlisting']/a[3]/@class").text).to eq("co")
			expect(html.xpath("//pre[@data-type='programlisting']/a[3]/@href").text).to eq("#callout_required_title_CO1-2")
			expect(html.xpath("//pre[@data-type='programlisting']/a[3]/@id").text).to eq("co_required_title_CO1-3")
			expect(html.xpath("//pre[@data-type='programlisting']/a[3]/img/@src").text).to eq("callouts/2.png")
			expect(html.xpath("//pre[@data-type='programlisting']/a[3]/img/@alt").text).to eq("2")
			end

		it "should convert inline callouts in code with callouts out of order with a calloutlist following" do
		html = Nokogiri::HTML(convert("
== Required Title

----
And so I cry sometimes <4>
when I'm lying in bed  <2>
Just to get it all out <3>
What's in my head <1>
----

<1> I'm feeling.
<2> A little peculiar.
<3> I wake up in the morning
<4> and I step outside...
"))
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/@class").text).to eq("co")
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/@href").text).to eq("#callout_required_title_CO1-4")
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/@id").text).to eq("co_required_title_CO1-1")
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/img/@src").text).to eq("callouts/4.png")
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/img/@alt").text).to eq("4")

			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/@class").text).to eq("co")
			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/@href").text).to eq("#callout_required_title_CO1-2")
			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/@id").text).to eq("co_required_title_CO1-2")
			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/img/@src").text).to eq("callouts/2.png")
			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/img/@alt").text).to eq("2")

			expect(html.xpath("//pre[@data-type='programlisting']/a[3]/@class").text).to eq("co")
			expect(html.xpath("//pre[@data-type='programlisting']/a[3]/@href").text).to eq("#callout_required_title_CO1-3")
			expect(html.xpath("//pre[@data-type='programlisting']/a[3]/@id").text).to eq("co_required_title_CO1-3")
			expect(html.xpath("//pre[@data-type='programlisting']/a[3]/img/@src").text).to eq("callouts/3.png")
			expect(html.xpath("//pre[@data-type='programlisting']/a[3]/img/@alt").text).to eq("3")

			expect(html.xpath("//pre[@data-type='programlisting']/a[4]/@class").text).to eq("co")
			expect(html.xpath("//pre[@data-type='programlisting']/a[4]/@href").text).to eq("#callout_required_title_CO1-1")
			expect(html.xpath("//pre[@data-type='programlisting']/a[4]/@id").text).to eq("co_required_title_CO1-4")
			expect(html.xpath("//pre[@data-type='programlisting']/a[4]/img/@src").text).to eq("callouts/1.png")
			expect(html.xpath("//pre[@data-type='programlisting']/a[4]/img/@alt").text).to eq("1")
			end

		it "should convert inline callouts in code with duplicate callouts with callouts out of order with a calloutlist following" do
		html = Nokogiri::HTML(convert("
== Required Title

----
And so I cry sometimes <3>
when I'm lying in bed  <2>
Just to get it all out <3>
What's in my head <1>
----

<1> I'm feeling.
<2> A little peculiar.
<3> I wake up in the morning
"))
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/@class").text).to eq("co")
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/@href").text).to eq("#callout_required_title_CO1-3")
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/@id").text).to eq("co_required_title_CO1-1")
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/img/@src").text).to eq("callouts/3.png")
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/img/@alt").text).to eq("3")

			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/@class").text).to eq("co")
			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/@href").text).to eq("#callout_required_title_CO1-2")
			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/@id").text).to eq("co_required_title_CO1-2")
			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/img/@src").text).to eq("callouts/2.png")
			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/img/@alt").text).to eq("2")

			expect(html.xpath("//pre[@data-type='programlisting']/a[3]/@class").text).to eq("co")
			expect(html.xpath("//pre[@data-type='programlisting']/a[3]/@href").text).to eq("#callout_required_title_CO1-3")
			expect(html.xpath("//pre[@data-type='programlisting']/a[3]/@id").text).to eq("co_required_title_CO1-3")
			expect(html.xpath("//pre[@data-type='programlisting']/a[3]/img/@src").text).to eq("callouts/3.png")
			expect(html.xpath("//pre[@data-type='programlisting']/a[3]/img/@alt").text).to eq("3")

			expect(html.xpath("//pre[@data-type='programlisting']/a[4]/@class").text).to eq("co")
			expect(html.xpath("//pre[@data-type='programlisting']/a[4]/@href").text).to eq("#callout_required_title_CO1-1")
			expect(html.xpath("//pre[@data-type='programlisting']/a[4]/@id").text).to eq("co_required_title_CO1-4")
			expect(html.xpath("//pre[@data-type='programlisting']/a[4]/img/@src").text).to eq("callouts/1.png")
			expect(html.xpath("//pre[@data-type='programlisting']/a[4]/img/@alt").text).to eq("1")
			end

		it "should convert inline callouts in code with a calloutlist following, when a callout in the code refers to a calloutlist number that does not exist" do
			html = Nokogiri::HTML(convert("
== Required Title

----
Sup dawg <1>
nm u  <2>
nm nm, just pointing to an item that doesn't exist <3>

----

<1> I'm a dude
<2> He's a dude.
")) 
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/@class").text).to eq("co")
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/@href").text).to eq("#callout_required_title_CO1-1")
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/@id").text).to eq("co_required_title_CO1-1")
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/img/@src").text).to eq("callouts/1.png")
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/img/@alt").text).to eq("1")

			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/@class").text).to eq("co")
			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/@href").text).to eq("#callout_required_title_CO1-2")
			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/@id").text).to eq("co_required_title_CO1-2")
			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/img/@src").text).to eq("callouts/2.png")
			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/img/@alt").text).to eq("2")

			expect(html.xpath("//pre[@data-type='programlisting']/a[3]/@class").text).to eq("co")
			expect(html.xpath("//pre[@data-type='programlisting']/a[3]/@href").text).to eq("#callout_required_title_CO1-3")
			expect(html.xpath("//pre[@data-type='programlisting']/a[3]/@id").text).to eq("co_required_title_CO1-3")
			expect(html.xpath("//pre[@data-type='programlisting']/a[3]/img/@src").text).to eq("callouts/3.png")
			expect(html.xpath("//pre[@data-type='programlisting']/a[3]/img/@alt").text).to eq("3")
			end

	it "should convert inline callouts in code without a calloutlist following"  do
		html = Nokogiri::HTML(convert("
== Required Title

----
Strawberry ice cream is great <1>
But nothing is better than Moose tracks. <2>
Yeah, I agree. Moose tracks is the best. <3>
That choco fudge folded in is totes yum. <4>
----

"))
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/@class").text).to eq("co")
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/@href").text).to eq("#callout_required_title_CO1-1")
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/@id").text).to eq("co_required_title_CO1-1")
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/img/@src").text).to eq("callouts/1.png")
			expect(html.xpath("//pre[@data-type='programlisting']/a[1]/img/@alt").text).to eq("1")

			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/@class").text).to eq("co")
			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/@href").text).to eq("#callout_required_title_CO1-2")
			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/@id").text).to eq("co_required_title_CO1-2")
			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/img/@src").text).to eq("callouts/2.png")
			expect(html.xpath("//pre[@data-type='programlisting']/a[2]/img/@alt").text).to eq("2")

			expect(html.xpath("//pre[@data-type='programlisting']/a[3]/@class").text).to eq("co")
			expect(html.xpath("//pre[@data-type='programlisting']/a[3]/@href").text).to eq("#callout_required_title_CO1-3")
			expect(html.xpath("//pre[@data-type='programlisting']/a[3]/@id").text).to eq("co_required_title_CO1-3")
			expect(html.xpath("//pre[@data-type='programlisting']/a[3]/img/@src").text).to eq("callouts/3.png")
			expect(html.xpath("//pre[@data-type='programlisting']/a[3]/img/@alt").text).to eq("3")
			
			expect(html.xpath("//pre[@data-type='programlisting']/a[4]/@class").text).to eq("co")
			expect(html.xpath("//pre[@data-type='programlisting']/a[4]/@href").text).to eq("#callout_required_title_CO1-4")
			expect(html.xpath("//pre[@data-type='programlisting']/a[4]/@id").text).to eq("co_required_title_CO1-4")
			expect(html.xpath("//pre[@data-type='programlisting']/a[4]/img/@src").text).to eq("callouts/4.png")
			expect(html.xpath("//pre[@data-type='programlisting']/a[4]/img/@alt").text).to eq("4")
		end


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
#    		expect(html.xpath("//pre[@data-type='programlisting']/a[1]").text).to eq("(1)")
#    		expect(html.xpath("//pre[@data-type='programlisting']/b[2]").text).to eq("(2)")
#    		expect(html.xpath("//ol[@class='calloutlist']/li[1]/p").text).to eq("➊ This is a fact.")
#    		expect(html.xpath("//ol[@class='calloutlist']/li[2]/p").text).to eq("➋ This poem uses the literary device known as a surprise ending.")
# 	end

	# Tests inline_footnote template
	it "should convert footnotes and footnoterefs" do
		html = Nokogiri::HTML(convert("
A footnote.footnote:[An example footnote.]

A second footnote with a reference ID.footnoteref:[note2,Second footnote.]

Finally a reference to the second footnote.footnoteref:[note2]
"))
		expect(html.xpath("//p[1]/span[@data-type='footnote']").text).to eq("An example footnote.")
		html.xpath("//p[1]/span[@data-type='footnote']/@id").size.should == 0
		expect(html.xpath("//p[2]/span[@data-type='footnote']").text).to eq("Second footnote.")
		expect(html.xpath("//p[2]/span[@data-type='footnote']/@id").text).to eq("note2")
		html.xpath("//p[3]/a[@data-type='footnoteref']/text()").size.should == 0
		expect(html.xpath("//p[3]/a[@data-type='footnoteref']/@href").text).to eq("#note2")
	end

	# Tests inline_image template
	it "should convert inline images" do
		html = Nokogiri::HTML(convert("Here is an inline figure: image:images/logo.png[]"))
		expect(html.xpath("//p/img/@src").text).to eq("images/logo.png")
	end

	# Tests inline_quoted template
	it "should convert inline formatting" do
		html = Nokogiri::HTML(convert("This para has __emphasis__, *bold**, ++literal++, ^superscript^, ~subscript~, __++replaceable++__, and *+userinput+*."))
		expect(html.xpath("//p/em[1]").text).to eq("emphasis")
		expect(html.xpath("//p/strong[1]").text).to eq("bold")
		expect(html.xpath("//p/code[1]").text).to eq("literal")
		expect(html.xpath("//p/sup").text).to eq("superscript")
		expect(html.xpath("//p/sub").text).to eq("subscript")
		expect(html.xpath("//p/em/code").text).to eq("replaceable")
		expect(html.xpath("//p/strong/code").text).to eq("userinput")
	end

	it "should add translate='no' attribute to inline code elements" do
		html = Nokogiri::HTML(convert("This para has some ++inline code++ in it."))
		html.xpath("//p/code[1]/@translate").text.should == "no"
	end

	# Tests math in inline_quoted template
	it "should convert inline latexmath equations with dollar sign delimeters to use standard delimiters" do
		html = Nokogiri::HTML(convert("The Pythagorean Theorem is latexmath:[$a^2 + b^2 = c^2$]"))
		expect(html.xpath("//p/span[@data-type='tex']").text).to eq("\\(a^2 + b^2 = c^2\\)")
	end
	it "should convert inline latexmath equations with standard delimiters with no change" do
		html = Nokogiri::HTML(convert("The Pythagorean Theorem is latexmath:[\\(a^2 + b^2 = c^2\\)]"))
		expect(html.xpath("//p/span[@data-type='tex']").text).to eq("\\(a^2 + b^2 = c^2\\)")
	end
	it "should convert inline latexmath equations with no delimiters and add delimiters" do
		html = Nokogiri::HTML(convert("The Pythagorean Theorem is latexmath:[a^2 + b^2 = c^2]"))
		expect(html.xpath("//p/span[@data-type='tex']").text).to eq("\\(a^2 + b^2 = c^2\\)")
	end
	it "should convert inline asciimath equations with dollar sign delimeters with no change" do
		html = Nokogiri::HTML(convert("The Pythagorean Theorem is asciimath:[\$a^2 + b^2 = c^2\$]"))
		expect(html.xpath("//p/span[@data-type='tex']").text).to eq("\$a^2 + b^2 = c^2\$")
	end
	it "should convert inline asciimath equations with no delimeters and add delimiters" do
		html = Nokogiri::HTML(convert("The Pythagorean Theorem is asciimath:[a^2 + b^2 = c^2]"))
		expect(html.xpath("//p/span[@data-type='tex']").text).to eq("\$a^2 + b^2 = c^2\$")
	end

	# Tests inline_indexterm template - source markup is in files/indexterm_testing.asciidoc
	it "should convert inline indexterms with one term" do
		html = Nokogiri::HTML(convert_indexterm_tests)
		# Primary only, with quation marks
		expect(html.xpath("//section[@data-type='sect1'][1]/section[@data-type='sect2'][1]/p[1]/a/@data-type").text).to eq("indexterm")
		expect(html.xpath("//section[@data-type='sect1'][1]/section[@data-type='sect2'][1]/p[1]/a/@data-primary").text).to eq("metaclass")
		# Primary only, without quotation marks
		expect(html.xpath("//section[@data-type='sect1'][1]/section[@data-type='sect2'][1]/p[2]/a/@data-type").text).to eq("indexterm")
		expect(html.xpath("//section[@data-type='sect1'][1]/section[@data-type='sect2'][1]/p[2]/a/@data-primary").text).to eq("accessibility")
	end

	it "should convert inline indexterms with two terms" do
		html = Nokogiri::HTML(convert_indexterm_tests)
		# Primary only
		expect(html.xpath("//section[@data-type='sect1'][2]/section[@data-type='sect2'][1]/p[1]/a/@data-see").text).to eq("aspect-oriented")
		expect(html.xpath("//section[@data-type='sect1'][2]/section[@data-type='sect2'][1]/p[2]/a/@data-seealso").text).to eq("namespace")
		expect(html.xpath("//section[@data-type='sect1'][2]/section[@data-type='sect2'][1]/p[3]/a/@data-primary-sortas").text).to eq("patterns")
		expect(html.xpath("//section[@data-type='sect1'][2]/section[@data-type='sect2'][1]/p[4]/a/@id").text).to eq("dynamic")
		expect(html.xpath("//section[@data-type='sect1'][2]/section[@data-type='sect2'][1]/p[5]/a/@data-startref").text).to eq("dynamic")
		# Secondary
		expect(html.xpath("//section[@data-type='sect1'][2]/section[@data-type='sect2'][2]/p[1]/a/@data-secondary").text).to eq("eigenclass")
	end

	it "should convert inline indexterms with three terms" do
		html = Nokogiri::HTML(convert_indexterm_tests)
		# Primary only
		expect(html.xpath("//section[@data-type='sect1'][3]/section[@data-type='sect2'][1]/p[1]/a/@id").text).to eq("orthogonality")
		expect(html.xpath("//section[@data-type='sect1'][3]/section[@data-type='sect2'][1]/p[2]/a/@data-see").text).to eq("destructor")
		expect(html.xpath("//section[@data-type='sect1'][3]/section[@data-type='sect2'][1]/p[2]/a/@data-seealso").text).to eq("factory method")
		# Secondary
		expect(html.xpath("//section[@data-type='sect1'][3]/section[@data-type='sect2'][2]/p[1]/a/@data-secondary").text).to eq("immutable")
		expect(html.xpath("//section[@data-type='sect1'][3]/section[@data-type='sect2'][2]/p[1]/a/@data-see").text).to eq("instance method")
		expect(html.xpath("//section[@data-type='sect1'][3]/section[@data-type='sect2'][2]/p[2]/a/@data-seealso").text).to eq("partial class")
		expect(html.xpath("//section[@data-type='sect1'][3]/section[@data-type='sect2'][2]/p[3]/a/@data-secondary-sortas").text).to eq("iterator")
		# Tertiary, with quotation marks
		expect(html.xpath("//section[@data-type='sect1'][3]/section[@data-type='sect2'][3]/p[1]/a/@data-secondary").text).to eq("virtual class")
		expect(html.xpath("//section[@data-type='sect1'][3]/section[@data-type='sect2'][3]/p[1]/a/@data-tertiary").text).to eq("subtype")
		# Tertiary, without quotation marks
		expect(html.xpath("//section[@data-type='sect1'][3]/section[@data-type='sect2'][3]/p[2]/a/@data-secondary").text).to eq("test-driven development")
		expect(html.xpath("//section[@data-type='sect1'][3]/section[@data-type='sect2'][3]/p[2]/a/@data-tertiary").text).to eq("weak reference")		
	end

	it "should convert inline indexterms with four terms" do
		html = Nokogiri::HTML(convert_indexterm_tests)
		# Primary only
		expect(html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][1]/p[1]/a/@id").text).to eq("slicing")
		expect(html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][1]/p[1]/a/@data-see").text).to eq("access control")
		expect(html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][1]/p[2]/a/@data-seealso").text).to eq("hybrid")
		expect(html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][1]/p[3]/a/@data-primary-sortas").text).to eq("uninitialized")
		expect(html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][1]/p[4]/a/@data-see").text).to eq("mutator method")
		expect(html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][1]/p[4]/a/@data-seealso").text).to eq("policy-based design")
		# Secondary
		expect(html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][2]/p[1]/a/@data-secondary").text).to eq("viscosity")
		expect(html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][2]/p[1]/a/@id").text).to eq("encapsulation")
		expect(html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][2]/p[2]/a/@data-secondary").text).to eq("superclass")
		expect(html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][2]/p[2]/a/@data-see").text).to eq("typecasting")
		expect(html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][2]/p[2]/a/@data-seealso").text).to eq("virtual inheritance")
		# Tertiary
		expect(html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][3]/p[1]/a/@data-secondary").text).to eq("shadowed name")
		expect(html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][3]/p[1]/a/@data-tertiary").text).to eq("function")
		expect(html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][3]/p[1]/a/@data-see").text).to eq("late binding")
		expect(html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][3]/p[2]/a/@data-secondary").text).to eq("array")
		expect(html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][3]/p[2]/a/@data-tertiary").text).to eq("compiler")
		expect(html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][3]/p[2]/a/@data-seealso").text).to eq("subroutine")
		expect(html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][3]/p[3]/a/@data-secondary").text).to eq("stack")
		expect(html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][3]/p[3]/a/@data-tertiary").text).to eq("paradigm")
		expect(html.xpath("//section[@data-type='sect1'][4]/section[@data-type='sect2'][3]/p[3]/a/@data-tertiary-sortas").text).to eq("enumerable")
	end

	it "should convert inline indexterms with five terms" do
		html = Nokogiri::HTML(convert_indexterm_tests)
		# Primary only
		expect(html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][1]/p[1]/a/@id").text).to eq("mapping")
		expect(html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][1]/p[1]/a/@data-see").text).to eq("overload")
		expect(html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][1]/p[1]/a/@data-seealso").text).to eq("parse")
		# Secondary
		expect(html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][2]/p[1]/a/@data-secondary").text).to eq("token")
		expect(html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][2]/p[1]/a/@id").text).to eq("syntax")
		expect(html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][2]/p[1]/a/@data-see").text).to eq("binary")
		expect(html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][2]/p[2]/a/@data-secondary").text).to eq("conditional")
		expect(html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][2]/p[2]/a/@id").text).to eq("collection")
		expect(html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][2]/p[2]/a/@data-seealso").text).to eq("alias")
		expect(html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][2]/p[3]/a/@data-secondary").text).to eq("operation")
		expect(html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][2]/p[3]/a/@id").text).to eq("semantics")
		expect(html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][2]/p[3]/a/@data-secondary-sortas").text).to eq("parameter")
		expect(html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][2]/p[4]/a/@data-secondary").text).to eq("abstraction")
		expect(html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][2]/p[4]/a/@id").text).to eq("constant")
		expect(html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][2]/p[4]/a/@data-see").text).to eq("arithmetic operator")
		expect(html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][2]/p[4]/a/@data-seealso").text).to eq("base type")
		# Tertiary
		expect(html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][3]/p[1]/a/@data-secondary").text).to eq("deprecated")
		expect(html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][3]/p[1]/a/@data-tertiary").text).to eq("finalization")
		expect(html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][3]/p[1]/a/@id").text).to eq("little-endian")
		expect(html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][3]/p[2]/a/@data-secondary").text).to eq("parallel")
		expect(html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][3]/p[2]/a/@data-tertiary").text).to eq("scheme")
		expect(html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][3]/p[2]/a/@data-see").text).to eq("ternary")
		expect(html.xpath("//section[@data-type='sect1'][5]/section[@data-type='sect2'][3]/p[2]/a/@data-seealso").text).to eq("exception")
	end

	it "should convert inline indexterms with six terms" do
		html = Nokogiri::HTML(convert_indexterm_tests)
		# Secondary
		expect(html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][1]/p[1]/a/@data-secondary").text).to eq("while loop")
		expect(html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][1]/p[1]/a/@id").text).to eq("retro")
		expect(html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][1]/p[1]/a/@data-see").text).to eq("top-level class")
		expect(html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][1]/p[1]/a/@data-seealso").text).to eq("unary")
		# Tertiary
		expect(html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][2]/p[1]/a/@data-secondary").text).to eq("precedence")
		expect(html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][2]/p[1]/a/@data-tertiary").text).to eq("overriding")
		expect(html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][2]/p[1]/a/@id").text).to eq("lightweight")
		expect(html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][2]/p[1]/a/@data-see").text).to eq("infinite")
		expect(html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][2]/p[2]/a/@data-secondary").text).to eq("encapsulation")
		expect(html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][2]/p[2]/a/@data-tertiary").text).to eq("condition")
		expect(html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][2]/p[2]/a/@id").text).to eq("aggregation")
		expect(html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][2]/p[2]/a/@data-seealso").text).to eq("boundary")
		expect(html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][2]/p[3]/a/@data-secondary").text).to eq("classpath")
		expect(html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][2]/p[3]/a/@data-tertiary").text).to eq("import")
		expect(html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][2]/p[3]/a/@id").text).to eq("datagram")
		expect(html.xpath("//section[@data-type='sect1'][6]/section[@data-type='sect2'][2]/p[3]/a/@data-tertiary-sortas").text).to eq("method")
	end

	it "should convert inline indexterms with seven terms" do
		html = Nokogiri::HTML(convert_indexterm_tests)
		# Tertiary
		expect(html.xpath("//section[@data-type='sect1'][7]/p[1]/a/@data-secondary").text).to eq("public")
		expect(html.xpath("//section[@data-type='sect1'][7]/p[1]/a/@data-tertiary").text).to eq("relational")
		expect(html.xpath("//section[@data-type='sect1'][7]/p[1]/a/@id").text).to eq("cascaded")
		expect(html.xpath("//section[@data-type='sect1'][7]/p[1]/a/@data-see").text).to eq("inline")
		expect(html.xpath("//section[@data-type='sect1'][7]/p[1]/a/@data-seealso").text).to eq("private")
	end

	it "should convert inline indexterm next-gen sortas attributes properly (primary-sortas, secondary-sortas, tertiary-sortas)" do
		html = Nokogiri::HTML(convert_indexterm_tests)
		expect(html.xpath("//section[@id='sortas_tests']/p[1]/a/@data-primary-sortas").text).to eq("one")
		expect(html.xpath("//section[@id='sortas_tests']/p[1]/a/@data-secondary-sortas").text).to eq("two")
		expect(html.xpath("//section[@id='sortas_tests']/p[1]/a/@data-tertiary-sortas").text).to eq("three")
	end

        it "should ignore legacy sortas when primary, secondary, or tertiary sortas are present" do
               html = Nokogiri::HTML(convert_indexterm_tests)
               html.xpath("//section[@id='sortas_tests']/p[position() > 1]/a/@*[contains(., 'ignoreme')]").length.should == 0
               expect(html.xpath("//section[@id='sortas_tests']/p[2]/a/@data-primary-sortas").text).to eq("one")
               expect(html.xpath("//section[@id='sortas_tests']/p[3]/a/@data-secondary-sortas").text).to eq("two")
               expect(html.xpath("//section[@id='sortas_tests']/p[4]/a/@data-tertiary-sortas").text).to eq("three")
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
	# 	expect(html.xpath("//section[@data-type='sect1'][1]/p[1]/span[@class='keep-together']").text).to eq("DocBook phrase element")
	# 	expect(html.xpath("//section[@data-type='sect1'][1]/p[2]/code").text).to eq("DocBook code element")
	# end

	# it "should convert block DocBook passthroughs to HTMLBook" do
	# 	html = Nokogiri::HTML(convert_passthrough_tests)
	# 	expect(html.xpath("//section[@data-type='sect1'][2]/pre[@data-type='programlisting']/strong/code").text).to eq("first line of code here")
	# 	expect(html.xpath("//section[@data-type='sect1'][2]/figure/figcaption").text).to eq("DocBook Figure Markup")
	# 	expect(html.xpath("//section[@data-type='sect1'][2]/figure/img/@src").text).to eq("images/docbook.png")
	# 	expect(html.xpath("//section[@data-type='sect1'][2]/blockquote/p[@data-type='attribution']").text).to eq("Lewis Carroll")
	# 	html.xpath("//section[@data-type='sect1'][2]/blockquote/p").text.should start_with "Alice was beginning to get very tired"
	# end

	# it "should not convert inline HTML block passthroughs" do
	# 	html = Nokogiri::HTML(convert_passthrough_tests)
	# 	expect(html.xpath("//section[@data-type='sect1'][3]/p[1]/strong").text).to eq("HTML strong element")
	# 	expect(html.xpath("//section[@data-type='sect1'][3]/p[2]/code").text).to eq("HTML code element")
	# end

	# it "should not convert block HTML passthroughs" do
	# 	html = Nokogiri::HTML(convert_passthrough_tests)
	# 	expect(html.xpath("//section[@data-type='sect1'][4]/p[2]").text).to eq("Some text in an HTML p element.")
	# 	expect(html.xpath("//section[@data-type='sect1'][4]/figure/figcaption").text).to eq("HTML Figure Markup")
	# 	expect(html.xpath("//section[@data-type='sect1'][4]/figure/img/@src").text).to eq("images/html.png")
	# 	html.xpath("//section[@data-type='sect1'][4]/blockquote/p").text.should start_with "So she was considering in her own mind"
	# end

	# it "should ignore processing instruction passthroughs" do
	# 	html = Nokogiri::HTML(convert_passthrough_tests)
	# 	expect(html.xpath("//section[@data-type='sect1'][5]/p[1]").text).to eq("Processing instruction in inline passthroughs should be ignored entirely.")
	# 	expect(html.xpath("//section[@data-type='sect1'][5]/p[2]/span").text).to eq("should be subbed out.")
	# 	html.xpath("//section[@data-type='sect1'][5]").text.should_not include '<?hard-pagebreak?>'
	# 	expect(html.xpath("//section[@data-type='sect1'][5]/p[5]").text).to eq("text before  text after")
	# end

end
