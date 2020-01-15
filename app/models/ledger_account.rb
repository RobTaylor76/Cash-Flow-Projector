class LedgerAccount < ActiveRecord::Base
  belongs_to :user

  has_many :ledger_entries, :dependent => :destroy
  has_many :balance_corrections, :dependent => :destroy
  has_many :statement_imports , :dependent => :destroy

  before_destroy :delete_account_validation
  validate :control_name_restrictions

  default_scope -> {order(:name => :asc)}

  def self.control_account(name)
    where(:control_name => name).first
  end

  def debit(amount, date, transaction = nil)
    ledger_entries.create(:debit => amount, :date => date, :financial_transaction => transaction)
  end

  def credit(amount, date, transaction = nil)
    ledger_entries.create(:credit => amount, :date => date, :financial_transaction => transaction)
  end

  def increase(amount, date, transaction = nil)
    debit(amount, date, transaction)
  end

  def decrease(amount, date, transaction = nil)
    credit(amount, date, transaction)
  end

  # return the balance at the start of a given date, default to tomorrow to to get up to date balance
  def balance(date=Date.tomorrow)
    ledger_entries.before_date(date).sum(:debit) - ledger_entries.before_date(date).sum(:credit)
  end


  # return the bank activity for the specified date
  def activity(date)
    ledger_entries.for_date(date).sum(:debit) - ledger_entries.for_date(date).sum(:credit)
  end

  def is_control_account?
    control_name.present?
  end

  private

  def delete_account_validation
    if is_control_account?
      errors.add(:base, 'cannot delete a control account')
      return false
    end
  end

  def control_name_restrictions
    if persisted? && control_name_changed?
      errors.add(:base, 'cannot change control name')
      return false
    end
  end

end
