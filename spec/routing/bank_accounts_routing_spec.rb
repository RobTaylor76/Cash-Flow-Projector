require "spec_helper"

describe BankAccountsController do
  describe "routing" do

    it "routes to #index" do
      get("/bank_accounts").should route_to("bank_accounts#index")
    end

    it "routes to #new" do
      get("/bank_accounts/new").should route_to("bank_accounts#new")
    end

    it "routes to #show" do
      get("/bank_accounts/1").should route_to("bank_accounts#show", :id => "1")
    end

    it "routes to #edit" do
      get("/bank_accounts/1/edit").should route_to("bank_accounts#edit", :id => "1")
    end

    it "routes to #create" do
      post("/bank_accounts").should route_to("bank_accounts#create")
    end

    it "routes to #update" do
      put("/bank_accounts/1").should route_to("bank_accounts#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/bank_accounts/1").should route_to("bank_accounts#destroy", :id => "1")
    end

  end
end
