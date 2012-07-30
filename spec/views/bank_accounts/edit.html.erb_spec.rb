require 'spec_helper'

describe "bank_accounts/edit" do
  before(:each) do
    @bank_account = assign(:bank_account, stub_model(BankAccount))
  end

  it "renders the edit bank_account form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => bank_accounts_path(@bank_account), :method => "post" do
    end
  end
end
