require 'spec_helper'

describe Cashflow::LedgerEntry do
  it { subject.should belong_to(:ledger_account) }

  describe :new_record do
    its(:debit) { should == 0 }
    its(:credit) { should == 0 }
    its(:date)  { should == Date.today}
  end
end
