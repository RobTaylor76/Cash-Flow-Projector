class CreateBankAccounts < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.string :name
      t.float :balance, :default => 0
      t.timestamps
    end
  end
end
