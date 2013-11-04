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
      return true if updated_existing_exact_match?(user,transaction_details)
      return true if updated_existing_approximate_match?(user,transaction_details)
      false
    end

    def updated_existing_approximate_match?(user,transaction_details)
      #find approximate matches
      approx_matches = approximate_transaction_matches(user, transaction_details)
      if approx_matches.present?
        tran = approx_matches.first
        tran.ledger_entries.each do |entry|
          if entry.credit != 0.00
            entry.credit = transaction_details[:amount]
          else
            entry.debit = transaction_details[:amount]
          end
        end
        tran.approximation = false
        tran.date = transaction_details[:date] #update the date as well as matching +/- 4 days
        tran.source = nil # unlink from recurrence , hack for now!
        return tran.save
      end
      false
    end

    def updated_existing_exact_match?(user,transaction_details)
      matching_entries = matching_transaction_entries(user, transaction_details)

      if matching_entries.present?
        first_match = matching_entries.find {|entry| entry.ledger_account_id == transaction_details[:import]}
        if first_match.present?
          # matching transaction imported into another bank account. assign the data import it 
          first_match.ledger_account_id = transaction_details[:bank]
          first_match.save
        end
        true
      else
        false
      end
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

    def approximate_transaction_matches(user, transaction_details)
      matching_trans = []
      tran_type = transaction_details[:type]
      possible_matching_transactions(user, transaction_details, true).each do |tran|
        matches = tran.ledger_entries.find do  |entry|
          ((entry.ledger_account_id == transaction_details[:bank]) && # matches the bank account
           (entry.send(tran_type) != 0.00)) # and its the debit/credit transaction were interested in
        end.present?
        matching_trans << tran if matches
      end
      matching_trans
    end

    def find_matching_entries(transaction,transaction_details)
      tran_type = transaction_details[:type]
      transaction.ledger_entries.find_all do |entry|
        ((entry.send(tran_type) == transaction_details[:amount])  &&
         ((entry.ledger_account_id == transaction_details[:bank]) || # matches the bank account
          (entry.ledger_account_id == transaction_details[:import])))    # matches the import ledger
      end
    end

    def possible_matching_transactions(user, transaction_details, find_approximations = false)
      scope = user.transactions.includes(:ledger_entries)
      if find_approximations
        min_date = transaction_details[:date] - 4.days
        max_date = transaction_details[:date] + 4.days
        scope.date_range_filter(min_date,max_date).where(:reference => transaction_details[:reference], :approximation => true)
      else
        scope.for_date(transaction_details[:date]).where(:amount => transaction_details[:amount])
      end
    end

    def create_transaction(user,transaction_details)
      tran = user.transactions.build(:reference => transaction_details[:reference],
                                     :date => transaction_details[:date],
                                     :import_sig =>transaction_details[:md5])
      tran.ledger_entries.build(:ledger_account_id => transaction_details[:debit], :debit => transaction_details[:amount])
      tran.ledger_entries.build(:ledger_account_id => transaction_details[:credit], :credit => transaction_details[:amount])
      tran.save!
    end

    def bank_ledger_account(bank_account)
      bank_account.main_ledger_account
    end

    def import_ledger_account(user,bank_account)
      user.ledger_accounts.control_account('statement_import')
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
