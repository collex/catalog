require "spec_helper"

describe DisciplinesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/disciplines" }.should route_to(:controller => "disciplines", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/disciplines/new" }.should route_to(:controller => "disciplines", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/disciplines/1" }.should route_to(:controller => "disciplines", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/disciplines/1/edit" }.should route_to(:controller => "disciplines", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/disciplines" }.should route_to(:controller => "disciplines", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/disciplines/1" }.should route_to(:controller => "disciplines", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/disciplines/1" }.should route_to(:controller => "disciplines", :action => "destroy", :id => "1")
    end

  end
end
