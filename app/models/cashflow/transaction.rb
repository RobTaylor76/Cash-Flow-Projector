module Cashflow
  class Transaction < ActiveRecord::Base
    attr_accessible :date, :reference

    belongs_to :user
    has_many :ledger_entries

    after_initialize :init

    scope :before_date, lambda { |cutoff|  where('transactions.date < ?', cutoff) }
    scope :for_date, lambda { |required_date| where('transactions.date  = ?', required_date) }

    def amount
      ledger_entries.sum(:credit)
    end

    def balanced?
      ledger_entries.sum(:credit) ==ledger_entries.sum(:debit)
    end

    def move_money(from, to, amount)
      from.decrease(amount, self.date, self)
      to.increase(amount, self.date, self)
    end
    private

    def init
      self.date ||= Date.today
      self.reference ||= ''
    end
  end
end
