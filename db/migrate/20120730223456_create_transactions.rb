class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.references :bank_account
      t.float :debit, :default => 0.0
      t.float :credit, :default => 0.0
      t.date :date
      t.timestamps
    end
  end
end
