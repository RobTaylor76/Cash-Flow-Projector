class LedgerAccountHelper
  class << self
    def correct_balance(ledger_account, balance_date, required_balance, correction_date, reference)
      user = ledger_account.user
      current_balance = ledger_account.balance(balance_date)
      correction_account = find_correction_account(user)


      debit, credit, amount = if required_balance > current_balance
                                [ledger_account, correction_account, (required_balance - current_balance)]
                              else
                                [correction_account, ledger_account, (current_balance - required_balance)]
                              end

      #transaction_details[:source] = nil
      transaction_details = {:reference => reference}
      transaction_details[:date] = correction_date
      transaction_details[:debit] = debit.id
      transaction_details[:credit] = credit.id
      transaction_details[:amount] = amount
      transaction_details[:analysis_code] = user.default_analysis_code.id
      TransactionHelper.create_transaction(user, transaction_details)
    end


    private
    def find_correction_account(user)
      user.ledger_accounts.control_account('balance_correction')
    end
  end
end
