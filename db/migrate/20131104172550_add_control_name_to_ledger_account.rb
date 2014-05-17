class AddControlNameToLedgerAccount < ActiveRecord::Migration
  def change
    add_column :ledger_accounts, :control_name, :string
  end
end
