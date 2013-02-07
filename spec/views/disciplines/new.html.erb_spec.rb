require 'spec_helper'

describe "disciplines/new.html.erb" do
  before(:each) do
    assign(:discipline, stub_model(Discipline,
      :name => "MyString"
    ).as_new_record)
  end

  it "renders new discipline form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => disciplines_path, :method => "post" do
      assert_select "input#discipline_name", :name => "discipline[name]"
    end
  end
end
