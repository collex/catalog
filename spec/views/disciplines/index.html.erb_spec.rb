require 'spec_helper'

describe "disciplines/index.html.erb" do
  before(:each) do
    assign(:disciplines, [
      stub_model(Discipline,
        :name => "Name"
      ),
      stub_model(Discipline,
        :name => "Name"
      )
    ])
  end

  it "renders a list of disciplines" do
    render
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
