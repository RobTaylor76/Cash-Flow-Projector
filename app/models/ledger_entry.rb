class LedgerEntry < ActiveRecord::Base
  extend DateValidator

  belongs_to :user

  belongs_to :ledger_account
  belongs_to :transaction
  belongs_to :analysis_code

  after_initialize :set_defaults, :if => :new_record?

  validates_date :date
  validates :analysis_code_id, :presence => true

  scope :date_range_filter, lambda{|from, to|  where('ledger_entries.date >= ? AND ledger_entries.date <= ?', from,to)}
  scope :before_date, lambda { |cutoff|  where('ledger_entries.date < ?', cutoff) }
  scope :for_date, lambda { |required_date| where('ledger_entries.date  = ?', required_date) }

  private
  def set_defaults
    self.date ||= Date.today
    self.credit ||= 0
    self.debit ||= 0
    if ledger_account_id.present?
      self.user_id ||= ledger_account.user_id
    end
    if self.user_id.present?
      self.analysis_code_id ||= user.default_analysis_code.id
    end
  end
end
