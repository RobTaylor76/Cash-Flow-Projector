require 'spec_helper'

describe BankAccountImport do
  before :each do
    @user = User.find_by_email('test_user@cashflowprojector.com')
    @bank_account = @user.bank_accounts.create!( :name => 'test' )


  end

  it 'should match the existing transaction do nothing' do
    tran = create_transaction({:user => @user,
      :date => Date.parse('1/1/2014'),
      :reference => 'tran 1',
      :debit => @bank_account.main_ledger_account,
      :credit => @bank_account.charges_ledger_account,
      :amount => 1234.56,
      :approximation => false})
  end

  def create_transaction(tran_spec)
    tran = tran_spec[:user].transactions.create(
                                :reference => tran_spec[:date],
                                :date => tran_spec[:date],
                                :approximation => tran_spec[:approximation])
    tran.move_money(tran_spec[:debit],
                      tran_spec[:credit],
                      tran_spec[:amount])

    tran
  end

end
