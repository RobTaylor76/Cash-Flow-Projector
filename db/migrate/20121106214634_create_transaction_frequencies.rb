class CreateTransactionFrequencies < ActiveRecord::Migration
  def change
    create_table :transaction_frequencies do |t|
      t.string :name
      t.timestamps
    end
  end
end
