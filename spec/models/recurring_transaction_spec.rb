require 'spec_helper'

describe RecurringTransaction do

  fail_fast_translations

  it { should have_many :transactions }
  it { should belong_to :user }
  it { should belong_to :frequency }


  context 'recur a money transfer' do

    before :each do
      @user = User.create!(:email => 'r@rob.com', :password => '##12##34')
      @from_ledger_account = @user.ledger_accounts.create!( :name => 'from' )
      @to_ledger_account = @user.ledger_accounts.create!( :name => 'to' )

      @start_date = Date.parse('2012/01/01')
      @end_date = @start_date + 11.months

      @recurring = @user.recurring_transactions.build
      @recurring.frequency = TransactionFrequency.monthly
      @recurring.start_date = @start_date
      @recurring.end_date = @end_date
      @recurring.amount = 33
      @recurring.from = @from_ledger_account
      @recurring.to = @to_ledger_account
    end

    context :validations do
      it 'should have either a non zero amount or percentage but not both' do
        @recurring.percentage = 1
        @recurring.amount = 33
        @recurring.valid?
        @recurring.errors[:base].should include I18n.t('errors.recurring_transaction.cannot_have_amount_and_percentage')

        @recurring.percentage = 1
        @recurring.amount = 0.00
        @recurring.valid?
        @recurring.errors[:base].should_not include I18n.t('errors.recurring_transaction.cannot_have_amount_and_percentage')

        @recurring.percentage = 0.00
        @recurring.amount = 1
        @recurring.valid?
        @recurring.errors[:base].should_not include I18n.t('errors.recurring_transaction.cannot_have_amount_and_percentage')
      end
    end
    context :supporting_records do
      it 'should create a transaction for each month' do
        expect { @recurring.create_recurrences}.to change { @user.transactions.count }.by(12)
      end

      it 'should create a 2 legder entries for each month' do
        expect { @recurring.create_recurrences}.to change { LedgerEntry.count }.by(24)
      end
    end

    context :duplications, :focus => true do
      before :each do
        @start_date = Date.parse('2013/05/01')
        @recurring.start_date = @start_date
        @recurring.end_date = @start_date + 2.months
        @recurring.reference = 'XXXXXXXX'
        @recurring.amount = 30.00
      end
      it 'should not duplicate if tran exists for same date and amount for same ledger accounts' do
        tran = @user.transactions.create(:date => Date.parse('2013/06/01'), :reference => 'wibble')
        tran.move_money(@from_ledger_account,@to_ledger_account, 30.00)

        expect { @recurring.create_recurrences}.to change { @user.transactions.count }.by(2)

        @recurring.transactions[0].date.should == Date.parse('2013/05/01')
        @recurring.transactions[1].date.should == Date.parse('2013/07/01')
      end

      it 'should not duplicate if approximation and same date,reference  and ledger accounts matches' do
        tran = @user.transactions.create(:date => Date.parse('2013/06/01'), :reference => 'XXXXXXXX')
        tran.move_money(@from_ledger_account,@to_ledger_account, 30.33)

        tran = @user.transactions.create(:date => Date.parse('2013/07/01'), :reference => 'bibble')
        tran.move_money(@from_ledger_account,@to_ledger_account, 30.33)

        @recurring.approximation = true

        expect { @recurring.create_recurrences}.to change { @user.transactions.count }.by(2)

        @recurring.transactions[0].date.should == Date.parse('2013/05/01')
        @recurring.transactions[1].date.should == Date.parse('2013/07/01')

      end
    end
    context :transaction_dates do

      context :avoid_weekends do
        it 'should not be recurred on the weekend, future transactions still occur on same date' do
          @start_date = Date.parse('2013/05/01')
          @recurring.start_date = @start_date
          @recurring.end_date = @start_date + 3.months
          @recurring.working_days_only = true
          @recurring.approximation = true
          @recurring.create_recurrences
          @recurring.transactions[0].date.should == @start_date
          @recurring.transactions[0].approximation.should be_true
          @recurring.transactions[1].date.should == Date.parse('2013/06/03') #1st is sunday
          @recurring.transactions[1].approximation.should be_true
          @recurring.transactions[2].date.should == Date.parse('2013/07/01')
          @recurring.transactions[2].approximation.should be_true
        end

      end
      context :monthly_frequency do
        before :each do
          @recurring.frequency = TransactionFrequency.monthly
          @recurring.end_date = @start_date + 11.months
          @recurring.create_recurrences
        end
        it 'should create the transactions on correct dates'do
        #it 'should create first transaction for the start date' do
          @user.transactions.for_date(@start_date).count.should == 1
        #it 'should create repeating transactions for the correct day of the month' do
          @user.transactions.for_date(@start_date + 1.month).count.should == 1
        #it 'should create last transactions for the correct date' do
          @user.transactions.last.date.should == @start_date + 11.months
        end

      end
      context :weekly_frequency do
        before :each do
          @recurring.frequency = TransactionFrequency.weekly
          @recurring.end_date = @start_date + 51.weeks
          @recurring.create_recurrences
        end
        it 'should create the transactions on correct dates'do
        #it 'should create first transaction for the start date' do
          @user.transactions.for_date(@start_date).count.should == 1
        #it 'should create repeating transactions for 1 weeks time' do
          @user.transactions.for_date(@start_date + 1.week).count.should == 1
        #it 'should create repeating transactions for 2 weeks time' do
          @user.transactions.for_date(@start_date + 2.weeks).count.should == 1
        #it 'should create last transactions for the correct date' do
          @user.transactions.last.date.should == @start_date + 51.weeks
        end

      end

      context :daily_frequency do
        before :each do
          @recurring.frequency = TransactionFrequency.daily
          @recurring.end_date = @start_date + 30.days
          @recurring.create_recurrences
        end
        it 'should create the transactions on correct dates'do
        #it 'should create first transaction for the start date' do
          @user.transactions.for_date(@start_date).count.should == 1
        #it 'should create repeating transactions for 1 days time' do
          @user.transactions.for_date(@start_date + 1.day).count.should == 1
        #it 'should create repeating transactions for 2 days time' do
          @user.transactions.for_date(@start_date + 2.days).count.should == 1
        #it 'should create last transactions for the correct date' do
          @user.transactions.last.date.should == @start_date + 30.days
        end

      end

      context :annualy_frequency do
        before :each do
          @recurring.frequency = TransactionFrequency.annualy
          @start_date = Date.parse('2012/12/31')
          @recurring.start_date = @start_date
          @recurring.end_date = @start_date + 4.years
          @recurring.create_recurrences
        end
        it 'should create the transactions on correct dates'do
        #it 'should create first transaction for the start date' do
          @user.transactions.for_date(@start_date).count.should == 1
        #it 'should create repeating transactions for 1 years time' do
          @user.transactions.for_date(@start_date + 1.year).count.should == 1
        #it 'should create repeating transactions for 2 years time' do
          @user.transactions.for_date(@start_date + 2.years).count.should == 1
        #it 'should create last transactions for the correct date' do
          @user.transactions.last.date.should == @start_date + 4.years
        end

      end
    end

    context :daily_balances do

      before :each do
        @recurring.create_recurrences
      end

      it 'should affect the daily balances' do
      #it 'should have  33 for 1st month in to_account' do
        @to_ledger_account.balance(Date.parse('2012/01/04')).should == 33
      #it 'should have  -33 for 1st month in from_account' do
        @from_ledger_account.balance(Date.parse('2012/01/04')).should == -33
      #it 'should have 399 in to_account day after last tran' do
        @to_ledger_account.balance(Date.parse('2012/12/04')).should == 396
      #it 'should have -399 in to_account day after last tran' do
        @from_ledger_account.balance(Date.parse('2012/12/04')).should == -396
      end
    end

    context :interest_payments do
      before :each do
        @recurring.frequency = TransactionFrequency.annualy
        @start_date = Date.parse('2012/12/31')
        @recurring.start_date = @start_date
        @recurring.end_date = @start_date + 4.years
        @recurring.amount = 0.00
        @recurring.percentage = 10
      end

      context :interest_on_loan do
        before :each do
          @from_ledger_account.debit(-100, Date.parse('2012/12/30'))
          @recurring.percentage_of = @from_ledger_account
          @recurring.create_recurrences
        end
        it 'should increase the to account by a %age of the from account on the given date' do
          @from_ledger_account.balance(Date.parse('2013/01/01')).should == -110
          @from_ledger_account.balance(Date.parse('2014/01/01')).should == -121
        end
      end

      context :interest_on_bank do
        before :each do
          @to_ledger_account.debit(100, Date.parse('2012/12/30'))
          @recurring.percentage_of = @to_ledger_account
          @recurring.create_recurrences
        end

        it 'should increase the to account by a %age of the to account on the given date' do
          @to_ledger_account.balance(Date.parse('2013/01/01')).should == 110
          @to_ledger_account.balance(Date.parse('2014/01/01')).should == 121
        end
      end
    end
  end
end

