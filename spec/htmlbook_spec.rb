# encoding: utf-8
require 'spec_helper.rb'

describe "HTMLBook" do

  describe 'section' do

    it 'converts chapter title' do
      html = convert('== Chapter Title')
      expect(html).to have_html("//section[@data-type='chapter']/h1").with_text('Chapter Title')
    end

    ['Dedication', 'Glossary', 'Index'].each do |title|
      it "converts #{title.downcase} title" do
        html = convert("== #{title}")
        expect(html).to have_html("//section[@data-type='#{title.downcase}']/h1").with_text(title)
      end
    end

    ['Preface', 'Foreword'].each do |title|
      it "converts #{title.downcase} title" do
        html = convert <<-eos
          [preface]
          == #{title}
        eos
        expect(html).to have_html("//section[@data-type='#{title.downcase}']/h1").with_text(title)
      end
    end

    it 'converts appendix title' do
      html = convert <<-eos
        [appendix]
        == Appendix
      eos
      expect(html).to have_html("//section[@data-type='appendix']/h1").with_text('Appendix')
    end

    (1..4).each do |lvl|
      it "converts level #{lvl} heading" do
        html = convert("==#{'=' * lvl} Heading #{lvl}")
        expect(html).to have_html("//section[@data-type='sect#{lvl}']/h#{lvl}").with_text("Heading #{lvl}")
      end
    end
  end

  describe 'block_admonition' do
    ['note', 'tip', 'warning', 'caution'].each do |type|
      it "converts #{type}" do
        html = convert <<-eos
          [#{type.upcase}]
          ====
          Here is some text inside a #{type}.
          ====
        eos
        expect(html).to have_html("//div[@data-type='#{type}']/p").with_text("Here is some text inside a #{type}.")
      end
    end
  end

  # PENDING: Tests block_colist template
  it 'block_colist'

  describe 'block_dlist' do
    subject { convert('First term:: This is a definition of the first term.') }

    it { should have_html('//dl/dt').with_text('First term') }
    it { should have_html('//dl/dd/p').with_text('This is a definition of the first term.') }
  end

  # formal examples
  describe 'block_example' do
    subject do
      convert <<-eos
        [[Example1]]
        .A code block with a title
        ====
        [source, ruby]
        ----
        Hello world
        ----
        ====
      eos
    end

    { '@id' => 'Example1',
      'h5' => 'A code block with a title',
      "pre[@data-type='programlisting']/@data-code-language" => 'ruby',
      "pre[@data-type='programlisting']" => 'Hello world'
    }.each do |xpath, text|
      it { should have_html("//div[@data-type='example']/#{xpath}").with_text(text) }
    end
  end

  describe 'block_image' do

    describe 'formal figure' do
      subject do
        convert <<-eos
          [[unique_id1]]
          .A Figure
          image::images/tiger.png[]
        eos
      end

      { '@id' => 'unique_id1',
        'figcaption' => 'A Figure',
        'img/@src' => 'images/tiger.png',
        'img/@alt' => 'tiger'
      }.each do |xpath, text|
        it { should have_html("//figure/#{xpath}").with_text(text) }
      end
    end

    describe 'informal figure' do

      describe 'with an alternate text' do
        subject { convert 'image::images/duck.png[]' }

        it { should have_html('//figure/figcaption') }
        it { should have_html('//figure/img/@src').with_text('images/duck.png') }
        it { should_not have_html('//figure/@id') }
      end

      describe 'without an alternate text' do
        subject { convert "image::images/lion.png['An image of a lion head']" }

        it { should have_html('//figure/img/@alt').with_text('An image of a lion head') }
      end
    end
  end

  describe 'block_listing' do

    describe 'informal code block' do
      subject do
        convert <<-eos
          [source, ruby]
          ----
          Hello world
          ----
        eos
      end
      let(:xpath) { "//pre[@data-type='programlisting']" }

      it { should have_html("#{xpath}/@data-code-language").with_text('ruby') }
      it { should have_html("#{xpath}").with_text('Hello world') }
    end
  end

  describe 'block_literal' do

    it 'converts a first markup style' do
      html = convert %(
        [literal]
        This is a literal block.
      )
      expect(html).to have_html('//pre').with_text('This is a literal block.')
    end

    it 'converts a second markup style' do
      html = convert(' This is also a literal block.')
      expect(html).to have_html('//pre').with_text('This is also a literal block.')
    end
  end

  describe 'block_math' do
    subject do
      convert %q(
        [latexmath]
        .Equation title
        ++++
        \begin{equation}
        {x = \frac{{ - b \pm \sqrt {b^2 - 4ac} }}{{2a}}}
        \end{equation}
        ++++
      )
    end

    let(:tex) do
      unindent %q(
        \begin{equation}
        {x = \frac{{ - b \pm \sqrt {b^2 - 4ac} }}{{2a}}}
        \end{equation}
        )
    end

    let(:xpath) { "//div[@data-type='equation']" }

    it { should have_html("#{xpath}/h5").with_text('Equation title') }
    it { should have_html("#{xpath}/p[@data-type='tex']").with_text(tex) }
  end

  describe 'block_olist' do
    subject do
      convert <<-eos
        . Preparation
        . Assembly
        . Measure
        +
        Combine
        +
        Bake
        +
        . Applause
      eos
    end

    { 'li[1]/p[1]' => 'Preparation',
      'li[2]/p[1]' => 'Assembly',
      'li[3]/p[1]' => 'Measure',
      'li[3]/p[2]' => 'Combine',
      'li[3]/p[3]' => 'Bake',
      'li[4]/p[1]' => 'Applause'
    }.each do |xpath, text|
      it { should have_html("//ol/#{xpath}").with_text(text) }
    end
  end

  describe 'block_paragraph' do

    it 'converts regular paragraphs' do
      html = convert('Here is a basic paragraph.')
      expect(html).to have_html('//p').with_text('Here is a basic paragraph.')
    end

    it 'converts paragraphs with role attributes' do
      html = convert <<-eos
        [role='right']
        Here is a basic paragraph.
      eos
      expect(html).to have_html("//p[@class='right']").with_text('Here is a basic paragraph.')
    end
  end

  describe 'block_quote' do
    subject do
      convert <<-eos
        [quote, Wilfred Meynell]
        ____
        Many thanks; I shall lose no time in reading it.

        This is a second paragraph in the quotation.
        ____
      eos
    end

    { 'p[1]' => 'Many thanks; I shall lose no time in reading it.',
      'p[2]' => 'This is a second paragraph in the quotation.',
      "p[@data-type='attribution']" => '— Wilfred Meynell'
    }.each do |xpath, text|
      it { should have_html("//blockquote[@data-type='epigraph']/#{xpath}").with_text(text) }
    end
  end

  describe 'block_sidebar' do
    subject do
      convert <<-eos
        .Sidebar Title
        ****
        Sidebar text is surrounded by four asterisks.
        ****
      eos
    end
    let(:xpath) { "//aside[@data-type='sidebar']" }

    it { should have_html("#{xpath}/h5").with_text('Sidebar Title') }
    it { should have_html("#{xpath}/p").with_text('Sidebar text is surrounded by four asterisks.') }
  end

  describe 'block_table' do

    describe 'formal table (with title and header)' do
      subject do
        convert <<-eos
          .Table Title
          [options='header']
          |=======
          |header1|header2
          |row1|P^Q^
          |row2|col2
          |=======
        eos
      end

      { 'caption' => 'Table Title',
        'thead/tr/th[1]' => 'header1',
        'thead/tr/th[2]' => 'header2',
        'tbody/tr[1]/td[1]/p' => 'row1',
        'tbody/tr[1]/td[2]/p/text()' => 'P',
        'tbody/tr[1]/td[2]/p/sup' => 'Q',
        'tbody/tr[2]/td[1]/p' => 'row2',
        'tbody/tr[2]/td[2]/p' => 'col2'
      }.each do |xpath, text|
        it { should have_html("//table/#{xpath}").with_text(text) }
      end
    end

    describe 'informal table (no title or header)' do
      subject do
        convert <<-eos
          |=======
          |row1|P^Q^
          |row2|col2
          |=======
        eos
      end

      { 'tr[1]/td[1]/p' => 'row1',
        'tr[1]/td[2]/p/text()' => 'P',
        'tr[1]/td[2]/p/sup' => 'Q',
        'tr[2]/td[1]/p' => 'row2',
        'tr[2]/td[2]/p' => 'col2'
      }.each do |xpath, text|
        it { should have_html("//table/tbody/#{xpath}").with_text(text) }
      end
    end
  end

  describe 'block_ulist' do

    describe 'converts itemized lists' do
      subject do
        convert <<-eos
          * lions
          * tigers
          +
          sabre-toothed
          +
          teapotted
          +
          * lions, tigers, and bears
        eos
      end

      { 'li[1]/p[1]' => 'lions',
        'li[2]/p[1]' => 'tigers',
        'li[2]/p[2]' => 'sabre-toothed',
        'li[2]/p[3]' => 'teapotted',
        'li[3]/p[1]' => 'lions, tigers, and bears'
      }.each do |xpath, text|
        it { should have_html("//ul/#{xpath}").with_text(text) }
      end
    end
  end

  describe 'block_verse' do
    subject do
      convert <<-eos
        [verse, William Blake, Songs of Experience]
        Tiger, tiger, burning bright
        In the forests of the night
      eos
    end
    let(:xpath) { "//blockquote[@data-type='epigraph']" }

    it { should have_html("#{xpath}/pre").with_text("Tiger, tiger, burning bright\nIn the forests of the night") }
    it { should have_html("#{xpath}/p[@data-type='attribution']").with_text("— William Blake, Songs of Experience") }
  end

  describe 'block_video' do

    describe 'first markup style' do
      subject do
        convert <<-eos
          video::gizmo.ogv[width=200]
        eos
      end

      it { should have_html("//video[@width='200']/source/@src").with_text('gizmo.ogv') }
      it { should have_html('//video').with_text("\n\nSorry, the <video> element is not supported in your reading system.\n") }
    end
  end

  describe 'inline_anchor' do

    describe 'reference to inline anchor' do
      subject do
        convert <<-eos
          This is a reference to an <<inlineanchor>>.

          See <<inlineanchor, Awesome Chapter>>
        eos
      end

      { '//p[1]/a/@href' => '#inlineanchor',
        '//p[1]/a' => '',
        '//p[2]/a/@href' => '#inlineanchor',
        '//p[2]/a' => 'Awesome Chapter'
      }.each do |xpath, text|
        it { should have_html(xpath).with_text(text) }
      end
    end

    describe 'link' do
      subject do
        convert <<-eos
          This is a link without a text node: http://www.oreilly.com

          This is a link with a text node: http://www.oreilly.com[check out this text node]
        eos
      end

      { '//p[1]/a/@href' => 'http://www.oreilly.com',
        "//p[1]/a/em[@class='hyperlink']" => 'http://www.oreilly.com',
        '//p[2]/a/@href' => 'http://www.oreilly.com',
        '//p[2]/a[not(*)]' => 'check out this text node',
      }.each do |xpath, text|
        it { should have_html(xpath).with_text(text) }
      end
    end
  end

  describe 'inline_callout' do
    subject do
      convert <<-eos
        ----
        Roses are red, <1>
           Violets are blue. <2>
        ----
        <1> This is a fact.
        <2> This poem uses the literary device known as a surprise ending.
      eos
    end

    { "//pre[@data-type='programlisting']/text()" => 'Roses are red,\n   Violets are blue. ',
      "//pre[@data-type='programlisting']/b[1]" => '(1)',
      "//pre[@data-type='programlisting']/b[2]" => '(2)',
      "//ol[@class='calloutlist']/li[1]/p" => '➊ This is a fact.',
      "//ol[@class='calloutlist']/li[2]/p" => '➋ This poem uses the literary device known as a surprise ending.'
    }.each do |xpath, text|
      it { should have_html(xpath).with_text(text) }
    end
  end

  describe 'inline_footnote' do
    subject do
      convert <<-eos
        A footnote.footnote:[An example footnote.]

        A second footnote with a reference ID.footnoteref:[note2,Second footnote.]

        Finally a reference to the second footnote.footnoteref:[note2]
      eos
    end

    { "//p[1]/span[@data-type='footnote']" => 'An example footnote.',
      "//p[2]/span[@data-type='footnote']" => 'Second footnote.',
      "//p[2]/span[@data-type='footnote']/@id" => 'note2',
      "//p[3]/a[@data-type='footnoteref']/@href" => 'note2'
    }.each do |xpath, text|
      it { should have_html(xpath).with_text(text) }
    end

    it { should_not have_html("//p[1]/span[@data-type='footnote']/@id") }
    it { should_not have_html("//p[3]/a[@data-type='footnoteref']/text()") }
  end

  describe 'inline_image' do
    subject { convert('Here is an inline figure: image:images/logo.png[]') }

    it { should have_html('//p/img/@src').with_text('images/logo.png') }
  end

  describe 'inline_quoted' do

    describe 'inline formatting' do
      subject { convert('This para has __emphasis__, *bold**, ++literal++, ^superscript^, ~subscript~, __++replaceable++__, and *+userinput+*.') }

      { '//p/em[1]' => 'emphasis',
        '//p/strong[1]' => 'bold',
        '//p/code[1]' => 'literal',
        '//p/sup' => 'superscript',
        '//p/sub' => 'subscript',
        '//p/em/code' => 'replaceable',
        '//p/strong/code' => 'userinput'
      }.each do |xpath, text|
        it { should have_html(xpath).with_text(text) }
      end
    end

    describe 'math' do
      subject { convert('The Pythagorean Theorem is latexmath:[$a^2 + b^2 = c^2$]') }
      it { should have_html("//p/span[@data-type='tex']").with_text('$a^2 + b^2 = c^2$') }
    end
  end


  # source markup is in files/indexterm_testing.asciidoc
  # XXX Is it really useful to test all these cases?
  describe 'inline_indexterm.asciidoc' do

    subject { convert_indexterm_tests }

    describe 'with one term' do
      let(:xpath_prefix) { "//section[@data-type='sect1'][1]/section[@data-type='sect2'][1]" }

      describe 'primary only, with quation marks' do
        { 'p[1]/a/@data-type' => 'indexterm',
          'p[1]/a/@data-primary' => 'metaclass'
        }.each do |xpath, text|
          it { should have_html("#{xpath_prefix}[1]/#{xpath}").with_text(text) }
        end
      end

      describe 'primary only, without quotation marks' do
        { 'p[2]/a/@data-type' => 'indexterm',
          'p[2]/a/@data-primary' => 'accessibility'
        }.each do |xpath, text|
          it { should have_html("#{xpath_prefix}/#{xpath}").with_text(text) }
        end
      end
    end

    describe 'with two terms' do
      let(:xpath_prefix) { "//section[@data-type='sect1'][2]/section[@data-type='sect2']" }

      describe 'primary only' do
        { 'p[1]/a/@data-see' => 'aspect-oriented',
          'p[2]/a/@data-seealso' => 'namespace',
          'p[3]/a/@data-primary-sortas' => 'patterns',
          'p[4]/a/@id' => 'dynamic',
          'p[5]/a/@data-startref' => 'dynamic'
        }.each do |xpath, text|
          it { should have_html("#{xpath_prefix}[1]/#{xpath}").with_text(text) }
        end
      end

      describe 'secondary' do
        it { should have_html("#{xpath_prefix}[2]/p[1]/a/@data-secondary").with_text('eigenclass') }
      end
    end

    describe 'with three terms' do
      let(:xpath_prefix) { "//section[@data-type='sect1'][3]/section[@data-type='sect2']" }

      describe 'primary only' do
        { 'p[1]/a/@id' => 'orthogonality',
          'p[2]/a/@data-see' => 'destructor',
          'p[2]/a/@data-seealso' => 'factory method'
        }.each do |xpath, text|
          it { should have_html("#{xpath_prefix}[1]/#{xpath}").with_text(text) }
        end
      end

      describe 'secondary' do
        { 'p[1]/a/@data-secondary' => 'immutable',
          'p[1]/a/@data-see' => 'instance method',
          'p[2]/a/@data-seealso' => 'partial class',
          'p[3]/a/@data-secondary-sortas' => 'iterator'
        }.each do |xpath, text|
          it { should have_html("#{xpath_prefix}[2]/#{xpath}").with_text(text) }
        end
      end

      describe 'tertiary, with quotation marks' do
        { 'p[1]/a/@data-secondary' => 'virtual class',
          'p[1]/a/@data-tertiary' => 'subtype'
        }.each do |xpath, text|
          it { should have_html("#{xpath_prefix}[3]/#{xpath}").with_text(text) }
        end
      end

      describe 'tertiary, without quotation marks' do
        { 'p[2]/a/@data-secondary' => 'test-driven development',
          'p[2]/a/@data-tertiary' => 'weak reference'
        }.each do |xpath, text|
          it { should have_html("#{xpath_prefix}[3]/#{xpath}").with_text(text) }
        end
      end
    end

    describe 'with four terms' do
      let(:xpath_prefix) { "//section[@data-type='sect1'][4]/section[@data-type='sect2']" }

      describe 'primary only' do
        { 'p[1]/a/@id' => 'slicing',
          'p[1]/a/@data-see' => 'access control',
          'p[2]/a/@data-seealso' => 'hybrid',
          'p[3]/a/@data-primary-sortas' => 'uninitialized',
          'p[4]/a/@data-see' => 'mutator method',
          'p[4]/a/@data-seealso' => 'policy-based design'
        }.each do |xpath, text|
          it { should have_html("#{xpath_prefix}[1]/#{xpath}").with_text(text) }
        end
      end

      describe 'secondary' do
        { 'p[1]/a/@data-secondary' => 'viscosity',
          'p[1]/a/@id' => 'encapsulation',
          'p[2]/a/@data-secondary' => 'superclass',
          'p[2]/a/@data-see' => 'typecasting',
          'p[2]/a/@data-seealso' => 'virtual inheritance'
        }.each do |xpath, text|
          it { should have_html("#{xpath_prefix}[2]/#{xpath}").with_text(text) }
        end
      end

      describe 'tertiary' do
        { 'p[1]/a/@data-secondary' => 'shadowed name',
          'p[1]/a/@data-tertiary' => 'function',
          'p[1]/a/@data-see' => 'late binding',
          'p[2]/a/@data-secondary' => 'array',
          'p[2]/a/@data-tertiary' => 'compiler',
          'p[2]/a/@data-seealso' => 'subroutine',
          'p[3]/a/@data-secondary' => 'stack',
          'p[3]/a/@data-tertiary' => 'paradigm',
          'p[3]/a/@data-tertiary-sortas' => 'enumerable'
        }.each do |xpath, text|
          it { should have_html("#{xpath_prefix}[3]/#{xpath}").with_text(text) }
        end
      end
    end

    describe 'with five terms' do
      let(:xpath_prefix) { "//section[@data-type='sect1'][5]/section[@data-type='sect2']" }

      describe 'primary only' do
        { 'p[1]/a/@id' => 'mapping',
          'p[1]/a/@data-see' => 'overload',
          'p[1]/a/@data-seealso' => 'parse'
        }.each do |xpath, text|
          it { should have_html("#{xpath_prefix}[1]/#{xpath}").with_text(text) }
        end
      end

      describe 'secondary' do
        { 'p[1]/a/@data-secondary' => 'token',
          'p[1]/a/@id' => 'syntax',
          'p[1]/a/@data-see' => 'binary',
          'p[2]/a/@data-secondary' => 'conditional',
          'p[2]/a/@id' => 'collection',
          'p[2]/a/@data-seealso' => 'alias',
          'p[3]/a/@data-secondary' => 'operation',
          'p[3]/a/@id' => 'semantics',
          'p[3]/a/@data-secondary-sortas' => 'parameter',
          'p[4]/a/@data-secondary' => 'abstraction',
          'p[4]/a/@id' => 'constant',
          'p[4]/a/@data-see' => 'arithmetic operator',
          'p[4]/a/@data-seealso' => 'base type'
        }.each do |xpath, text|
          it { should have_html("#{xpath_prefix}[2]/#{xpath}").with_text(text) }
        end
      end

      describe 'tertiary' do
        { 'p[1]/a/@data-secondary' => 'deprecated',
          'p[1]/a/@data-tertiary' => 'finalization',
          'p[1]/a/@id' => 'little-endian',
          'p[2]/a/@data-secondary' => 'parallel',
          'p[2]/a/@data-tertiary' => 'scheme',
          'p[2]/a/@data-see' => 'ternary',
          'p[2]/a/@data-seealso' => 'exception'
        }.each do |xpath, text|
          it { should have_html("#{xpath_prefix}[3]/#{xpath}").with_text(text) }
        end
      end
    end

    describe 'with six terms' do
      let(:xpath_prefix) { "//section[@data-type='sect1'][6]/section[@data-type='sect2']" }

      describe 'secondary' do
        { 'p[1]/a/@data-secondary' => 'while loop',
          'p[1]/a/@id' => 'retro',
          'p[1]/a/@data-see' => 'top-level class',
          'p[1]/a/@data-seealso' => 'unary'
        }.each do |xpath, text|
          it { should have_html("#{xpath_prefix}[1]/#{xpath}").with_text(text) }
        end
      end

      describe 'tertiary' do
        { 'p[1]/a/@data-secondary' => 'precedence',
          'p[1]/a/@data-tertiary' => 'overriding',
          'p[1]/a/@id' => 'lightweight',
          'p[1]/a/@data-see' => 'infinite',
          'p[2]/a/@data-secondary' => 'encapsulation',
          'p[2]/a/@data-tertiary' => 'condition',
          'p[2]/a/@id' => 'aggregation',
          'p[2]/a/@data-seealso' => 'boundary',
          'p[3]/a/@data-secondary' => 'classpath',
          'p[3]/a/@data-tertiary' => 'import',
          'p[3]/a/@id' => 'datagram',
          'p[3]/a/@data-tertiary-sortas' => 'method',
        }.each do |xpath, text|
          it { should have_html("#{xpath_prefix}[2]/#{xpath}").with_text(text) }
        end
      end
    end

    describe 'with seven terms' do

      describe 'tertiary' do
        { '@data-secondary' => 'public',
          '@data-tertiary' => 'relational',
          '@id' => 'cascaded',
          '@data-see' => 'inline',
          '@data-seealso' => 'private'
        }.each do |xpath, text|
          it { should have_html("//section[@data-type='sect1'][7]/p[1]/a/#{xpath}").with_text(text) }
        end
      end
    end
  end

  describe 'passthrough_testing.adoc' do

    subject { convert_passthrough_tests }
    let(:xpath_prefix) { "//section[@data-type='sect1']" }

    describe 'converts inline DocBook passthroughs to HTMLBook' do
      { "p[1]/span[@class='keep-together']" => 'DocBook phrase element',
        "p[2]/code" => 'DocBook code element'
      }.each do |xpath, text|
        it { should have_html("//section[@data-type='sect1'][1]/#{xpath}").with_text(text) }
      end
    end

    describe 'converts block DocBook passthroughs to HTMLBook' do
      { "pre[@data-type='programlisting']/strong/code" => 'first line of code here',
        "figure/figcaption" => 'DocBook Figure Markup',
        "figure/img/@src" => 'images/docbook.png',
        "blockquote/p[@data-type='attribution']" => 'Lewis Carroll',
        "blockquote/p" => 'Alice was beginning to get very tired'
      }.each do |xpath, text|
        it { should have_html("//section[@data-type='sect1'][2]/#{xpath}").with_text(text) }
      end
    end

    describe 'should not convert inline HTML block passthroughs' do
      { 'p[1]/strong' => 'HTML strong element',
        'p[2]/code' => 'HTML code element'
      }.each do |xpath, text|
        it { should have_html("//section[@data-type='sect1'][3]/#{xpath}").with_text(text) }
      end
    end

    describe 'should not convert block HTML passthroughs' do
      { 'p[2]' => 'Some text in an HTML p element.',
        'figure/figcaption' => 'HTML Figure Markup',
        'figure/img/@src' => 'images/html.png'
      }.each do |xpath, text|
        it { should have_html("#{xpath_prefix}/[4]/#{xpath}").with_text(text) }
      end
      it { should have_html("#{xpath_prefix}/[4]/blockquote/p").with_text { |text| text.should start_with("So she was considering") }}
    end

    describe 'ignore processing instruction passthroughs' do
      { 'p[1]' => 'Processing instruction in inline passthroughs should be ignored entirely.',
        'p[2]/span' => 'should be subbed out.',
        'p[5]' => 'text before  text after'
      }.each do |xpath, text|
        it { should have_html("#{xpath_prefix}/[5]/#{xpath}").with_text(text) }
      end

      it { should have_html("#{xpath_prefix}/[5]").with_text { |text| text.should_not include('<?hard-pagebreak?>') } }
    end
  end

end
