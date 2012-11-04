module Cashflow
  class LedgerAccount < ActiveRecord::Base
    has_many :ledger_entries, :class_name => Cashflow::LedgerEntry
    belongs_to :user

    attr_accessible :name

    def debit(amount, date, transaction = nil)
      ledger_entries.create(:debit => amount, :date => date, :transaction => transaction)
    end

    def credit(amount, date, transaction = nil)
      ledger_entries.create(:credit => amount, :date => date, :transaction => transaction)
    end

    def increase(amount, date, transaction = nil)
      debit(amount, date, transaction)
    end

    def decrease(amount, date, transaction = nil)
      credit(amount, date, transaction)
    end

    # return the balance at the start of a given date, default to tomorrow to to get up to date balance
    def balance(date=Date.tomorrow)
      ledger_entries.before_date(date).sum(:debit) - ledger_entries.before_date(date).sum(:credit)
    end


    # return the bank activity for the specified date
    def activity(date)
      ledger_entries.for_date(date).sum(:debit) - ledger_entries.for_date(date).sum(:credit)
    end

    # return daily balances for a date range...
    def daily_balances(start_date, end_date)
      balance = balance(start_date)
      balances = Array.new
      ((start_date)..(end_date)).each do |date|
        balance += activity(date-1) unless date == start_date
        balances << {:date => date, :balance => balance }
      end 
      balances
    end
  end
end
