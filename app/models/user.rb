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
  has_many :transactions
  has_many :recurring_transactions
  has_many :analysis_codes

  private
  def add_dependancies
    UserBuilder.add_dependancies(self)
  end
end
