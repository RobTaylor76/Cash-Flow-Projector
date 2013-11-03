module DateRangeFilterable
  extend ActiveSupport::Concern

  def apply_date_range_filter(scope)
    scope.date_range_filter(@date_range_filter.start_date,@date_range_filter.end_date)
  end

  def store_in_session(key, value)
    session[key] = value
  end

  def get_from_session(key, default)
    session[key] ||= default
    session[key]
  end

  def set_up_date_range_filter(filter_path)
    date_range_params =  params[:date_range_filter] ||= {}

    if date_range_params[:start_date].present?
      date_range_params[:start_date] = Date.parse(date_range_params[:start_date])
      store_in_session(:start_date, date_range_params[:start_date])
    else
      date_range_params[:start_date] = get_from_session(:start_date, Date.today.beginning_of_month)
    end

    if date_range_params[:end_date].present?
      date_range_params[:end_date] = Date.parse(date_range_params[:end_date])
      store_in_session(:end_date, date_range_params[:end_date])
    else
      date_range_params[:end_date] = get_from_session(:end_date, Date.today.end_of_month)
    end

    if date_range_params[:balance_date].present?
      date_range_params[:balance_date] = Date.parse(date_range_params[:balance_date])
      store_in_session(:balance_date, date_range_params[:end_date])
    else
      date_range_params[:balance_date] = get_from_session(:balance_date, Date.today)
    end

    if date_range_params[:balance_date] > date_range_params[:end_date]
      date_range_params[:balance_date]  = date_range_params[:end_date]
    elsif date_range_params[:balance_date] < date_range_params[:start_date]
      date_range_params[:balance_date]  = date_range_params[:start_date]
    end

    @date_range_filter = DateRangeFilter.new(date_range_params)
    @date_range_filter.filter_submit_path = filter_path
  end
end
