require 'nokogiri'
require 'rspec/expectations'

RSpec::Matchers.define :have_html do |xpath|

  attr_reader :text, :count

  match do |actual|
    actual = Nokogiri::HTML(actual) unless actual.respond_to?(:xpath)
    @match = actual.xpath(xpath)

    expect(@match).to_not be_empty

    if text.is_a?(Proc)
      text.call(@match.text)
    elsif text
      expect(@match.text).to eq @text
    end

    expect(@match.length).to eq @count if @count

    true
  end

  chain :with_text do |*args, &block|
    @text = args[0] || block
  end

  chain :with_count do |count|
    @count = count
  end

  description do
    %{have xpath "#{xpath}"}
  end

  failure_message do |actual|
    desc  = %{Expected to find xpath "#{xpath}"}
    desc << %{ with text "#{text}"} if text
    desc << %{ #{count} times} if count
    desc << %{ but there were no matches.}

    unless @match.empty?
      desc << "\nAlso found #{matched_texts_str}"
      desc << ", which matched the selector but not all filters."
    end

    desc
  end

  failure_message_when_negated do |actual|
    desc  = %{Expected to not find xpath "#{xpath}"}
    desc << %{ with text "#{text}"} if text
    desc << %{, but found #{@match.count} match: #{matched_texts_str}}
    desc
  end

  # RSpec 2.x compatibility
  alias_method :failure_message_for_should, :failure_message
  alias_method :failure_message_for_should_not, :failure_message_when_negated

  private
  def matched_texts_str
    @match.map(&:text).map(&:inspect).join(', ')
  end
end
