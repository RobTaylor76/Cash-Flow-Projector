require 'spec_helper'

describe Cashflow::Transaction do
  it { subject.should belong_to(:bank_account) }

  describe :new_record do
 #   require 'pry';binding.pry
    its(:debit) { should == 0 }
    its(:credit) { should == 0 }
    its(:date)  { should == Date.today}
  end
end
