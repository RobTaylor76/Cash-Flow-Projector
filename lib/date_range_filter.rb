class DateRangeFilter
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend DateValidator

  attr_accessor :start_date, :end_date, :filter_submit_path
  validates_date :start_date, :end_date

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
end
