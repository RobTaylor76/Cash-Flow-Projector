module Cashflow
  class RecurringTransaction < ActiveRecord::Base
    # attr_accessible :title, :body
    has_many :transactions, :class_name => Cashflow::Transaction
    belongs_to :from_ledger_account, :class_name => Cashflow::LedgerAccount
    belongs_to :to_ledger_account, :class_name => Cashflow::LedgerAccount
    belongs_to :user

    attr_accessible :start_date, :end_date, :from_ledger_account_id,  :to_ledger_account_id,
                    :amount, :debit_percentage,:credit_percentage
    def create_recurrences
      create_transaction(start_date)
      recurrence_date = start_date.next_month

      while (recurrence_date <= end_date)
        create_transaction(recurrence_date)
        recurrence_date = recurrence_date.next_month
      end

    end

    private

    def create_transaction(recurrence_date)
      tran = Cashflow::Transaction.create!(:date => recurrence_date)
      tran.move_money(from_ledger_account, to_ledger_account, amount)
    end
  end
end
