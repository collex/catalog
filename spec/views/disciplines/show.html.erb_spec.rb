require 'spec_helper'

describe "disciplines/show.html.erb" do
  before(:each) do
    @discipline = assign(:discipline, stub_model(Discipline,
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(/Name/)
  end
end
