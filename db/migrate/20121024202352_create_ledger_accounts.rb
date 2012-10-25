class CreateLedgerAccounts < ActiveRecord::Migration
  def change
    create_table :ledger_accounts do |t|
      t.references :user, :null => false
      t.string :name
      t.timestamps
    end
  end
end
