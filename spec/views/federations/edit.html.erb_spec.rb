require 'spec_helper'

describe "federations/edit.html.erb" do
  before(:each) do
    @federation = assign(:federation, stub_model(Federation,
      :name => "MyString"
    ))
  end

  it "renders the edit federation form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => federations_path(@federation), :method => "post" do
      assert_select "input#federation_name", :name => "federation[name]"
    end
  end
end
