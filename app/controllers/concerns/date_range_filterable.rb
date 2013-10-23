module DateRangeFilterable
  extend ActiveSupport::Concern

  def apply_date_range_filter(scope)
    scope.date_range_filter(@date_range_filter.start_date,@date_range_filter.end_date)
  end

  def set_up_date_range_filter(filter_path)
    params[:date_range_filter] ||= {}

    if params[:date_range_filter][:start_date].present?
      params[:date_range_filter][:start_date] = Date.parse(params[:date_range_filter][:start_date])
    else
      params[:date_range_filter][:start_date] = Date.today-30
    end

    if params[:date_range_filter][:end_date].present?
      params[:date_range_filter][:end_date] = Date.parse(params[:date_range_filter][:end_date])
    else
      params[:date_range_filter][:end_date] = Date.today
    end

    @date_range_filter = DateRangeFilter.new(params[:date_range_filter])
    @date_range_filter.filter_submit_path = filter_path
  end
end
