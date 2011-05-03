require "spec_helper"

describe ArchivesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/archives" }.should route_to(:controller => "archives", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/archives/new" }.should route_to(:controller => "archives", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/archives/1" }.should route_to(:controller => "archives", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/archives/1/edit" }.should route_to(:controller => "archives", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/archives" }.should route_to(:controller => "archives", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/archives/1" }.should route_to(:controller => "archives", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/archives/1" }.should route_to(:controller => "archives", :action => "destroy", :id => "1")
    end

  end
end
