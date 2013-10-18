class Transaction < ActiveRecord::Base
  extend DateValidator

  validates_date :date
  validate :validate_balanced

  belongs_to :user
  belongs_to :recurring_transaction
  has_many :ledger_entries, :dependent => :destroy

  after_initialize :init

  scope :before_date, lambda { |cutoff|  where('transactions.date < ?', cutoff) }
  scope :for_date, lambda { |required_date| where('transactions.date  = ?', required_date) }

#  def amount
#    ledger_entries.sum(:credit)
#  end

  def balanced?
    sum_credits = ledger_entries.map(&:credit).reduce(:+)
    sum_debits = ledger_entries.map(&:debit).reduce(:+)
    sum_credits  == sum_debits
  end

  def move_money(from, to, amount)
    from.decrease(amount, self.date, self)
    to.increase(amount, self.date, self)
  end
  private

  def validate_balanced
    errors.add(:base, I18n.t('errors.transaction.unbalanced_transaction')) unless balanced?
  end

  def init
    self.date ||= Date.today
    self.reference ||= ''
  end
end
