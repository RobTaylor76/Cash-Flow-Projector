class BankAccount < ActiveRecord::Base

  belongs_to :user
  belongs_to :main_ledger_account, :class_name => LedgerAccount
  belongs_to :charges_ledger_account, :class_name => LedgerAccount

  after_initialize :create_ledger_accounts, :if => :new_record?
  after_save :update_ledger_account_names, :if => :name_changed?

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
    LedgerAccountHelper.daily_balances(main_ledger_account, start_date, end_date)
  end

  private

  def update_ledger_account_names
    ActiveRecord::Base.transaction do
      main_ledger_account.name = main_ledger_name
      main_ledger_account.save
      charges_ledger_account.name = charges_ledger_name
      charges_ledger_account.save
    end
  end

  def main_ledger_name
    self.name
  end

  def charges_ledger_name
    "#{self.name} (Interest & Charges)"
  end

  def create_ledger_accounts
    unless self.main_ledger_account_id.present?
      self.main_ledger_account = user.ledger_accounts.build(:name => main_ledger_name)
    end
    unless self.charges_ledger_account_id.present?
      self.charges_ledger_account = user.ledger_accounts.build(:name => charges_ledger_name )
    end
  end
end
