require 'spec_helper'

describe "federations/show.html.erb" do
  before(:each) do
    @federation = assign(:federation, stub_model(Federation,
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
  end
end
