class CreateAnalysisCodes < ActiveRecord::Migration
  def change
    create_table :analysis_codes do |t|
      t.references :user, :null => false
      t.string :name
      t.timestamps
    end
  end
end
