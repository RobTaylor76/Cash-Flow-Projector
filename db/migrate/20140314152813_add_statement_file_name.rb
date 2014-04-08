class AddStatementFileName < ActiveRecord::Migration
  def change
    add_column :statement_imports, :file_name, :string, :length => 255
  end
end
