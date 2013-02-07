require 'spec_helper'

describe "disciplines/edit.html.erb" do
  before(:each) do
    @discipline = assign(:discipline, stub_model(Discipline,
      :new_record? => false,
      :name => "MyString"
    ))
  end

  it "renders the edit discipline form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => discipline_path(@discipline), :method => "post" do
      assert_select "input#discipline_name", :name => "discipline[name]"
    end
  end
end
