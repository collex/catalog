require 'spec_helper'

describe DisciplinesController do

  def mock_discipline(stubs={})
    (@mock_discipline ||= mock_model(Discipline).as_null_object).tap do |discipline|
      discipline.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all disciplines as @disciplines" do
      Discipline.stub(:all) { [mock_discipline] }
      get :index
      assigns(:disciplines).should eq([mock_discipline])
    end
  end

  describe "GET show" do
    it "assigns the requested discipline as @discipline" do
      Discipline.stub(:find).with("37") { mock_discipline }
      get :show, :id => "37"
      assigns(:discipline).should be(mock_discipline)
    end
  end

  describe "GET new" do
    it "assigns a new discipline as @discipline" do
      Discipline.stub(:new) { mock_discipline }
      get :new
      assigns(:discipline).should be(mock_discipline)
    end
  end

  describe "GET edit" do
    it "assigns the requested discipline as @discipline" do
      Discipline.stub(:find).with("37") { mock_discipline }
      get :edit, :id => "37"
      assigns(:discipline).should be(mock_discipline)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created discipline as @discipline" do
        Discipline.stub(:new).with({'these' => 'params'}) { mock_discipline(:save => true) }
        post :create, :discipline => {'these' => 'params'}
        assigns(:discipline).should be(mock_discipline)
      end

      it "redirects to the created discipline" do
        Discipline.stub(:new) { mock_discipline(:save => true) }
        post :create, :discipline => {}
        response.should redirect_to(discipline_url(mock_discipline))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved discipline as @discipline" do
        Discipline.stub(:new).with({'these' => 'params'}) { mock_discipline(:save => false) }
        post :create, :discipline => {'these' => 'params'}
        assigns(:discipline).should be(mock_discipline)
      end

      it "re-renders the 'new' template" do
        Discipline.stub(:new) { mock_discipline(:save => false) }
        post :create, :discipline => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested discipline" do
        Discipline.should_receive(:find).with("37") { mock_discipline }
        mock_discipline.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :discipline => {'these' => 'params'}
      end

      it "assigns the requested discipline as @discipline" do
        Discipline.stub(:find) { mock_discipline(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:discipline).should be(mock_discipline)
      end

      it "redirects to the discipline" do
        Discipline.stub(:find) { mock_discipline(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(discipline_url(mock_discipline))
      end
    end

    describe "with invalid params" do
      it "assigns the discipline as @discipline" do
        Discipline.stub(:find) { mock_discipline(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:discipline).should be(mock_discipline)
      end

      it "re-renders the 'edit' template" do
        Discipline.stub(:find) { mock_discipline(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested discipline" do
      Discipline.should_receive(:find).with("37") { mock_discipline }
      mock_discipline.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the disciplines list" do
      Discipline.stub(:find) { mock_discipline }
      delete :destroy, :id => "1"
      response.should redirect_to(disciplines_url)
    end
  end

end
