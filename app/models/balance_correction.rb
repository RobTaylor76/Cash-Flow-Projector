class BalanceCorrection < ActiveRecord::Base
  include DateRangeScopes
  extend DateValidator

  belongs_to :user
  belongs_to :ledger_account
  has_one :transaction, :as => :source

  after_initialize :set_defaults, :if => :new_record?
  before_save :save_transaction

  validates :reference, :ledger_account_id, :presence => true
  validates_date :date
  validates_date :correction_date


  private
  def set_defaults
    self.correction_date ||= Date.parse('1/1/2000')
    self.user_id ||= self.ledger_account.user_id
  end

  def save_transaction
    self.transaction.destroy if self.transaction.present?
    self.transaction = LedgerAccountHelper.correct_balance(self.ledger_account,
                                                           self.date,
                                                           self.balance,
                                                           self.correction_date,
                                                           self.reference)
  end
end
