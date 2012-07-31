class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.references :bank_account
      t.decimal :debit, :precision => 14, :scale => 2, :default => 0.0
      t.decimal :credit, :precision => 14, :scale => 2, :default => 0.0
      t.date :date
      t.timestamps
    end
  end
end
