module Cashflow
  class Transaction < ActiveRecord::Base
    attr_accessible :credit, :debit, :date, :bank_account_id
    belongs_to :bank_account
    after_initialize :init
    
    scope :before_date, lambda { |cutoff|  where('transactions.date < ?', cutoff) }
    scope :for_date, lambda { |required_date| where('transactions.date  == ?', required_date) }

    def init
      self.date ||= Date.today
      self.credit ||= 0
      self.debit ||= 0
    end
  end
end
