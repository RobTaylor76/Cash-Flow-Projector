require 'spec_helper'

describe User do

  describe :relationships do
    it { should have_many :ledger_accounts}
    it { should have_many :bank_accounts }
    it { should have_many :transactions}
  end
end
