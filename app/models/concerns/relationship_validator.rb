module RelationshipValidator
  extend ActiveSupport::Concern

  module ClassMethods
    def validates_relationship(*attrs)
      options = attrs.extract_options!

      validates_each attrs do |record, attr, attr_value|
        if attr_value.present?
          unless record.user.present? && record.send(options[:valid_values]).include?(attr_value)
            record.errors.add(:base, I18n.t('errors.security.invalid_lookup_id'))
          end
        end
      end
    end
  end
  private

  def valid_ledger_accounts
    user.ledger_accounts.pluck(:id)
  end

  def valid_analysis_codes
    user.analysis_codes.pluck(:id)
  end
end
