class Change < ActiveRecord::Migration
  def change
    rename_column :ledger_entries, :transaction_id, :financial_transaction_id
    rename_table :transactions, :financial_transactions
  end
end
