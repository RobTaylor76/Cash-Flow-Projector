module Cashflow
  class BankAccount < ActiveRecord::Base

    attr_accessible :name
    after_initialize :create_ledger_account

    belongs_to :user
    belongs_to :ledger_account

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
      self.ledger_account ||= user.ledger_accounts.build(:name => self.name)
    end
  end
end

