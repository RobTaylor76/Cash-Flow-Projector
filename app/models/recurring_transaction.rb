class RecurringTransaction < ActiveRecord::Base
  extend DateValidator

  has_many :transactions, :class_name => Transaction, :dependent => :destroy
  belongs_to :from, :class_name => LedgerAccount
  belongs_to :to, :class_name => LedgerAccount
  belongs_to :percentage_of, :class_name => LedgerAccount
  belongs_to :frequency, :class_name => TransactionFrequency
  belongs_to :user

  validates_date :start_date
  validates_date :end_date
  validate :validate_amount_or_percentage

  def create_recurrences
    create_transaction(start_date)
    recurrence_date = next_recurrence(start_date)

    while (recurrence_date <= end_date)
      create_transaction(recurrence_date)
      recurrence_date = next_recurrence(recurrence_date)
    end

  end

  private

  def next_recurrence(current_date)
    recurrence_date = current_date.next_year if frequency == TransactionFrequency.annualy
    recurrence_date = current_date.next_month if frequency == TransactionFrequency.monthly
    recurrence_date = current_date + 1.week if frequency == TransactionFrequency.weekly
    recurrence_date = current_date.next_day if frequency == TransactionFrequency.daily
    recurrence_date
  end

  def create_transaction(recurrence_date)
    tran = Transaction.create!(:date => recurrence_date, :recurring_transaction => self)
    tran_amount = calculate_transaction_amount(recurrence_date)
    tran.move_money(from, to, tran_amount)
  end

  def calculate_transaction_amount(date)
    if amount != 0.00
      amount
    else
      ((percentage_of.balance(date).abs) * (percentage/100))
    end
  end

  def validate_amount_or_percentage
    errors.add(:base, I18n.t('errors.recurring_transaction.cannot_have_amount_and_percentage')) if (amount != 0.00) && (percentage != 0.00)

  end
end
