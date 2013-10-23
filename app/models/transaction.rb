class Transaction < ActiveRecord::Base
  extend DateValidator

  validates_date :date
  validate :validate_balanced

  belongs_to :user
  belongs_to :source, :polymorphic => true
  has_many :ledger_entries, :dependent => :destroy

  after_initialize :init
  after_save :propogate_date_to_ledger_entries, :if => :date_changed?

  scope :date_range_filter, lambda{|from, to|  where('transactions.date >= ? AND transactions.date <= ?', from,to)}
  scope :before_date, lambda { |cutoff|  where('transactions.date < ?', cutoff) }
  scope :for_date, lambda { |required_date| where('transactions.date  = ?', required_date) }

  def amount
    ledger_entries.sum(:credit)
  end

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

  def propogate_date_to_ledger_entries
    ActiveRecord::Base.transaction do
      ledger_entries.update_all(:date => self.date)
    end
  end
end
