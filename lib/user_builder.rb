class UserBuilder
  class << self
    def add_dependancies(user)
      add_control_accounts(user)
      add_default_bank_accounts(user)
    end

    private
    def add_control_accounts(user)
      control_accounts.each do |control_account|
        unless user.ledger_accounts.control_account(control_account[:control_name]).present?
          user.ledger_accounts.create( :name => control_account[:name],
                                       :control_name => control_account[:control_name])
        end
      end
    end

    def add_default_bank_accounts(user)
      default_bank_accounts.each do |bank_account|
        unless user.bank_accounts.where(:name => bank_account[:name]).present?
          user.bank_accounts.create( :name => bank_account[:name])
        end
      end
    end


    def default_bank_accounts
      [{:name => 'Current'}]
    end

    def control_accounts
      [{:name => 'Bank Statement Import', :control_name => 'bank_statement_import'},
      {:name => 'Income', :control_name => 'income'},
      {:name => 'Expense', :control_name => 'expense'}]
    end
  end
end
