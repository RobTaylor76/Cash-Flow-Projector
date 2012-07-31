module Cashflow
  class Transaction < ActiveRecord::Base
    attr_accessible :credit, :debit, :date
    belongs_to :bank_account
    after_initialize :init
    
    scope :date_cutoff, lambda { |cutoff|  where('transactions.date < ?', cutoff) }

    def init
      self.date ||= Date.today
      self.credit ||= 0
      self.debit ||= 0
    end
  end
end
