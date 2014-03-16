class GraphHelper
  class << self

    def generate_pie_chart_series(series_def)
      series_name = series_def[:series_name]
      series_data = series_def[:data]
      label_field = series_def[:label_field]
      value_field = series_def[:value_field]

      series = {:data => [], :name => series_name}
      series_data.each do |data|
         series[:data] << {:name => data[label_field], :y => data[value_field].to_f.round(2)}
      end
      series
    end

    def generate_line_chart_series(series_def)
      series_name = series_def[:series_name]
      daily_balances = series_def[:daily_balances]
      field_to_graph = series_def[:field_to_graph]
      bucket_size = series_def[:bucket_size]

      series_data = []
      start_date = daily_balances.first[:date]
      end_date = daily_balances.last[:date]

      increment = calculate_increment(bucket_size)

      cashflow_total = 0
      next_date = start_date
      daily_balances.each do |daily_balance|
        cashflow_total = cashflow_total + daily_balance[:activity]
        if (daily_balance[:date] == next_date) || (daily_balance[:date] == end_date)
          graph_point = if field_to_graph == :balance
                          daily_balance[field_to_graph]
                        else
                          cashflow_total
                        end
          series_data << [format_date(daily_balance[:date]),graph_point.to_f.round(2)]
          cashflow_total = 0
          next_date = next_date + increment
        end
      end
      {:name => series_name, :data => series_data}
    end

    def calculate_optimal_bucket_size(daily_balances)
      size = daily_balances.size

      if size < 50
        :day
      elsif size < 366
        :week
      elsif size < (364 * 5)
        :month
      else
        :year
      end
    end

    def calculate_increment(bucket_size)
      increment = case bucket_size
                  when :year
                    1.year
                  when :month
                    1.month
                  when :week
                    1.week
                  else
                    1.day
                  end
    end

    def format_date(date)
     date.to_datetime.to_i * 1000 
    end
  end
end
