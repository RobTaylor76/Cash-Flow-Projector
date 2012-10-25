require 'spec_helper'

describe Cashflow::RecurringTransaction do

  it { should have_many :transactions }


  context 'recur a deposit (debit)' do

    before :each do
      user = User.create!(:email => 'r@rob.com', :password => '##12##34')
      @from_ledger_account = user.ledger_accounts.create!( :name => 'from' )
      @to_ledger_account = user.ledger_accounts.create!( :name => 'to' )

      @recurring = described_class.new
      @recurring.start_date = 2012-01-01
      @recurring.end_date = 2012-12-01
      @recurring.day_of_month = 1
      @recurring.from_ledger_account = @from_ledger_account
      @recurring.to_ledger_account = @to_ledger_account
    end

    it 'should create a transaction for each month' do
      expect { @recurring.create_recurrences}.to change { Cashflow::Transaction.count }.by(12)
    end


  end
end

