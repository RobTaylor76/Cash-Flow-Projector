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

      summary = { :debits => [], :credits => []}
      data.each do |row|
        dr_total = row['debits'].to_d
        cr_total = row['credits'].to_d

        if dr_total > 0
          summary[:debits] << {:analysis_code => row['analysis_code'], :total => dr_total}
        end
        if cr_total > 0
          summary[:credits] << {:analysis_code => row['analysis_code'], :total => cr_total}
        end
      end
      summary
    end

    private

    def analysis_code_summary_sql(ledger_account, start_date, end_date)
      sql =  "select sum(debit) as debits, sum(credit) as credits, analysis_codes.name as analysis_code "
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
