class LedgerEntryDecorator

  def initialize(entry)
    @entry = entry
  end

  def self.build_collection(entries)
    entries.includes(:financial_transaction,:analysis_code).map {|entry| LedgerEntryDecorator.new(entry)}
  end

  def date
    I18n.l(@entry.date)
  end

  def debit
    format_number(@entry.debit)
  end

  def credit
    format_number(@entry.credit)
  end

  def reference
    @entry.financial_transaction.reference
  end

  def analysis_code
    if @entry.analysis_code.present?
      @entry.analysis_code.name
    else
      ''
    end
  end

  def format_number(value)
    '%.2f' % value
  end

  def method_missing(method_name, *args, &block)
    @entry.send(method_name, *args, &block)
  end

  def respond_to_missing?(method_name, include_private = false)
    @entry.respond_to?(method_name, include_private) || super
  end
end
