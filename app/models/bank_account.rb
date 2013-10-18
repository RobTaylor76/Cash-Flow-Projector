class BankAccount < ActiveRecord::Base

  after_initialize :create_ledger_accounts

  belongs_to :user
  belongs_to :main_ledger_account, :class_name => LedgerAccount
  belongs_to :charges_ledger_account, :class_name => LedgerAccount

  def deposit(ammount, date)
    main_ledger_account.debit(ammount, date)
  end

  def withdraw(ammount, date)
    main_ledger_account.credit(ammount, date)
  end

  def balance(date=Date.tomorrow)
    main_ledger_account.balance(date)
  end

  # return the bank activity for the specified date
  def activity(date)
    main_ledger_account.activity(date)
  end

  # return daily balances for a date range...
  def daily_balances(start_date, end_date)
    main_ledger_account.daily_balances(start_date, end_date)
  end

  private

  def create_ledger_accounts
    self.main_ledger_account ||= user.ledger_accounts.build(:name => self.name)
    self.charges_ledger_account ||= user.ledger_accounts.build(:name => "#{self.name} (Interest & Charges)")
  end
end
