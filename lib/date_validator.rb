module DateValidator

    def validates_date(*attrs)

      options = attrs.extract_options!

      validates_each attrs do |record, attr, date|
        next if date.nil? && options[:allow_nil]
        if date.nil?
          record.errors.add(attr, I18n.t('activerecord.errors.messages.invalid_date'))
          next
        end

        case date
        when String
          if date.length > 10 || ((Date.parse(date) rescue ArgumentError) == ArgumentError)
            record.errors.add(attr, I18n.t('activerecord.errors.messages.invalid_date'))
          end
        else
          if date.year > 2299 || date.year < 1976
            record.errors.add(attr, I18n.t('activerecord.errors.messages.invalid_date'))
          end
        end
      end

    end
end
