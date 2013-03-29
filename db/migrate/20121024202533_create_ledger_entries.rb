class CreateLedgerEntries < ActiveRecord::Migration
  def change
    create_table :ledger_entries do |t|
      t.references :ledger_account, :null => false
      t.references :user, :null => false
      t.references :transaction
      t.decimal :debit, :precision => 14, :scale => 2, :default => 0.0
      t.decimal :credit, :precision => 14, :scale => 2, :default => 0.0
      t.date :date, :null => false
      t.timestamps
    end
  end
end
