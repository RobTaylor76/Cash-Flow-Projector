require 'spec_helper'

describe StatementImport do
  it { subject.should have_many(:transactions) }
  it { subject.should belong_to(:user) }
  it { subject.should belong_to(:ledger_account) }

end
