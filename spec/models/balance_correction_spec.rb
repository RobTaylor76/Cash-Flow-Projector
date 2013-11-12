require 'spec_helper'

describe BalanceCorrection do

  describe :relationships do
    it 'has em!' do
      subject.should belong_to :user
      subject.should belong_to :ledger_account
      subject.should have_one :transaction
    end
  end

  describe :correction do
    before :each do
      @user = User.find_by_email('test_user@cashflowprojector.com')
      @bank_account_la = @user.bank_accounts.first.main_ledger_account
      @corrections_la = @user.ledger_accounts.control_account('balance_correction')
    end

    it 'creates a historic transaction which corrects the balance' do
      balance_date = Date.today
      correction_date = Date.today - 1.year

      required_balances =  [234.44,-234.44]
      required_balances.each do |required_balance|
        expect do
          expect do
            correction = described_class.new
            correction.required_balance = required_balance
            correction.balance_date = balance_date
            correction.correction_date = correction_date
            correction.ledger_account = @bank_account_la
            correction.save!
            @bank_account_la.balance(balance_date).should == required_balance
          end.to change {@user.transactions.for_date(correction_date).count}.by(1)
        end.to change {BalanceCorrection.count}.by(1)
      end
    end
  end
end
