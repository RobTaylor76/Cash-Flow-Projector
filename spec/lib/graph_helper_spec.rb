require 'spec_helper'

describe GraphHelper do

  it 'should take a legder account and a date range and generate the daily balances in JSON for high charts' do

    daily_balances = []

    start_date = Date.today.beginning_of_month
    end_date = start_date + 1.year
    expected_json = {}
    expected_series_data = []

    start_date.upto(end_date).each do |date|
      daily_balance = { :date => date, :balance => Random.rand(100), :activity => Random.rand(100) }
      daily_balances << daily_balance

    end
    series_name = 'test'
    json = GraphHelper.generate_graph_series(series_name , daily_balances, :balance, :week)

    expected_series_data =  generate_expected_data(daily_balances, start_date, end_date, :week)
    expected_series_data.size.should  == 53 #?
    expected_json = {:name => series_name, :data => expected_series_data}

    json.should == expected_json
  end

  def generate_expected_data(daily_balances, start_date, end_date, bucket_size)
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
    bucket = {}
    bucket_balances = []

    next_date = start_date
    while next_date < end_date
      daily_balance = daily_balances.find{|b| b[:date] == next_date}
      break if daily_balance.nil?
      bucket_balances << [format_date(next_date), daily_balance[:balance].to_f]
      next_date = next_date + increment
    end
    bucket_balances
  end

  def format_date(date)
    date.to_datetime.to_i * 1000 
  end
end
