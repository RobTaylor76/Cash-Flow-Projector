require 'spec_helper'

describe Transaction do
  fail_fast_translations

  it { subject.should have_many(:ledger_entries) }
  it { subject.should belong_to(:user) }
  it { subject.should belong_to(:source) }

  describe :new_record do
    its(:reference) { should == '' }
    its(:date)  { should == Date.today}
  end
  before :each do
    @user = User.create!(:email => 'r@rob.com', :password => '##12##34')
    @from = @user.ledger_accounts.create!( :name => 'from' )
    @from.debit 100.00, Date.yesterday
    @to = @user.ledger_accounts.create!( :name => 'to' )
    @tr = @user.transactions.create
  end

  context :validations do
    it 'should have either a non zero amount or percentage but not both' do
      @tr.ledger_entries.build(:date => Date.today, :debit => 0, :credit => 30)
      @tr.valid?
      @tr.errors[:base].should include  I18n.t('errors.transaction.unbalanced_transaction')
      @tr.ledger_entries.build(:date => Date.today, :debit => 30, :credit => 0)
      @tr.valid?
      @tr.errors[:base].should_not include  I18n.t('errors.transaction.unbalanced_transaction')
    end
  end

  describe :ledger_entries do

  #    @cr.debit 200.03, Date.today, @tr
    it 'should move money from  the from_account to the to_account' do
      @from.balance.should == 100
      @to.balance.should == 0
      @tr.move_money(@from,@to, 30.00)
      @from.balance.should == 70
      @to.balance.should == 30
    end
    it 'should have 2 ledger entries' do
      @tr.move_money(@from,@to, 30.00)
      @tr.ledger_entries.count.should == 2
    end
  end

  describe :dates do
    it 'should default transaction date and ledger entries to today' do
      @tr.move_money(@from,@to, 30.00)
      @tr.ledger_entries.each {|entry| entry.date.should == Date.today }
    end

    it 'should use the supplied date for ledger entries and transaction' do
      @tr = @user.transactions.create(:date => Date.today + 5.days)
      @tr.move_money(@from,@to, 30.00)
      @tr.ledger_entries.each {|entry| entry.date.should == (Date.today + 5.days) }
    end
  end

end
