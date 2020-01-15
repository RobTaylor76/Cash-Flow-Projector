class TransactionHelper
  class << self
    def create_recurrable_transaction(transaction)
      recurrence = RecurringTransaction.new
      recurrence.start_date = transaction.date + 1.month # dafault is to recurr monthly
      recurrence.end_date = recurrence.start_date + 1.year # dafault is for a year
      recurrence.frequency = TransactionFrequency.monthly
      recurrence.amount = transaction.amount
      recurrence.reference = transaction.reference

      transaction.ledger_entries.includes(:ledger_account).each do |entry|
        if entry.credit != 0.00
          recurrence.from = entry.ledger_account
        else
          recurrence.to = entry.ledger_account
          recurrence.analysis_code_id = entry.analysis_code_id
        end
      end
      recurrence
    end

    def create_transaction(user,transaction_details)
      tran = user.financial_transactions.build(:reference => transaction_details[:reference],
                                     :date => transaction_details[:date],
                                     :source => transaction_details[:source],
                                     :approximation => transaction_details[:approximation],
                                     :import_sig => transaction_details[:md5])
      tran.ledger_entries.build(:ledger_account_id => transaction_details[:debit],
                                :debit => transaction_details[:amount],
                                :analysis_code_id => transaction_details[:analysis_code])
      tran.ledger_entries.build(:ledger_account_id => transaction_details[:credit],
                                :analysis_code_id => transaction_details[:analysis_code],
                                :credit => transaction_details[:amount])
      tran.save!

      tran
    end
  end
end
