class Cashflow::TransactionFrequency < ActiveRecord::Base
   attr_accessible :name

   self.all.each do  |freq|
     define_singleton_method "#{freq.name.downcase}" do
         freq
     end
   end
end
