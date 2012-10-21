require 'spec_helper'

describe Cashflow::RecurringTransaction do

  it { should have_many :transactions }


  context 'recur a deposit (debit)' do
  
    before :each do
      @bank_account = Cashflow::BankAccount.create!
      @recurring = described_class.new
      @recurring.start_date = 2012-01-01
      @recurring.end_date = 2012-12-01
      @recurring.day_of_month = 1
      @recurring.debit_bank_account = @bank_account
    end

    it 'should create a transaction for each month' do
      expect { @recurring.create_recurrences}.to change { Cashflow::Transaction.count }.by(12)
    end


  end
end

