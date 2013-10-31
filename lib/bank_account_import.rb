class BankAccountImport
  class << self

    def process_statement(user,bank_account, csv_text)
      bank_ledger = bank_ledger_account(bank_account)
      import_ledger = import_ledger_account(user, bank_account)

      ActiveRecord::Base.transaction do
        DataImporter.import_file(csv_text, header_map) do |row_data, md5|
          process_transaction(user, row_data, bank_ledger, import_ledger,md5)
        end
      end
    end

    private
    def process_transaction(user, row_data, bank_ledger, import_ledger,md5)
      amount = row_data[:amount].to_d

      debit,credit,type = if amount > 0
                  [bank_ledger,import_ledger,:debit]
                else
                  [import_ledger,bank_ledger,:credit]
                end

      amount = amount.abs
      tran_details = {:amount => amount,
                      :debit => debit, :credit => credit,
                      :date => Date.parse(row_data[:date]),
                      :reference => row_data[:reference],
                      :type => type, :md5 => md5}


      unless transaction_exits?(user, tran_details)
        create_transaction(user, tran_details)
      end

    end

    def transaction_exits?(user, transaction_details)
      return true if already_imported?(user,transaction_details)

      matching_trans = matching_transactions(user, transaction_details)

      return true if matching_trans.present?

      false
    end

    def already_imported?(user,transaction_details)
      user.transactions.where(:import_sig => transaction_details[:md5]).present?
    end

    def matching_transactions(user, transaction_details)
      matching_trans = []
      possible_matching_transactions(user, transaction_details).each do |tran|
        if transaction_matches?(tran, transaction_details)
          matching_trans << tran
        end
      end
      matching_trans
    end

    def transaction_matches?(transaction,transaction_details)
      tran_type = transaction_details[:type]
      transaction.ledger_entries.find do |entry| 
        ((entry.send(tran_type) == transaction_details[:amount])  &&
         (entry.ledger_account == transaction_details[tran_type]))
      end.present?
    end

    def possible_matching_transactions(user, transaction_details)
      user.transactions.where(:date => transaction_details[:date], :amount => transaction_details[:amount])
    end

    def create_transaction(user,transaction_details)
      tran = user.transactions.build(:reference => transaction_details[:reference], :date => transaction_details[:date], :import_sig =>transaction_details[:md5])
      tran.ledger_entries.build(:ledger_account => transaction_details[:debit], :debit => transaction_details[:amount])
      tran.ledger_entries.build(:ledger_account => transaction_details[:credit], :credit => transaction_details[:amount])
      tran.save!
    end

    def bank_ledger_account(bank_account)
      bank_account.main_ledger_account
    end
    def import_ledger_account(user,bank_account)
      user.ledger_accounts.find_or_create_by(:name => 'Bank Statement Import')
    end

    def header_map
      { 'Date' => :date,
        'Transaction Date' => :date,
        'Memo' => :reference,
        'Description' => :reference,
        'Reference' => :reference,
        'Amount' => :amount}
    end
  end
end
