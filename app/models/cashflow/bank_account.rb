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
      transactions.date_cutoff(date).sum(:debit) - transactions.date_cutoff(date).sum(:credit)
    end
  end
end

