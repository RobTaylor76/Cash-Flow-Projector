require 'spec_helper'

describe User do

  describe :relationships do
    it { should have_many :analysis_codes }
    it { should have_many :ledger_accounts}
    it { should have_many :ledger_entries}
    it { should have_many :bank_accounts}
    it { should have_many :transactions}
    it { should have_many :recurring_transactions}
  end
end
