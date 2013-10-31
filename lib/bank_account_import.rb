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
      date = Date.parse(row_data[:date])
      to,from = if amount > 0
                  [bank_ledger,import_ledger]
                else
                  [import_ledger,bank_ledger]
                end
      create_transaction(user,date,row_data[:reference],to,from,amount.abs)

    end

    def create_transaction(user,date,reference,to,from,amount)
      tran = user.transactions.build(:reference => reference, :date => date)
      tran.ledger_entries.build(:ledger_account => to, :debit => amount)
      tran.ledger_entries.build(:ledger_account => from, :credit => amount)
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
