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

    #import some test data
    csv_text = File.read('spec/data/activity_summary_import.csv')
    StatementImportHelper.process_statement(@user, @ledger_account, csv_text, 'filename')

    #summarize the ledger enties for the ledger account by analysis code
    start_date = Date.parse('1/2/2014')
    end_date = Date.parse('28/2/2014')

    summary = LedgerAccountHelper.analysis_code_summary(@ledger_account, start_date, end_date)
    #assert equal to our expected analysis code
    income = summary[:debits]
    income.should include( {:total => 200.00, :analysis_code => 'AC1'})
    income.should include( {:total => 200.00, :analysis_code => 'AC2'})

    expense = summary[:credits]
    expense.should include( {:total => 10.00, :analysis_code => 'AC1'})
    expense.should include( {:total => 100.00, :analysis_code => 'AC3'})

  end
end
