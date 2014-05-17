module DateRangeScopes
  extend ActiveSupport::Concern

  included do
    scope :date_range_filter, lambda{|from, to|  where( "#{self.table_name}.date >= ? AND #{self.table_name}.date <= ?", from,to)}
    scope :before_date, lambda { |cutoff|  where("#{self.table_name}.date < ?", cutoff) }
    scope :for_date, lambda { |required_date| where("#{self.table_name}.date  = ?", required_date) }
  end

end
