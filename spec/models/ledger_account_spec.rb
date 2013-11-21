require 'spec_helper'

describe LedgerAccount do


  describe :relationships do
    it { should have_many :ledger_entries }
    it { should have_many :balance_corrections }
    it { should have_many :statement_imports }
    it { should belong_to :user}
  end


  before :each do
    @user = User.find_by_email('test_user@cashflowprojector.com')
    @ledger_account = @user.ledger_accounts.create!( :name => 'test' )
  end

  subject { @ledger_account }

  describe :klass do
    it { should respond_to(:name) }
  end

  describe :new_ledger_account do 
    its(:balance) { should == 0 }
  end

  describe :control_account do
    it 'should be psooible to find control account by name' do
      control_account = @user.ledger_accounts.create!( :name => 'blah blah blah', :control_name => 'special_purpose' )
      @user.ledger_accounts.control_account('special_purpose').should == control_account
    end

    it 'cannot delete them' do
      control_account = @user.ledger_accounts.create!( :name => 'blah blah blah', :control_name => 'special_purpose' )
      expect { control_account.destroy }.to change {@user.ledger_accounts.count}.by(0)
    end

    it 'cannot have its control name changed/cleared' do
      control_account = @user.ledger_accounts.create!( :name => 'blah blah blah', :control_name => 'special_purpose' )
      control_account.control_name = nil
      control_account.valid?
      control_account.errors[:base].should include 'cannot change control name'
    end
  end

  describe :debits do

    it "will create a single transaction" do
      expect do
        @ledger_account.debit(100 , Date.tomorrow)
      end.to change { LedgerEntry.count }.by(1)
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
  describe :credit do

    it "will create a single transaction" do
      expect do
        @ledger_account.credit(100 , Date.tomorrow)
      end.to change { LedgerEntry.count }.by(1)
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

  describe :increase do
    it 'should increase the account balance' do
      expect do
        @ledger_account.increase 100.00, Date.today
      end.to change{@ledger_account.balance}.by(100.00)
    end
  end

  describe :decrease do
    it 'should decrease the account balance' do
      expect do
        @ledger_account.decrease 100.00, Date.today
      end.to change{@ledger_account.balance}.by(-100.00)
    end
  end


  describe :ledger_entries_for_specific_dates do

    it "should find ledger_entries created on a specific date" do
      @ledger_account.credit 100.02, Date.today
      @ledger_account.credit 234.00, Date.tomorrow
      @ledger_account.debit 100.02, Date.today
      @ledger_account.debit 234.00, Date.tomorrow

      ledger_entries = @ledger_account.ledger_entries.where(:date => Date.today)
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
        balance[:activity].should ==  @ledger_account.activity(date)
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
