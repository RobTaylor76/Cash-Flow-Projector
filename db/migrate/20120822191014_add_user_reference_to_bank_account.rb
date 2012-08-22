class AddUserReferenceToBankAccount < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :user_id, :integer
  end
end
