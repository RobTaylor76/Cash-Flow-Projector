class BalanceCorrection < ActiveRecord::Base
  include DateRangeScopes
  extend DateValidator

  belongs_to :user
  belongs_to :ledger_account
  has_one :transaction, :as => :source, :dependent => :destroy

  after_initialize :set_defaults, :if => :new_record?
  before_save :save_transaction

  validates :reference, :ledger_account_id, :presence => true
  validates_date :date
  validates_date :correction_date
  validate :validate_correction_before_balance

  private
  def set_defaults
    self.date ||= Date.today
    self.correction_date ||= Date.yesterday
    self.user_id ||= self.ledger_account.user_id
    self.reference ||= 'Balance Correction'
  end

  def validate_correction_before_balance
    unless correction_date < date
      errors.add(:base, I18n.t('errors.balance_correction.correction_before_balance'))
    end
  end

  def save_transaction
    self.transaction.destroy if self.transaction.present?
    correct_balance
  end

  def correct_balance
    current_balance = ledger_account.balance(date)
    correction_account = user.balance_correction_account


    debit, credit, amount, modifier = if balance > current_balance
                              [ledger_account, correction_account, (balance - current_balance), 1]
                            else
                              [correction_account, ledger_account, (current_balance - balance), -1]
                            end

    self.correction = amount * modifier

    transaction_details = {:reference => reference}
    transaction_details[:date] = correction_date
    transaction_details[:debit] = debit.id
    transaction_details[:credit] = credit.id
    transaction_details[:amount] = amount
    transaction_details[:analysis_code] = user.default_analysis_code.id
    self.transaction = TransactionHelper.create_transaction(user, transaction_details)
  end

end
