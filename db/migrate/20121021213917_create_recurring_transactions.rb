class CreateRecurringTransactions < ActiveRecord::Migration
  def change
    create_table :recurring_transactions do |t|
      t.date :start_date
      t.date :end_date
      t.references :user, :nil => false
      t.references :from
      t.references :to
      t.references :percentage_of
      t.references :transaction
      t.references :frequency
      t.decimal :amount, :precision => 14, :scale => 2, :default => nil
      t.decimal :percentage, :precision => 14, :scale => 2, :default => nil
      t.integer :day_of_month
      t.timestamps
    end
  end
end
