module Cashflow
  class LedgerEntry < ActiveRecord::Base
    attr_accessible :credit, :debit, :date, :ledger_account_id
    belongs_to :ledger_account
    after_initialize :init
    
    scope :before_date, lambda { |cutoff|  where('ledger_entries.date < ?', cutoff) }
    scope :for_date, lambda { |required_date| where('ledger_entries.date  == ?', required_date) }

    def init
      self.date ||= Date.today
      self.credit ||= 0
      self.debit ||= 0
    end
  end
end
