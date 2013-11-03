class RecurringTransaction < ActiveRecord::Base
  extend DateValidator

  belongs_to :user
  belongs_to :from, :class_name => LedgerAccount
  belongs_to :to, :class_name => LedgerAccount
  belongs_to :percentage_of, :class_name => LedgerAccount
  belongs_to :frequency, :class_name => TransactionFrequency
  has_many :transactions, :class_name => Transaction, :dependent => :destroy, :as => :source

  validates_date :start_date
  validates_date :end_date
  validate :validate_amount_or_percentage

  validates :amount, :percentage , :numericality => true
  validates :to_id,  :from_id, :frequency_id, :presence => true

  after_initialize :set_defaults

  def edit_recurrences
    return false unless valid?
    ActiveRecord::Base.transaction do
      transactions.destroy_all
      create_recurrences
      save!
    end
  end

  def create_recurrences
    return false unless valid?
    ActiveRecord::Base.transaction do
      create_transaction(start_date)
      recurrence_date = next_recurrence(start_date)

      while (recurrence_date <= end_date)
        create_transaction(recurrence_date)
        recurrence_date = next_recurrence(recurrence_date)
      end
      save!
    end
  end

  private

  def duplication?(date,amount)
    transactions = possible_duplicates(date,amount)
    return false unless transactions.present?
    ledger_ids = [to.id, from.id].sort
    transactions.each do |tran|
      return true if tran.ledger_entries.map(&:ledger_account_id).sort == ledger_ids
    end
    false
  end

  def possible_duplicates(date, amount)
    scope = user.transactions.includes(:ledger_entries).for_date(date)

    if approximation
      scope.where(:reference => reference)
    else
      scope.where(:amount => amount)
    end
  end

  def next_recurrence(current_date)
    recurrence_date = current_date.next_year if frequency == TransactionFrequency.annualy
    recurrence_date = current_date.next_month if frequency == TransactionFrequency.monthly
    recurrence_date = current_date + 1.week if frequency == TransactionFrequency.weekly
    recurrence_date = current_date.next_day if frequency == TransactionFrequency.daily
    recurrence_date
  end

  def create_transaction(recurrence_date)
    if working_days_only
      recurrence_date = recurrence_date + 2.days if recurrence_date.wday == 6 # saturday
      recurrence_date = recurrence_date + 1.days if recurrence_date.wday == 0 # sunday
    end

    tran_amount = calculate_transaction_amount(recurrence_date)
    return if tran_amount == 0.00
    return if duplication?(recurrence_date,tran_amount)

    tran = user.transactions.create(:date => recurrence_date,
                                    :source => self,
                                    :approximation => approximation,
                                    :reference => reference)
    tran.move_money(from, to, tran_amount)
  end

  def calculate_transaction_amount(date)
    if percentage != 0.00
      ((percentage_of.balance(date).abs) * (percentage/100))
    else
      amount
    end
  end

  def validate_amount_or_percentage
    errors.add(:base, I18n.t('errors.recurring_transaction.cannot_have_amount_and_percentage')) if (amount != 0.00) && (percentage != 0.00)
    errors.add(:base, I18n.t('errors.recurring_transaction.need_to_specify_which_account_to_take_percentage_of')) if (percentage != 0.00) && (percentage_of.nil?)
  end

  def set_defaults
    self.frequency_id = TransactionFrequency.monthly.id unless self.frequency_id.present?
    self.start_date ||= Date.today
    self.end_date ||= self.start_date + 1.year
  end
end
