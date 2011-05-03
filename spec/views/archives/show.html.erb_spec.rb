require 'spec_helper'

describe "archives/show.html.erb" do
  before(:each) do
    @archive = assign(:archive, stub_model(Archive,
      :name => "Name",
      :site_url => "Site Url",
      :thumbnail => "Thumbnail",
      :carousel_description => "MyText",
      :carousel_image_url => "Carousel Image Url"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Site Url/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Thumbnail/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Carousel Image Url/)
  end
end
