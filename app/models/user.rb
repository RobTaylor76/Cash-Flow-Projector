class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  after_create :add_dependancies

  # Setup accessible (or protected) attributes for your model
#  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body
  has_many :ledger_accounts
  has_many :ledger_entries
  has_many :bank_accounts
  has_many :financial_transactions
  has_many :recurring_transactions
  has_many :analysis_codes

  def default_analysis_code
    analysis_codes.find_or_create_by(:name => 'Misc')
  end

  def balance_correction_account
    ledger_accounts.control_account('balance_correction')
  end

  def import_ledger_account
    ledger_accounts.control_account('statement_import')
  end

  private
  def add_dependancies
    UserBuilder.add_dependancies(self)
  end
end
