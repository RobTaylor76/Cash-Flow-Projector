class BankAccountImport
  class << self

    def process_statement(bank_account, csv_text)
      DataImporter.import_file(csv_text, header_map) do |row_data, md5|
        puts row_data, md5
      end
    end

    def header_map
      { 'Date' => 'Date',
        'Transaction Date' => 'Date',
        'Memo' => 'Reference',
        'Description' => 'Reference',
        'Amount' => 'Amount'}
    end
  end
end
