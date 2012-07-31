require 'spec_helper'

describe Cashflow::BankAccount do

  subject { Cashflow::BankAccount.new }
  describe :klass do
    it { should respond_to(:name) }
  end
 
  describe :new_bank_account do 
    its(:balance) { should == 0 }
  end

  describe :deposits do
    
    before :each do
      @bank_account = Cashflow::BankAccount.create!
    end

    it "will create a single transaction" do
      expect { @bank_account.deposit 100 }.to change { Cashflow::Transaction.count }.by(1)
    end

    it "will total up all deposits" do
      @bank_account.deposit 100.01
      @bank_account.deposit 200.03

      @bank_account.balance.should == 300.04
    end
  end
  describe :withdrals do

    before :each do
      @bank_account = Cashflow::BankAccount.create!
    end

    it "will create a single transaction" do
      expect { @bank_account.withdraw 100 }.to change { Cashflow::Transaction.count }.by(1)
    end

    it "will total up all withdrawls" do
      @bank_account.withdraw 100.01
      @bank_account.withdraw 300.03

      @bank_account.balance.should == -400.04
  
    end
  end
end
