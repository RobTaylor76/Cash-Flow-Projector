class CreateBalanceCorrection < ActiveRecord::Migration
  def change
    create_table :balance_corrections do |t|
      t.references :user, :nil => false
      t.references :ledger_account, :nil => false
      t.decimal :balance, :precision => 14, :scale => 2, :default => 0.0
      t.date :date
      t.date :correction_date
      t.string :reference
      t.timestamps
    end
  end
end
