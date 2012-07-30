require 'spec_helper'

describe BankAccount do
 
  describe :klass do
    it { should respond_to(:name) }
  end
 
  describe :new_bank_account do 
    its(:balance) { should == 0 }
  end
end
