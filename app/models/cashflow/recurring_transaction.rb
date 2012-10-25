module Cashflow
  class RecurringTransaction < ActiveRecord::Base
    # attr_accessible :title, :body
    has_many :transactions, :class_name => Cashflow::Transaction
    belongs_to :from_ledger_account, :class_name => Cashflow::LedgerAccount
    belongs_to :to_ledger_account, :class_name => Cashflow::LedgerAccount


    attr_accessible :start_date, :end_date, :from_bank_account_id,  :to_bank_account_id,
                    :amount, :debit_percentage,:credit_percentage, :day_of_month
    def create_recurrences
      12.times { Cashflow::Transaction.create!(:bank_account_id => debit_bank_account.id) }
    end
  end
end
