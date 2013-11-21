class CreateStatementImport < ActiveRecord::Migration
  def change
    create_table :statement_imports do |t|
      t.references :ledger_account, :null => false
      t.references :user, :null => false
      t.date :date, :null => false
      t.date :from
      t.date :to
      t.timestamps
    end
  end
end
