require 'spec_helper'

describe Cashflow::Transaction do
  it { subject.should have_many(:ledger_entries) }
  it { subject.should belong_to(:user) }

  describe :new_record do
    its(:reference) { should == '' }
    its(:date)  { should == Date.today}
  end
  before :each do
    user = User.create!(:email => 'r@rob.com', :password => '##12##34')
    @cr = user.ledger_accounts.create!( :name => 'cr' )
    @dr = user.ledger_accounts.create!( :name => 'dr' )
    @tr = user.transactions.build
  end

  describe :ledger_entries do

  #    @dr.debit 100.01, Date.today, @tr
  #    @cr.debit 200.03, Date.today, @tr

  end

end
