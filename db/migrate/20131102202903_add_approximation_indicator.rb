class AddApproximationIndicator < ActiveRecord::Migration
  def change
    add_column :transactions, :approximation, :boolean, :default => false
    add_column :recurring_transactions, :approximation, :boolean, :default => true
  end
end
