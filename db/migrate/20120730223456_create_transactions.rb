class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.references :user, :nil => false
      t.string :reference, :default => ''
      t.date :date
      t.timestamps
    end
  end
end
