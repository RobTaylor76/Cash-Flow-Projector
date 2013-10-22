class GraphHelper
  class << self

    def generate_graph_series(series_name, daily_balances, field_to_graph, bucket_size)
      series_data = []
      start_date = daily_balances.first[:date]
      end_date = daily_balances.last[:date]

      increment = calculate_increment(bucket_size)

      next_date = start_date
      while next_date < end_date
        daily_balance = daily_balances.find{|b| b[:date] == next_date}
        break if daily_balance.nil?
        series_data << [format_date(daily_balance[:date]),daily_balance[field_to_graph].to_f]
        next_date = next_date + increment
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

    def format_number(value)
      '%.2f' % value
    end

  end
end
