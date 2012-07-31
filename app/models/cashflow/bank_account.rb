module Cashflow 
  class BankAccount < ActiveRecord::Base

    has_many :transactions

    def deposit(ammount, date)
      transactions.create!(:debit => ammount, :date => date)
    end

    def withdraw(ammount, date)
      transactions.create!(:credit => ammount, :date => date)
    end
    # return the balance at the start of a given date, default to tomorrow to to get up to date balance
    def balance(date=Date.tomorrow)
      transactions.before_date(date).sum(:debit) - transactions.before_date(date).sum(:credit)
    end
    # return the bank activity for the specified date
    def activity(date)
      transactions.for_date(date).sum(:debit) - transactions.for_date(date).sum(:credit)
    end
  end
end

