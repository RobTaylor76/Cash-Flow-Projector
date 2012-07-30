module Cashflow 
  class BankAccount < ActiveRecord::Base

    after_initialize :init

    has_many :transactions

    def deposit ammount
      self.balance += ammount
    end

    def withdraw ammount
      self.balance -= ammount
    end

    #Initailise new bank accounts
    def init
      self.balance = 0 
    end
  end
end

