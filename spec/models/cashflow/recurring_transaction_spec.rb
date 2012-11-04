require 'spec_helper'

describe Cashflow::RecurringTransaction do

  it { should have_many :transactions }
  it { should belong_to :user }


  context 'recur a money transfer' do

    before :each do
      user = User.create!(:email => 'r@rob.com', :password => '##12##34')
      @from_ledger_account = user.ledger_accounts.create!( :name => 'from' )
      @to_ledger_account = user.ledger_accounts.create!( :name => 'to' )

      @recurring = described_class.new
      @recurring.user = user
      @recurring.start_date = Date.parse('2012/01/01')
      @recurring.end_date = Date.parse('2012/12/01')
      @recurring.day_of_month = 19
      @recurring.amount = 33
      @recurring.from_ledger_account = @from_ledger_account
      @recurring.to_ledger_account = @to_ledger_account
    end

    it 'should create a transaction for each month' do
      expect { @recurring.create_recurrences}.to change { Cashflow::Transaction.count }.by(12)
    end

    it 'should create a 2 legder entries for each month' do
      expect { @recurring.create_recurrences}.to change { Cashflow::LedgerEntry.count }.by(24)
    end

    context :daily_balances do

      before :each do
        @recurring.create_recurrences
      end

      it 'should have  33 for 1st month in to_account' do
        @to_ledger_account.balance(Date.parse('2012/01/02')).should == 33
      end

      it 'should have  -33 for 1st month in from_account' do
        @from_ledger_account.balance(Date.parse('2012/01/02')).should == -33
      end

      it 'should have 399 in to_account day after last tran' do
        @to_ledger_account.balance(Date.parse('2012/12/02')).should == 396
      end

      it 'should have -399 in to_account day after last tran' do
        @from_ledger_account.balance(Date.parse('2012/12/02')).should == -396
      end
    end

    context :transaction_dates do
      before :each do
        @recurring.create_recurrences
      end
      it 'should create first transaction for the start date' do
        Cashflow::Transaction.for_date(Date.parse('2012/01/01')).count.should == 1
      end
      it 'should create repeating transactions for the correct day of the month' do
        Cashflow::Transaction.for_date(Date.parse('2012/02/01')).count.should == 1
      end
      it 'should create last transactions for the correct day of the month' do
        Cashflow::Transaction.for_date(Date.parse('2012/12/01')).count.should == 1
      end
    end

  end
end

