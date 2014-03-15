require 'spec_helper'

describe GraphHelper do

  before :each do
    @user = User.find_by_email('test_user@cashflowprojector.com')
    @ledger_account = @user.ledger_accounts.create!( :name => 'test' )
  end

  it 'should summarize the activity by analysis code' do

  end

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
    json = GraphHelper.generate_line_chart_series(series_name , daily_balances, :balance, :week)

    expected_series_data =  generate_expected_data(daily_balances, start_date, end_date, :week)
    expected_series_data.first[0].should == format_date(start_date)
    expected_series_data.last[0].should == format_date(end_date)
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
    series_data = []

    next_date = start_date
    daily_balances.each do |daily_balance|
      if (daily_balance[:date] == next_date) || (daily_balance[:date] == end_date)
        series_data << [format_date(daily_balance[:date]),daily_balance[:balance].to_f]
        cashflow_total = 0
        next_date = next_date + increment
      end
    end
    series_data
  end

  def format_date(date)
    date.to_datetime.to_i * 1000 
  end
end
