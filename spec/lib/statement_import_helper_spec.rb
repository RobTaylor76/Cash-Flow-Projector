require 'spec_helper'

describe StatementImportHelper do
  before :each do
    @user = User.find_by_email('test_user@cashflowprojector.com')
    @bank_account = @user.bank_accounts.first
    @bank_account_la = @bank_account.main_ledger_account
    @csv_text = File.read('spec/data/test_bank_import.csv')
    @data_import_la = @user.ledger_accounts.control_account('statement_import')
    @income_control_account  = @user.ledger_accounts.control_account('income')
    @analysis_type= @user.analysis_codes.create(:name => 'existing analysis code')
    @filename = '/import/file.csv'
  end

  it 'should install all three transactions' do
    expect do
      expect do
        expect do
          StatementImportHelper.process_statement(@user, @bank_account_la , @csv_text, @filename)
        end.to change{@user.transactions.count}.by(3)
      end.to change{@user.analysis_codes.count}.by(1)
    end.to change{@bank_account_la.statement_imports.count}.by(1)

    @bank_account_la.ledger_entries.count.should == 3
    @data_import_la.ledger_entries.count.should == 2
    @income_control_account.ledger_entries.count.should == 1

    @user.transactions.for_date(Date.parse('1/1/2014')).count.should == 1
    @user.transactions.for_date(Date.parse('2/1/2014')).count.should == 1
    @user.transactions.for_date(Date.parse('3/1/2014')).count.should == 1

    @user.transactions.for_date(Date.parse('2/1/2014')).first.tap do |tran|
      tran.ledger_entries.find {|le| le.ledger_account == @income_control_account }.should be_present
      tran.ledger_entries.find {|le| le.analysis_code.name == 'new analysis code'}.should be_present
    end

    @user.transactions.for_date(Date.parse('3/1/2014')).first.tap do |tran|
      tran.ledger_entries.find {|le| le.analysis_code.name == 'existing analysis code'}.should be_present
    end
  end

  it 'should match a transaction for another bank account if Data Import la in use' do
    tran = create_transaction({:user => @user,
      :date => Date.parse('1/1/2014'),
      :reference => 'tran 1',
      :debit => @data_import_la,
      :credit => @bank_account.charges_ledger_account,
      :amount => 1234.56,
      :approximation => false})

    bank_la_id = @bank_account_la.id
    tran.ledger_entries.map(&:ledger_account_id).should_not include bank_la_id

    @user.transactions.for_date(Date.parse('1/1/2014')).count.should == 1

    expect do
      StatementImportHelper.process_statement(@user, @bank_account_la , @csv_text, @filename)
    end.to change{@user.transactions.count}.by(2)

    tran.reload
    tran.ledger_entries.map(&:ledger_account_id).should include bank_la_id

  end

  it 'should match the existing transaction and do nothing' do
    tran = create_transaction({:user => @user,
      :date => Date.parse('1/1/2014'),
      :reference => 'tran 1',
      :debit => @bank_account_la,
      :credit => @bank_account.charges_ledger_account,
      :amount => 1234.56,
      :approximation => false})

    @user.transactions.for_date(Date.parse('1/1/2014')).count.should == 1
    @user.transactions.for_date(Date.parse('2/1/2014')).count.should == 0
    @user.transactions.for_date(Date.parse('3/1/2014')).count.should == 0

    expect do
      StatementImportHelper.process_statement(@user, @bank_account_la , @csv_text, @filename)
    end.to change{@user.transactions.count}.by(2)

    @user.transactions.for_date(Date.parse('2/1/2014')).count.should == 1
    @user.transactions.for_date(Date.parse('3/1/2014')).count.should == 1
  end

  it 'should not match the existing transaction and import them all it' do
    tran = create_transaction({:user => @user,
      :date => Date.parse('3/1/2014'),
      :reference => 'Approximation Import',
      :debit => @bank_account_la,
      :credit => @bank_account.charges_ledger_account,
      :amount => 234.56,
      :approximation => false })

    @user.transactions.for_date(Date.parse('1/1/2014')).count.should == 0
    @user.transactions.for_date(Date.parse('2/1/2014')).count.should == 0
    @user.transactions.for_date(Date.parse('3/1/2014')).count.should == 1

    expect do
      StatementImportHelper.process_statement(@user, @bank_account_la , @csv_text, @filename)
    end.to change{@user.transactions.count}.by(3)

    @user.transactions.for_date(Date.parse('1/1/2014')).count.should == 1
    @user.transactions.for_date(Date.parse('2/1/2014')).count.should == 1
    @user.transactions.for_date(Date.parse('3/1/2014')).count.should == 2

    tran.reload
    tran.amount.should == 234.56
  end

  it 'should match the existing approximation transaction and update it' do
    tran = create_transaction({:user => @user,
      :date => Date.parse('3/1/2014'),
      :reference => 'Approximation Import',
      :debit => @bank_account_la,
      :credit => @bank_account.charges_ledger_account,
      :amount => 234.56,
      :approximation => true})

    @user.transactions.for_date(Date.parse('1/1/2014')).count.should == 0
    @user.transactions.for_date(Date.parse('2/1/2014')).count.should == 0
    @user.transactions.for_date(Date.parse('3/1/2014')).count.should == 1

    expect do
      StatementImportHelper.process_statement(@user, @bank_account_la , @csv_text, @filename)
    end.to change{@user.transactions.count}.by(2)

    @user.transactions.for_date(Date.parse('1/1/2014')).count.should == 1
    @user.transactions.for_date(Date.parse('2/1/2014')).count.should == 1
    @user.transactions.for_date(Date.parse('3/1/2014')).count.should == 1

    tran.reload
    tran.amount.should == 2345.56
  end

  it 'should match the existing approximation transaction +/- 4 days and update it' do
    tran = create_transaction({:user => @user,
      :date => Date.parse('7/1/2014'),
      :reference => 'Approximation Import',
      :debit => @bank_account_la,
      :credit => @bank_account.charges_ledger_account,
      :amount => 234.56,
      :approximation => true})
    tran.source = @user # logically makes no sense but showing that it is unset after import
                        # used to unlink from recurrence so it isn't deleted when recurrence edited/deleted
    tran.save

    @user.transactions.for_date(Date.parse('1/1/2014')).count.should == 0
    @user.transactions.for_date(Date.parse('2/1/2014')).count.should == 0
    @user.transactions.for_date(Date.parse('7/1/2014')).count.should == 1

    expect do
      StatementImportHelper.process_statement(@user, @bank_account_la , @csv_text, @filename)
    end.to change{@user.transactions.count}.by(2)

    tran.reload
    tran.date.should == Date.parse('3/1/2014')
    tran.amount.should == 2345.56
    tran.approximation.should be_false
    tran.source.should == @bank_account_la.statement_imports.last

    @user.transactions.for_date(Date.parse('1/1/2014')).count.should == 1
    @user.transactions.for_date(Date.parse('2/1/2014')).count.should == 1
    @user.transactions.for_date(Date.parse('3/1/2014')).count.should == 1

  end

  def create_transaction(tran_spec)
    tran = tran_spec[:user].transactions.create(
                                :reference => tran_spec[:reference],
                                :date => tran_spec[:date],
                                :approximation => tran_spec[:approximation])
    tran.move_money(tran_spec[:credit],
                      tran_spec[:debit],
                      tran_spec[:amount])

    tran
  end

end
