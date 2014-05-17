class AddAnalysisCodeFk < ActiveRecord::Migration
  def change
    add_column :recurring_transactions, :analysis_code_id, :integer
    add_column :ledger_entries, :analysis_code_id, :integer

    add_index :ledger_entries, [:user_id, :analysis_code_id], :name => 'le_user_analysis_code_idx'
  end
end
