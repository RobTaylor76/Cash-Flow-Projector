require 'csv'
require 'digest/md5'

class DataImporter
  class << self

    def import_file(filename, headers_map, &block)
      csv_text = File.read(filename)
      csv = CSV.parse(csv_text, :headers => true)
      header_map  = map_headers(csv.headers, headers_map)
      csv.each do |row|
        import_data = {}
        header_map.each do |k,v|
          import_data[v] = row[k]
        end
        md5 = Digest::MD5.hexdigest(row.to_s)
        yield import_data, md5
      end
    end

    def upload_file(upload)
      random_name = SecureRandom.uuid
      directory = "public/data"
      # create the file path
      file_name = File.join(directory, random_name)
      # write the file
      File.open(file_name, "wb") { |f| f.write(upload['file'].read) }
      file_name
    end

    def remove_file(file_name)
#      File.delete("#{RAILS_ROOT}/dirname/#{@filename}") 
#                  if File.exist?("#{RAILS_ROOT}/dirname/#{@filename}")
      File.delete(file_name)
    end

    private
    def map_headers(file_headers, header_map)
      #  header_map = { 'Date' => 'Date',
      #              'Transaction Date' => 'Date',
      #              'Memo' => 'Reference',
      #              'Description' => 'Reference',
      #              'Amount' => 'Amount'}

      mapped_headers = {}
      file_headers.each do |header|
        next unless header_map.keys.include? header
        mapped_headers[header] = header_map[header]
      end

      mapped_headers
    end
  end
end

#Number,Date,Account,Amount,Subcategory,Memo
#Transaction Date,MCC,Description,Amount
#csv_text = File.read('virgin.csv')





