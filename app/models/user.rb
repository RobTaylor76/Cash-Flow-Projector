class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body
  has_many :ledger_accounts, :class_name => Cashflow::LedgerAccount
  has_many :bank_accounts, :class_name => Cashflow::BankAccount
  has_many :transactions, :class_name => Cashflow::Transaction
  has_many :recurring_transactions, :class_name => Cashflow::RecurringTransaction
end
