class StatementImport < ActiveRecord::Base
  include RelationshipValidator
  extend DateValidator
  include DateRangeScopes

  belongs_to :user
  belongs_to :ledger_account

  has_many :transactions, :dependent => :destroy, :as => :source

  validates_relationship :ledger_account_id, :valid_values => :valid_ledger_accounts
  after_initialize :set_defaults, :if => :new_record?

  private

  def set_defaults
    self.user_id ||= ledger_account.user_id
  end
end

