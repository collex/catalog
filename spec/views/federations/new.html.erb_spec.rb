require 'spec_helper'

describe "federations/new.html.erb" do
  before(:each) do
    assign(:federation, stub_model(Federation,
      :name => "MyString"
    ).as_new_record)
  end

  it "renders new federation form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => federations_path, :method => "post" do
      assert_select "input#federation_name", :name => "federation[name]"
    end
  end
end
