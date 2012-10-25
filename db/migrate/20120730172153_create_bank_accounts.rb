class CreateBankAccounts < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.string :name
      t.references :ledger_account, :nil => false
      t.references :user, :nil => false
      t.timestamps
    end
  end
end
