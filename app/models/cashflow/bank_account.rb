module Cashflow
  class BankAccount < ActiveRecord::Base

    attr_accessible :name
    belongs_to :user

    after_initialize :create_ledger_account

    has_one :ledger_account, :class_name => Cashflow::LedgerAccount,
                  :as => :accountable, :inverse_of => :accountable

    def deposit(ammount, date)
      ledger_account.debit(ammount, date)
    end

    def withdraw(ammount, date)
      ledger_account.credit(ammount, date)
    end

    def balance(date=Date.tomorrow)
      ledger_account.balance(date)
    end

    # return the bank activity for the specified date
    def activity(date)
      ledger_account.activity(date)
    end

    # return daily balances for a date range...
    def daily_balances(start_date, end_date)
      ledger_account.daily_balances(start_date, end_date)
    end

    private

    def create_ledger_account
      build_ledger_account
    end
  end
end

