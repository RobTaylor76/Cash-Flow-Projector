module ValidateDate
  class Matcher
    def initialize(attribute, options)
      @options = options
      @attribute = attribute 
    end

    def matches?(model)
      @model = model

      model.send "#{@attribute.to_s}=", nil
      model.valid?
      errors = model.errors[@attribute]
      found_errors = errors.any? { |error| error == I18n.t('activerecord.errors.messages.invalid_date') }
      return false if ((found_errors && @options[:allow_nil]) || (!found_errors && !@options[:allow_nil]))

      model.send "#{@attribute.to_s}=", '01/01/2102121'
      model.valid?
      errors = model.errors[@attribute]
      errors.any? { |error| error == I18n.t('activerecord.errors.messages.invalid_date') }
    end
    def failure_message
      "#{@model.class} failed to validate :#{@attribute} is valid date."
    end
  end
  def validate_date(attribute, options = {})
    Matcher.new(attribute, options)
  end
end
