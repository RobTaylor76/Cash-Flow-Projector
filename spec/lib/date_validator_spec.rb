require 'spec_helper'
require 'date_validator'
class DummyModel
  extend DateValidator
  include ActiveModel::Validations
  attr_accessor :date, :nillable_date

  validates_date :date
  validates_date :nillable_date, :allow_nil => true
end

describe DateValidator do

  subject { DummyModel.new }
it {should validate_date :nillable_date, :allow_nil => true }
it {should validate_date :date }
  before :each do
    subject.date = '01/01/2012'
    subject.nillable_date = '01/01/2012'
  end

  describe :validates_date do
    context 'when date is valid' do
      it 'has no errors' do
        expect(subject.valid?).to be true
      end
    end

    context 'when date is nil ' do

      context 'when nil option is true' do
        it 'has no errors' do
          subject.nillable_date = nil
          expect(subject.valid?).to be true
        end
      end

      context 'when nil option is false' do
        it 'has errors' do
          subject.date = nil
          expect(subject.valid?).to be false
          subject.errors[:date].should include(I18n.t('activerecord.errors.messages.invalid_date'))
        end
      end
    end

    context 'when date is invalid' do
      it 'has errors' do
        subject.date = Date.new(1975,1,1)
        expect(subject.valid?).to be false
        subject.errors[:date].should include(I18n.t('activerecord.errors.messages.invalid_date'))
      end
      it 'has errors' do
        subject.date = Date.new(2300,1,1)
        expect(subject.valid?).to be false
        subject.errors[:date].should include(I18n.t('activerecord.errors.messages.invalid_date'))
      end
      it 'has errors' do
        subject.date = '01/01/201222222'
        expect(subject.valid?).to be false
        subject.errors[:date].should include(I18n.t('activerecord.errors.messages.invalid_date'))
      end
    end
  end
end
