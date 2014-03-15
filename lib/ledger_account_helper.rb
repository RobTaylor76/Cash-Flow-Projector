class LedgerAccountHelper
  class << self
    # return daily balances for a date range...
    def daily_balances(ledger_account, start_date, end_date)
      balance = ledger_account.balance(start_date)

      data = execute_sql(daily_balances_sql(ledger_account, start_date, end_date))

      balances = Array.new
      ((start_date)..(end_date)).each do |date|
        delta = if data[date].present?
                  delta = data[date]['activity'].to_d
                else
                  0.00
                end
        balances << {:date => date, :balance => balance, :activity => delta }
        balance += delta
      end
      balances
    end

    private

    def daily_balances_sql(ledger_account, start_date, end_date)
      sql = "select date, sum(debit) - sum(credit) as activity "
      sql +="from ledger_entries where ledger_account_id = #{ledger_account.id} "
      sql +="and (date >= Date('#{start_date}') AND date <= Date('#{end_date}')) "
      sql +="group by date"
    end

    def execute_sql(sql)
      results = ActiveRecord::Base.connection.select_all(sql)
      transform_data_to_hash(results)
    end

    def transform_data_to_hash(data_set)
      hash = {}
      data_set.each do |item|
        key = Date.parse(item['date'])
        hash[key] = item
      end
      hash
    end
  end
end
