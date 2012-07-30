require 'spec_helper'

describe "bank_accounts/new" do
  before(:each) do
    assign(:bank_account, stub_model(BankAccount).as_new_record)
  end

  it "renders new bank_account form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => bank_accounts_path, :method => "post" do
    end
  end
end
