class CreateRecurringTransactions < ActiveRecord::Migration
  def change
    create_table :recurring_transactions do |t|
      t.date :start_date
      t.date :end_date
      t.references :debit_bank_account
      t.references :credit_bank_account
      t.decimal :amount, :precision => 14, :scale => 2, :default => nil
      t.decimal :debit_percentage, :precision => 14, :scale => 2, :default => nil
      t.decimal :credit_percentage, :precision => 14, :scale => 2, :default => nil
      t.integer :day_of_month
      t.timestamps
    end
  end
end
