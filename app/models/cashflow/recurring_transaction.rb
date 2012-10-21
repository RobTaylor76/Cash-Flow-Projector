module Cashflow
  class RecurringTransaction < ActiveRecord::Base
    # attr_accessible :title, :body
    has_many :transactions, :class_name => Cashflow::Transaction
    has_one :debit_bank_account, :class_name => Cashflow::BankAccount
    has_one :credit_bank_account, :class_name => Cashflow::BankAccount


    attr_accessible :start_date, :end_date, :debit_bank_account_id,  :credit_bank_account_id,
                    :amount, :debit_percentage,:credit_percentage, :day_of_month
    def create_recurrences
      12.times { Cashflow::Transaction.create!(:bank_account_id => debit_bank_account.id) }
    end
  end
end
