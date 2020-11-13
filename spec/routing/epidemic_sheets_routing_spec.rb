require "rails_helper"

RSpec.describe EpidemicSheetsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/epidemic_sheets").to route_to("epidemic_sheets#index")
    end

    it "routes to #new" do
      expect(:get => "/epidemic_sheets/new").to route_to("epidemic_sheets#new")
    end

    it "routes to #show" do
      expect(:get => "/epidemic_sheets/1").to route_to("epidemic_sheets#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/epidemic_sheets/1/edit").to route_to("epidemic_sheets#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/epidemic_sheets").to route_to("epidemic_sheets#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/epidemic_sheets/1").to route_to("epidemic_sheets#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/epidemic_sheets/1").to route_to("epidemic_sheets#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/epidemic_sheets/1").to route_to("epidemic_sheets#destroy", :id => "1")
    end
  end
end
