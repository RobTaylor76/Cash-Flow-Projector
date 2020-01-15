class LedgerEntry < ActiveRecord::Base
  include RelationshipValidator
  extend DateValidator
  include DateRangeScopes

  belongs_to :user

  belongs_to :ledger_account
  belongs_to :financial_transaction
  belongs_to :analysis_code

  after_initialize :set_defaults, :if => :new_record?

  validates_date :date
  validates_relationship :analysis_code_id, :valid_values => :valid_analysis_codes
  validates_relationship :ledger_account_id, :valid_values => :valid_ledger_accounts

  validates :analysis_code_id, :presence => true
  validates :ledger_account_id, :presence => true

  private

  def set_defaults
    self.date ||= Date.today
    self.credit ||= 0
    self.debit ||= 0
    if ledger_account_id.present?
      self.user_id ||= ledger_account.user_id
    end
    if self.user_id.present?
      self.analysis_code_id ||= user.default_analysis_code.id
    end
  end
end
