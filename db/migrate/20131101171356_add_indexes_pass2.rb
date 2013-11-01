class AddIndexesPass2 < ActiveRecord::Migration
  def change
    add_index :transactions, [:user_id, :import_sig], :name => 'transactions_user_import_sig_idx'
  end
end
