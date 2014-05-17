# Throws an exception instead of producing a missing translation message
#
# http://stackoverflow.com/questions/8066901/rails-how-to-treat-locale-translation-missing-as-error-during-test
class FailFastTranslationExceptionHandler
  def call(exception, _, _, _)
    if exception.is_a?(I18n::MissingTranslation)
      raise exception.message
    elsif exception.is_a?(Exception)
      raise exception
    else
      throw :exception, exception
    end
  end
end