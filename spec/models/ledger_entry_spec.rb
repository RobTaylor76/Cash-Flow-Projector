require 'spec_helper'

describe LedgerEntry do
  it { subject.should belong_to(:ledger_account) }
  it { subject.should belong_to(:user) }

  describe :new_record do
    its(:debit) { should == 0 }
    its(:credit) { should == 0 }
    its(:date)  { should == Date.today}
  end
end
