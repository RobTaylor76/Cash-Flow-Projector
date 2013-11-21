class StatementImport < ActiveRecord::Base

  belongs_to :user
  belongs_to :ledger_account

  has_many :transactions, :dependent => :destroy, :as => :source

  after_initialize :set_defaults, :if => :new_record?

  private

  def set_defaults
    self.user_id ||= ledger_account.user_id
  end
end

