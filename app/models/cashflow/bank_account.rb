module Cashflow 
  class BankAccount < ActiveRecord::Base

    has_many :transactions

    def deposit ammount
      transactions.create!(:debit => ammount)
    end

    def withdraw ammount
      transactions.create!(:credit => ammount)
    end

    def balance 
      transactions.sum(:debit) - transactions.sum(:credit)
    end
  end
end

