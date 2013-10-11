class LedgerEntry < ActiveRecord::Base
  extend DateValidator

  #attr_accessible :credit, :debit, :date, :ledger_account_id, :transaction
  belongs_to :ledger_account
  belongs_to :transaction
  belongs_to :user
  after_initialize :init

  validates_date :date

  scope :before_date, lambda { |cutoff|  where('ledger_entries.date < ?', cutoff) }
  scope :for_date, lambda { |required_date| where('ledger_entries.date  = ?', required_date) }

  def init
    self.date ||= Date.today
    self.credit ||= 0
    self.debit ||= 0
    self.user ||= ledger_account.user if ledger_account
  end
end
