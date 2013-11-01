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
                      :debit => debit.id, :credit => credit.id,
                      :bank => bank_ledger.id, :import => import_ledger.id,
                      :date => Date.parse(row_data[:date]),
                      :reference => row_data[:reference],
                      :type => type, :md5 => "#{md5}-#{bank_ledger.id}"}


      unless transaction_exits?(user, tran_details)
        create_transaction(user, tran_details)
      end

    end

    def transaction_exits?(user, transaction_details)
      return true if already_imported?(user,transaction_details)

      matching_entries = matching_transaction_entries(user, transaction_details)

      if matching_entries.present?
        first_match = matching_entries.find {|entry| entry.ledger_account_id != transaction_details[:bank]}
        if first_match.present?
          first_match.ledger_account_id = transaction_details[:bank]
          first_match.save
        end
        return true
      end

      false
    end

    def already_imported?(user,transaction_details)
      user.transactions.where(:import_sig => transaction_details[:md5]).present?
    end

    def matching_transaction_entries(user, transaction_details)
      matching_entries = []
      possible_matching_transactions(user, transaction_details).each do |tran|
        matching_entries.concat find_matching_entries(tran, transaction_details)
      end
      matching_entries
    end

    def find_matching_entries(transaction,transaction_details)
      tran_type = transaction_details[:type]
      transaction.ledger_entries.find_all do |entry|
        ((entry.send(tran_type) == transaction_details[:amount])  &&
         ((entry.ledger_account_id == transaction_details[:bank]) || # matches the bank account
          (entry.ledger_account_id == transaction_details[:import])))    # matches the import ledger
      end
    end

    def possible_matching_transactions(user, transaction_details)
      user.transactions.where(:date => transaction_details[:date], :amount => transaction_details[:amount])
    end

    def create_transaction(user,transaction_details)
      tran = user.transactions.build(:reference => transaction_details[:reference], :date => transaction_details[:date], :import_sig =>transaction_details[:md5])
      tran.ledger_entries.build(:ledger_account_id => transaction_details[:debit], :debit => transaction_details[:amount])
      tran.ledger_entries.build(:ledger_account_id => transaction_details[:credit], :credit => transaction_details[:amount])
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
