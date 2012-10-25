require 'spec_helper'

describe Cashflow::BankAccount do
  describe :relationships do
    it { should belong_to :ledger_account}
    it { should belong_to :user}
  end

  before :each do
    user = User.create!(:email => 'r@rob.com', :password => '##12##34')
    @bank_account = user.bank_accounts.create!( :name => 'test' )
  end

  subject { @bank_account }

  describe :klass do
    it { should respond_to(:name) }
  end

  describe :new_bank_account do 
    its(:balance) { should == 0 }
    its(:ledger_account) { should_not == nil }
  end

  describe :deposits do


    it "will total up all deposits" do
      @bank_account.deposit 100.01, Date.today
      @bank_account.deposit 200.03, Date.today

      @bank_account.balance.should == 300.04
    end

    it "should be possible to specify a date for a depoist" do
      @bank_account.deposit 100.02, Date.tomorrow
    end
  end
  describe :withdrals do

    it "will total up all withdrawls" do
      @bank_account.withdraw 100.01, Date.today
      @bank_account.withdraw 300.03, Date.today
      @bank_account.balance.should == -400.04

    end

    it "should be possible to specify a date for a withdrawl" do
      @bank_account.withdraw 100.02, Date.tomorrow
    end
  end


  describe :balance do
    it "should be possible to find the balance at the start of any given day" do

      @bank_account.deposit 100.02, Date.today
      @bank_account.deposit 234.00, Date.tomorrow
      @bank_account.deposit 111.02, Date.today+2
      @bank_account.deposit 321.00, Date.today+3

      @bank_account.balance(Date.today).should == 0
      @bank_account.balance(Date.tomorrow).should == 100.02
      @bank_account.balance(Date.today+2).should == (100.02+234.00)
      @bank_account.balance(Date.today+3).should == (100.02+234.00+111.02)
      @bank_account.balance(Date.today+4).should == (100.02+234.00+111.02+321.00)

    end

    it "should return a list of daily balances for a given date range" do

      @bank_account.deposit 100.02, Date.today
      @bank_account.deposit 234.00, Date.tomorrow
      @bank_account.deposit 111.02, Date.today+2
      @bank_account.deposit 321.00, Date.today+3

      balances = @bank_account.daily_balances Date.today, Date.today+4

      balances.size.should == 5

      balances.inject(Date.today) do |date,balance|
        balance[:date].should == date
        balance[:balance].should ==  @bank_account.balance(date)
        date+=1
      end
    end
  end

  describe :get_daily_balance_transaction_totals do
    it "should list the daily transaction totals (activity) for a given date" do

      @bank_account.deposit 100.02, Date.today
      @bank_account.withdraw 234.00, Date.tomorrow

      @bank_account.deposit 100.02, Date.today+2
      @bank_account.withdraw 234.00, Date.today+2

      @bank_account.activity(Date.today).should == 100.02
      @bank_account.activity(Date.tomorrow).should == -234.00
      @bank_account.activity(Date.today+2).should == -133.98

    end
  end
end
