class AddRecurringTransactionIdToTranactions < ActiveRecord::Migration
  def change
    add_column :transactions, :recurring_transaction_id, :integer
  end
end
