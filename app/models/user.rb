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
  has_many :ledger_accounts, :class_name => LedgerAccount
  has_many :ledger_entries, :class_name => LedgerEntry
  has_many :bank_accounts, :class_name => BankAccount
  has_many :transactions, :class_name => Transaction
  has_many :recurring_transactions, :class_name => RecurringTransaction

  private
  def add_dependancies
    UserBuilder.add_dependancies(self)
  end
end
