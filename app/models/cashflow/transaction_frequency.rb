class Cashflow::TransactionFrequency < ActiveRecord::Base
   attr_accessible :name

   def self.cache_lookup_data
     if self.table_exists?
       self.all.each do  |freq|
         define_singleton_method "#{freq.name.downcase}" do
           freq
         end
       end
     end
   end
   cache_lookup_data
end
