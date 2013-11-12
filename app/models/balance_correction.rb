class BalanceCorrection < ActiveRecord::Base
  belongs_to :user
  belongs_to :ledger_account
  has_one :transaction, :as => :source

  after_initialize :set_defaults, :if => :new_record?
  before_save :save_transaction

  private
  def set_defaults
    self.correction_date ||= Date.parse('1/1/2000')
  end

  def save_transaction
    self.user_id ||= self.ledger_account.user_id
    self.transaction.destroy if self.transaction.present?
    self.transaction = LedgerAccountHelper.correct_balance(self.ledger_account,
                                                           self.balance_date,
                                                           self.required_balance,
                                                           self.correction_date)
  end
end
