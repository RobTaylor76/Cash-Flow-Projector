class TransactionHelper
  class << self
    def create_recurrable_transaction(transaction)
      recurrence = RecurringTransaction.new
      recurrence.start_date = transaction.date + 1.month # dafault is to recurr monthly
      recurrence.end_date = recurrence.start_date + 1.year # dafault is for a year
      recurrence.frequency = TransactionFrequency.monthly
      recurrence.amount = transaction.amount
      recurrence.reference = transaction.reference
      transaction.ledger_entries.each do |entry|
        if entry.credit != 0.00
          recurrence.from = entry.ledger_account
        else
          recurrence.to = entry.ledger_account
        end
      end
      recurrence
    end
  end
end
