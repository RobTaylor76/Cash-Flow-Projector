require 'spec_helper'

describe BankAccount do
  before :each do
    @user = User.find_by_email('test_user@cashflowprojector.com')
    @bank_account = @user.bank_accounts.create!( :name => 'test' )
  end

  subject { @bank_account }

  # describe :relationships do
  #   it { should belong_to :main_ledger_account}
  #   it { should belong_to :charges_ledger_account}
  #   it { should belong_to :user}
  # end

  describe :create_new_bank_account do
    it 'should create 2 ledger accounts' do
      expect do
        @user.bank_accounts.create!( :name => 'test' )
      end.to change {LedgerAccount.count}.by(2)
    end
    it 'bank account name should be as specified' do
      @bank_account.name.should == 'test'
    end

    it 'main legder name should be same as bank account' do
      @bank_account.main_ledger_account.name.should == @bank_account.name
    end
    it 'bank chanrges legder name should be as bank account name + (Interest & Charges)"' do
      @bank_account.charges_ledger_account.name.should == "#{@bank_account.name} (Interest & Charges)"
    end
  end

  describe :klass do
    it { should respond_to(:name) }
  end

  describe :new_bank_account do
    it {expect(subject.balance).to eq 0 }
    it {expect(subject.main_ledger_account).to_not be_nil }
    it {expect(subject.charges_ledger_account).to_not be_nil }
  end

  context :banking do

    describe :deposits do


      it "will total up all deposits" do
        @bank_account.deposit 100.01, Date.today
        @bank_account.deposit 200.03, Date.today
        @bank_account.balance.should == 300.04
      end

      it "should be possible to specify a date for a depoist" do
        @bank_account.deposit 100.02, Date.tomorrow
      end
    end
    describe :withdrals do

      it "will total up all withdrawls" do
        @bank_account.withdraw 100.01, Date.today
        @bank_account.withdraw 300.03, Date.today
        @bank_account.balance.should == -400.04

      end

      it "should be possible to specify a date for a withdrawl" do
        @bank_account.withdraw 100.02, Date.tomorrow
      end
    end


    describe :balance do
      it "should be possible to find the balance at the start of any given day" do

        @bank_account.deposit 100.02, Date.today
        @bank_account.deposit 234.00, Date.tomorrow
        @bank_account.deposit 111.02, Date.today+2
        @bank_account.deposit 321.00, Date.today+3

        @bank_account.balance(Date.today).should == 0
        @bank_account.balance(Date.tomorrow).should == 100.02
        @bank_account.balance(Date.today+2).should == (100.02+234.00)
        @bank_account.balance(Date.today+3).should == (100.02+234.00+111.02)
        @bank_account.balance(Date.today+4).should == (100.02+234.00+111.02+321.00)

      end

      it "should return a list of daily balances for a given date range" do

        @bank_account.deposit 100.02, Date.today
        @bank_account.deposit 234.00, Date.tomorrow
        @bank_account.deposit 111.02, Date.today+2
        @bank_account.deposit 321.00, Date.today+3

        balances = @bank_account.daily_balances Date.today, Date.today+4

        balances.size.should == 5

        balances.inject(Date.today) do |date,balance|
          balance[:date].should == date
          balance[:activity].should ==  @bank_account.activity(date)
          balance[:balance].should ==  @bank_account.balance(date)
          date+=1
        end
      end
    end

    describe :get_daily_balance_transaction_totals do
      it "should list the daily transaction totals (activity) for a given date" do

        @bank_account.deposit 100.02, Date.today
        @bank_account.withdraw 234.00, Date.tomorrow

        @bank_account.deposit 100.02, Date.today+2
        @bank_account.withdraw 234.00, Date.today+2

        @bank_account.activity(Date.today).should == 100.02
        @bank_account.activity(Date.tomorrow).should == -234.00
        @bank_account.activity(Date.today+2).should == -133.98

      end
    end
  end
end
