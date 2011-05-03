require "spec_helper"

describe FederationsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/federations" }.should route_to(:controller => "federations", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/federations/new" }.should route_to(:controller => "federations", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/federations/1" }.should route_to(:controller => "federations", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/federations/1/edit" }.should route_to(:controller => "federations", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/federations" }.should route_to(:controller => "federations", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/federations/1" }.should route_to(:controller => "federations", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/federations/1" }.should route_to(:controller => "federations", :action => "destroy", :id => "1")
    end

  end
end
