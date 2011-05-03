require 'spec_helper'

describe "archives/index.html.erb" do
  before(:each) do
    assign(:archives, [
      stub_model(Archive,
        :name => "Name",
        :site_url => "Site Url",
        :thumbnail => "Thumbnail",
        :carousel_description => "MyText",
        :carousel_image_url => "Carousel Image Url"
      ),
      stub_model(Archive,
        :name => "Name",
        :site_url => "Site Url",
        :thumbnail => "Thumbnail",
        :carousel_description => "MyText",
        :carousel_image_url => "Carousel Image Url"
      )
    ])
  end

  it "renders a list of archives" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Site Url".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Thumbnail".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Carousel Image Url".to_s, :count => 2
  end
end
