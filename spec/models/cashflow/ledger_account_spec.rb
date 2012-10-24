require 'spec_helper'

describe Cashflow::LedgerAccount do

  let(:bank_account)  { Cashflow::BankAccount.create!}

  describe :relationships do
    it { should have_many :ledger_entries }
    it { should belong_to :accountable }
  end

  describe "Validation" do
    it { should validate_presence_of :accountable }
  end

  before :each do
    @ledger_account = bank_account.ledger_account
  end

  subject { @ledger_account }

  describe :klass do
    it { should respond_to(:name) }
  end

  describe :new_ledger_account do 
    its(:balance) { should == 0 }
  end

  describe :debits do

    it "will create a single transaction" do
      expect { @ledger_account.debit 100 , Date.tomorrow}.to change { Cashflow::LedgerEntry.count }.by(1)
    end

    it "will total up all debits" do
      @ledger_account.debit 100.01, Date.today
      @ledger_account.debit 200.03, Date.today

      @ledger_account.balance.should == 300.04
    end

    it "should be possible to specify a date for a depoist" do
      @ledger_account.debit 100.02, Date.tomorrow
    end
  end
  describe :withdrals do

    it "will create a single transaction" do
      expect { @ledger_account.credit 100, Date.today }.to change { Cashflow::LedgerEntry.count }.by(1)
    end

    it "will total up all creditls" do
      @ledger_account.credit 100.01, Date.today
      @ledger_account.credit 300.03, Date.today
      @ledger_account.balance.should == -400.04

    end

    it "should be possible to specify a date for a creditl" do
      @ledger_account.credit 100.02, Date.tomorrow
    end
  end

  describe :ledger_entries_for_specific_dates do

    it "should find ledger_entries created on a specific date" do
      @ledger_account.credit 100.02, Date.today
      @ledger_account.credit 234.00, Date.tomorrow
      @ledger_account.debit 100.02, Date.today
      @ledger_account.debit 234.00, Date.tomorrow

      ledger_entries = @ledger_account.ledger_entries.find_all_by_date(Date.today)
      ledger_entries.size.should == 2  
      ledger_entries.each { |tran| tran.date.should == Date.today }

    end
  end

  describe :balance do
    it "should be possible to find the balance at the start of any given day" do

      @ledger_account.debit 100.02, Date.today
      @ledger_account.debit 234.00, Date.tomorrow
      @ledger_account.debit 111.02, Date.today+2
      @ledger_account.debit 321.00, Date.today+3

      @ledger_account.balance(Date.today).should == 0
      @ledger_account.balance(Date.tomorrow).should == 100.02
      @ledger_account.balance(Date.today+2).should == (100.02+234.00)
      @ledger_account.balance(Date.today+3).should == (100.02+234.00+111.02)
      @ledger_account.balance(Date.today+4).should == (100.02+234.00+111.02+321.00)

    end

    it "should return a list of daily balances for a given date range" do

      @ledger_account.debit 100.02, Date.today
      @ledger_account.debit 234.00, Date.tomorrow
      @ledger_account.debit 111.02, Date.today+2
      @ledger_account.debit 321.00, Date.today+3

      balances = @ledger_account.daily_balances Date.today, Date.today+4

      balances.size.should == 5

      balances.inject(Date.today) do |date,balance|
        balance[:date].should == date
        balance[:balance].should ==  @ledger_account.balance(date)
        date+=1
      end
    end
  end

  describe :get_daily_balance_transaction_totals do
    it "should list the daily transaction totals (activity) for a given date" do

      @ledger_account.debit 100.02, Date.today
      @ledger_account.credit 234.00, Date.tomorrow

      @ledger_account.debit 100.02, Date.today+2
      @ledger_account.credit 234.00, Date.today+2

      @ledger_account.activity(Date.today).should == 100.02
      @ledger_account.activity(Date.tomorrow).should == -234.00
      @ledger_account.activity(Date.today+2).should == -133.98

    end
  end
end
