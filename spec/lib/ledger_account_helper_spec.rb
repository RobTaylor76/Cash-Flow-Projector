require 'spec_helper'

describe LedgerAccountHelper do

  before :each do
    @user = User.find_by_email('test_user@cashflowprojector.com')
    @ledger_account = @user.ledger_accounts.create!( :name => 'test' )
  end

  it "should return a list of daily balances for a given date range" do

    @ledger_account.debit 100.02, Date.today
    @ledger_account.debit 234.00, Date.tomorrow
    @ledger_account.debit 111.02, Date.today+2
    @ledger_account.debit 321.00, Date.today+3

    balances = LedgerAccountHelper.daily_balances(@ledger_account, Date.today, Date.today+4)

    balances.size.should == 5

    balances.inject(Date.today) do |date,balance|
      balance[:date].should == date
      balance[:activity].should ==  @ledger_account.activity(date)
      balance[:balance].should ==  @ledger_account.balance(date)
      date+=1
    end
  end

  it 'should summarize the activity by analysis code' do

  end
end
