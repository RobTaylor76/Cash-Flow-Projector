require 'spec_helper'

describe LedgerEntry do
  describe :class do
    it 'should have relationships' do
      subject.should belong_to(:ledger_account)
      subject.should belong_to(:user)
      subject.should belong_to(:analysis_code)
    end
  end

  describe :new_record do
    it 'should init correctly' do
      subject.debit.should == 0
      subject.credit.should == 0
      subject.date.should == Date.today

    end
  end
end
