class BankAccount < ActiveRecord::Base
  
  #Initailise new bank accounts
  def initialise 
    @balance = 0
  end
end
