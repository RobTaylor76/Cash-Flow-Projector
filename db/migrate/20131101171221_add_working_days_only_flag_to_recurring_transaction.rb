class AddWorkingDaysOnlyFlagToRecurringTransaction < ActiveRecord::Migration
  def change
    add_column :recurring_transactions, :working_days_only, :boolean, :default => false
  end
end
