require 'spec_helper'

describe LedgerEntry do
  # describe :class do
  #   it 'should have relationships' do
  #     subject.should belong_to(:ledger_account)
  #     subject.should belong_to(:user)
  #     subject.should belong_to(:analysis_code)
  #   end
  # end

  subject { LedgerEntry.new }

  describe :new_record do
    it 'should init correctly' do
      subject.debit.should == 0
      subject.credit.should == 0
      subject.date.should == Date.today
    end
  end

  describe :security do
    fail_fast_translations
    before :each do
      @user = User.find_by_email('test_user@cashflowprojector.com')
      tran = @user.financial_transactions.build
      @le = tran.ledger_entries.build(:analysis_code_id => @user.default_analysis_code.id,
                                      :ledger_account_id => @user.ledger_accounts.pluck(:id).first)

    end
    it 'should only allow users analysis codes to be used' do
      @le.should be_valid

      @le.analysis_code_id = -1
      @le.should_not be_valid
      @le.errors[:base].should include I18n.t('errors.security.invalid_lookup_id')
    end

    it 'should only allow users ledger accounts to be used' do
      @le.should be_valid

      @le.ledger_account_id = -1
      @le.should_not be_valid
      @le.errors[:base].should include I18n.t('errors.security.invalid_lookup_id')
    end
  end
end
