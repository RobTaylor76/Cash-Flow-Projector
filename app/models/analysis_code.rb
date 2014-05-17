class AnalysisCode < ActiveRecord::Base
  belongs_to :user

  validates :name, :presence => true

  default_scope -> {order(:name => :asc)}
end
