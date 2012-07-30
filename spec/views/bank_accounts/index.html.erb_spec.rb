require 'spec_helper'

describe "bank_accounts/index" do
  before(:each) do
    assign(:bank_accounts, [
      stub_model(BankAccount),
      stub_model(BankAccount)
    ])
  end

  it "renders a list of bank_accounts" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
