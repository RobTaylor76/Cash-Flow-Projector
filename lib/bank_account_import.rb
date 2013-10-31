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

      to,from = if amount > 0
                  [bank_ledger,import_ledger]
                else
                  [import_ledger,bank_ledger]
                end

      amount = amount.abs
      tran_details = {:amount => amount,
                      :to => to, :from => from,
                      :date => Date.parse(row_data[:date]), 
                      :reference => row_data[:reference],
                      :md5 => md5}


      unless transaction_exits(user, tran_details)
        create_transaction(user, tran_details)
      end

    end

    def transaction_exits(user, transaction_details)
      return true if  user.transactions.where(:import_sig => transaction_details[:md5]).present?

      user.transactions.where(:date => transaction_details[:date], :amount => transaction_details[:amount]).each do |tran|
        require 'pry'; binding.pry
      end

      false
    end

    def create_transaction(user,transaction_details)
      tran = user.transactions.build(:reference => transaction_details[:reference], :date => transaction_details[:date], :import_sig =>transaction_details[:md5])
      tran.ledger_entries.build(:ledger_account => transaction_details[:to], :debit => transaction_details[:amount])
      tran.ledger_entries.build(:ledger_account => transaction_details[:from], :credit => transaction_details[:amount])
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
