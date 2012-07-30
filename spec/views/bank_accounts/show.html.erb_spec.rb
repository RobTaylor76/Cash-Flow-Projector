require 'spec_helper'

describe "bank_accounts/show" do
  before(:each) do
    @bank_account = assign(:bank_account, stub_model(BankAccount))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
