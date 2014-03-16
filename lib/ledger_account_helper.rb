class LedgerAccountHelper
  class << self
    # return daily balances for a date range...
    def daily_balances(ledger_account, start_date, end_date)
      balance = ledger_account.balance(start_date)

      sql = daily_balances_sql(ledger_account, start_date, end_date)
      key_proc = ->(item){Date.parse(item['date'])}
      data = execute_sql(sql)
      data = transform_data_to_hash(data, key_proc)

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

    # return analysis code summary for a date range...
    def analysis_code_summary(ledger_account, start_date, end_date)
      sql = analysis_code_summary_sql(ledger_account, start_date, end_date)
      data = execute_sql(sql)

      summary = { :income => [], :expense => []}
      data.each do |row|
        total = row['total'].to_d
        target = if total > 0
                   summary[:income]
                 else
                   total = total * -1
                   summary[:expense]
                 end
        target <<  {:name => row['analysis_code'], :total => total}
      end
      summary
    end

    private

    def analysis_code_summary_sql(ledger_account, start_date, end_date)
      sql =  "select sum(debit-credit) as total, analysis_codes.name as analysis_code "
      sql += "from ledger_entries, analysis_codes "
      sql += "where ledger_account_id = #{ledger_account.id} "
      sql += "and analysis_code_id = analysis_codes.id "
      sql += "and (date >= Date('#{start_date}') AND date <= Date('#{end_date}')) "
      sql += "group by analysis_codes.name, analysis_code_id"
    end

    def daily_balances_sql(ledger_account, start_date, end_date)
      sql = "select date, sum(debit) - sum(credit) as activity "
      sql +="from ledger_entries where ledger_account_id = #{ledger_account.id} "
      sql +="and (date >= Date('#{start_date}') AND date <= Date('#{end_date}')) "
      sql +="group by date"
    end

    def execute_sql(sql)
      ActiveRecord::Base.connection.select_all(sql)
    end

    def transform_data_to_hash(data_set, key_proc)
      hash = {}
      data_set.each do |item|
        key = key_proc.call(item)
        hash[key] = item
      end
      hash
    end
  end
end
