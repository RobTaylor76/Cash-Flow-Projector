module Cashflow
  class Transaction < ActiveRecord::Base
    # attr_accessible :title, :body
    belongs_to :bank_account
    after_initialize :init

    def init
      self.date = Date.today
      self.credit = 0
      self.debit = 0
    end
  end
end