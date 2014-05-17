class AddRecurringTransactionIdToTranactions < ActiveRecord::Migration
  def change
    add_column :transactions, :source_id, :integer
    add_column :transactions, :source_type, :string
  end
end
