require 'spec_helper'

describe BalanceCorrection do

  before :each do
    @user = User.find_by_email('test_user@cashflowprojector.com')
    @bank_account_la = @user.bank_accounts.first.main_ledger_account
    @corrections_la = @user.ledger_accounts.control_account('balance_correction')
  end

  describe :relationships do
    it 'has em!' do
      correction = @corrections_la.balance_corrections.build
      correction.should belong_to :user
      correction.should belong_to :ledger_account
      correction.should have_one :transaction
    end
  end

  describe :correction do

    it 'creates a historic transaction which corrects the balance' do
      balance_date = Date.today
      correction_date = Date.today - 1.year

      required_balances =  [234.44,-234.44]
      required_balances.each do |required_balance|
        expect do
          expect do
            correction = @bank_account_la.balance_corrections.build
            correction.reference = 'balance correction'
            correction.balance = required_balance
            correction.date = balance_date
            correction.correction_date = correction_date
            correction.save!
            @bank_account_la.balance(balance_date).should == required_balance
            correction.correction.should == required_balance
          end.to change {@user.transactions.for_date(correction_date).count}.by(1)
        end.to change {BalanceCorrection.count}.by(1)
        @bank_account_la.balance_corrections.destroy_all
      end
    end
  end
end
