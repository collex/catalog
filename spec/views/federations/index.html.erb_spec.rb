require 'spec_helper'

describe "federations/index.html.erb" do
  before(:each) do
    assign(:federations, [
      stub_model(Federation,
        :name => "Name"
      ),
      stub_model(Federation,
        :name => "Name"
      )
    ])
  end

  it "renders a list of federations" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
