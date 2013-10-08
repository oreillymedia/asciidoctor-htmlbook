require 'spec_helper.rb'

describe "HTMLBook Templates" do

  it "should convert level 1 headings" do
    html = Nokogiri::HTML(convert("== Heading 1"))
    html.css("section[data-type='chapter'] h1").text.should == "Heading 1"
  end

end