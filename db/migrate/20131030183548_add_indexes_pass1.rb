class AddIndexesPass1 < ActiveRecord::Migration
  def change
    add_index :ledger_entries, :ledger_account_id, :name => 'lgr_entries_ledger_account_fk'
    add_index :ledger_entries, [:ledger_account_id, :date], :name => 'lgr_entries_ledger_account_date_idx'
    add_index :transactions, :user_id, :name => 'transactions_user_id_fk'
    add_index :transactions, [:user_id, :date], :name => 'transactions_user_date_idx'
  end
end
