require 'spec_helper'

describe TransactionFrequency do

  describe :security do
    xit { should allow_mass_assignment(:name) }
  end

  describe :methods do

    it 'should have a method for each row in database' do
      TransactionFrequency.all.each do |freq|
        described_class.should respond_to(freq.name.downcase)
      end
    end


  end

end
