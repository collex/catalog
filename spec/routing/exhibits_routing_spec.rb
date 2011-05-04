require "spec_helper"

describe ExhibitsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/exhibits" }.should route_to(:controller => "exhibits", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/exhibits/new" }.should route_to(:controller => "exhibits", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/exhibits/1" }.should route_to(:controller => "exhibits", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/exhibits/1/edit" }.should route_to(:controller => "exhibits", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/exhibits" }.should route_to(:controller => "exhibits", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/exhibits/1" }.should route_to(:controller => "exhibits", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/exhibits/1" }.should route_to(:controller => "exhibits", :action => "destroy", :id => "1")
    end

  end
end
