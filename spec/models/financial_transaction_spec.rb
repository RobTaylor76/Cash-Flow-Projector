require 'spec_helper'

describe FinancialTransaction do
  fail_fast_translations

  # it { subject.should have_many(:ledger_entries) }
  # it { subject.should belong_to(:user) }
  # it { subject.should belong_to(:source) }

  subject { FinancialTransaction.new }

  describe :new_record do
    it {expect(subject.reference).to eq '' }
    it {expect(subject.date).to eq Date.today }
  end

  before :each do
    @user = User.find_by_email('test_user@cashflowprojector.com')
    @from = @user.ledger_accounts.create!( :name => 'from' )
    @from.debit 100.00, Date.yesterday
    @to = @user.ledger_accounts.create!( :name => 'to' )
    @tr = @user.financial_transactions.create(:date => Date.yesterday)
  end

  context :validations do
    it 'credits should == debits' do
      @tr.ledger_entries.build(:date => Date.today, :debit => 0, :credit => 30)
      @tr.valid?
      @tr.errors[:base].should include  I18n.t('errors.transaction.unbalanced_transaction')
      @tr.ledger_entries.build(:date => Date.today, :debit => 30, :credit => 0)
      @tr.valid?
      @tr.errors[:base].should_not include  I18n.t('errors.transaction.unbalanced_transaction')
    end
  end

  describe :amount do
    it 'should == total of credits or debits - set on before_save ' do
      @tr.move_money(@from,@to, 30.00)
      @tr.amount.should ==  30.00
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
      @tr.ledger_entries.each do |entry|
        entry.date.should == Date.yesterday
      end
    end
    it 'should have 2 ledger entries' do
      @tr.move_money(@from,@to, 30.00)
      @tr.ledger_entries.count.should == 2
    end

    it 'it should set the dates correctly on create' do

      tr = @user.financial_transactions.build
      new_date = Date.today + 7.days
      tr.date = new_date

      tr.ledger_entries.build(:ledger_account_id => @from.id, :credit => 33.11)
      tr.ledger_entries.build(:ledger_account_id => @from.id, :debit => 33.11)

      tr.save!
      tr.reload

      tr.amount.should == 33.11
      tr.ledger_entries.each do |entry|
        entry.date.should == new_date
      end
    end
  end

  describe :dates do
    it 'should use the supplied date for ledger entries and transaction' do
      tr = @user.financial_transactions.create(:date => Date.today + 5.days)
      tr.move_money(@from,@to, 30.00)
      tr.ledger_entries.each {|entry| entry.date.should == (Date.today + 5.days) }
    end
  end
end
