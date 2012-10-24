class CreateLedgerAccounts < ActiveRecord::Migration
  def change
    create_table :ledger_accounts do |t|
      t.references :accountable, :null => false
      t.string :accountable_type, :null => false
      t.string :name
      t.timestamps
    end
  end
end
