class UserBuilder
  class << self
    def add_dependancies(user)
      add_control_accounts(user)
      add_default_bank_accounts(user)
      add_default_analysis_codes(user)
    end

    private
    def add_control_accounts(user)
      control_accounts.each do |account|
        user.ledger_accounts.create( :name => account[:name],
                                    :control_name => account[:control_name])
      end
    end

    def add_default_bank_accounts(user)
      default_bank_accounts.each do |bank_account|
        user.bank_accounts.create( :name => bank_account[:name])
      end
    end

    def add_default_analysis_codes(user)
      default_analysis_codes.each do |analysis_code|
        user.analysis_codes.create( :name => analysis_code[:name])
      end
    end

    def default_analysis_codes
      [{:name => 'Misc'}, {:name => 'Income'}, {:name => 'Expense'}]
    end
    def default_bank_accounts
      [{:name => 'Current'}]
    end

    def control_accounts
      [{:name => 'Statement Import', :control_name => 'statement_import'},
      {:name => 'Balance Correction', :control_name => 'balance_correction'},
      {:name => 'Income', :control_name => 'income'},
      {:name => 'Expense', :control_name => 'expense'}]
    end
  end
end
