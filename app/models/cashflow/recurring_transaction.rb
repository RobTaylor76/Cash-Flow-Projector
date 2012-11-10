module Cashflow
  class RecurringTransaction < ActiveRecord::Base
    # attr_accessible :title, :body
    has_many :transactions, :class_name => Cashflow::Transaction
    belongs_to :from_ledger_account, :class_name => Cashflow::LedgerAccount
    belongs_to :to_ledger_account, :class_name => Cashflow::LedgerAccount
    belongs_to :frequency, :class_name => Cashflow::TransactionFrequency
    belongs_to :user

    attr_accessible :start_date, :end_date, :from_ledger_account_id,  :to_ledger_account_id,
                    :amount, :debit_percentage,:credit_percentage
    def create_recurrences
      create_transaction(start_date)
      recurrence_date = next_recurrence(start_date)

      while (recurrence_date <= end_date)
        create_transaction(recurrence_date)
        recurrence_date = next_recurrence(recurrence_date)
      end

    end

    private

    def next_recurrence(current_date)
      recurrence_date = current_date.next_year if frequency == Cashflow::TransactionFrequency.annualy
      recurrence_date = current_date.next_month if frequency == Cashflow::TransactionFrequency.monthly
      recurrence_date = current_date + 1.week if frequency == Cashflow::TransactionFrequency.weekly
      recurrence_date = current_date.next_day if frequency == Cashflow::TransactionFrequency.daily
      recurrence_date
    end

    def create_transaction(recurrence_date)
      tran = Cashflow::Transaction.create!(:date => recurrence_date)
      tran_amount = amount || (to_ledger_account.balance(recurrence_date) * (percentage/100))
      tran.move_money(from_ledger_account, to_ledger_account, tran_amount)
    end
  end
end
