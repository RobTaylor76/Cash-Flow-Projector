class AddAmountAndSigToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :amount, :decimal, :precision => 14, :scale => 2, :default => 0.0
    add_column :transactions, :import_sig, :string, :default => nil
  end
end
