module Cashflow
  class RecurringTransaction < ActiveRecord::Base
    # attr_accessible :title, :body
    has_many :transactions, :class_name => Cashflow::Transaction
    belongs_to :from_ledger_account, :class_name => Cashflow::LedgerAccount
    belongs_to :to_ledger_account, :class_name => Cashflow::LedgerAccount


    attr_accessible :start_date, :end_date, :from_ledger_account_id,  :to_ledger_account_id,
                    :amount, :debit_percentage,:credit_percentage, :day_of_month
    def create_recurrences
      12.times.inject(0) do |index| 
        recurrence_date = start_date + index.months
        require 'pry'| binding.pry
        Cashflow::Transaction.create!(:date => recurrence_date)
      end
    end
  end
end
