require 'spec_helper'

describe Cashflow::RecurringTransaction do

  it { should have_many :transactions }
  it { should belong_to :user }
  it { should belong_to :frequency }


  context 'recur a money transfer' do

    before :each do
      user = User.create!(:email => 'r@rob.com', :password => '##12##34')
      @from_ledger_account = user.ledger_accounts.create!( :name => 'from' )
      @to_ledger_account = user.ledger_accounts.create!( :name => 'to' )

      @start_date = Date.parse('2012/01/01')
      @end_date = @start_date + 11.months

      @recurring = described_class.new
      @recurring.frequency = Cashflow::TransactionFrequency.monthly
      @recurring.user = user
      @recurring.start_date = @start_date
      @recurring.end_date = @end_date
      @recurring.amount = 33
      @recurring.from_ledger_account = @from_ledger_account
      @recurring.to_ledger_account = @to_ledger_account
    end

    context :supporting_records do
      it 'should create a transaction for each month' do
        expect { @recurring.create_recurrences}.to change { Cashflow::Transaction.count }.by(12)
      end

      it 'should create a 2 legder entries for each month' do
        expect { @recurring.create_recurrences}.to change { Cashflow::LedgerEntry.count }.by(24)
      end
    end
    context :transaction_dates do
      context :monthly_frequency do
        before :each do
          @recurring.frequency = Cashflow::TransactionFrequency.monthly
          @recurring.end_date = @start_date + 11.months
          @recurring.create_recurrences
        end
        it 'should create first transaction for the start date' do
          Cashflow::Transaction.for_date(@start_date).count.should == 1
        end
        it 'should create repeating transactions for the correct day of the month' do
          Cashflow::Transaction.for_date(@start_date + 1.month).count.should == 1
        end
        it 'should create last transactions for the correct date' do
          Cashflow::Transaction.last.date.should == @start_date + 11.months
        end

      end
      context :weekly_frequency do
        before :each do
          @recurring.frequency = Cashflow::TransactionFrequency.weekly
          @recurring.end_date = @start_date + 51.weeks
          @recurring.create_recurrences
        end
        it 'should create first transaction for the start date' do
          Cashflow::Transaction.for_date(@start_date).count.should == 1
        end
        it 'should create repeating transactions for 1 weeks time' do
          Cashflow::Transaction.for_date(@start_date + 1.week).count.should == 1
        end
        it 'should create repeating transactions for 2 weeks time' do
          Cashflow::Transaction.for_date(@start_date + 2.weeks).count.should == 1
        end
        it 'should create last transactions for the correct date' do
          Cashflow::Transaction.last.date.should == @start_date + 51.weeks
        end

      end

      context :daily_frequency do
        before :each do
          @recurring.frequency = Cashflow::TransactionFrequency.daily
          @recurring.end_date = @start_date + 30.days
          @recurring.create_recurrences
        end
        it 'should create first transaction for the start date' do
          Cashflow::Transaction.for_date(@start_date).count.should == 1
        end
        it 'should create repeating transactions for 1 days time' do
          Cashflow::Transaction.for_date(@start_date + 1.day).count.should == 1
        end
        it 'should create repeating transactions for 2 days time' do
          Cashflow::Transaction.for_date(@start_date + 2.days).count.should == 1
        end
        it 'should create last transactions for the correct date' do
          Cashflow::Transaction.last.date.should == @start_date + 30.days
        end

      end

      context :annualy_frequency do
        before :each do
          @recurring.frequency = Cashflow::TransactionFrequency.annualy
          @start_date = Date.parse('2012/12/31')
          @recurring.start_date = @start_date
          @recurring.end_date = @start_date + 4.years
          @recurring.create_recurrences
        end
        it 'should create first transaction for the start date' do
          Cashflow::Transaction.for_date(@start_date).count.should == 1
        end
        it 'should create repeating transactions for 1 years time' do
          Cashflow::Transaction.for_date(@start_date + 1.year).count.should == 1
        end
        it 'should create repeating transactions for 2 years time' do
          Cashflow::Transaction.for_date(@start_date + 2.years).count.should == 1
        end
        it 'should create last transactions for the correct date' do
          Cashflow::Transaction.last.date.should == @start_date + 4.years
        end

      end
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

  end
end

