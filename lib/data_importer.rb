require 'csv'
require 'digest/md5'

class DataImporter
  class << self

    def import_file(csv_text, headers_map, &block)
      csv = CSV.parse(sanitise_csv(csv_text), :headers => true)
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
    def sanitise_csv(csv_text)
      unless csv_text.encoding == Encoding::UTF_8
        csv_text.force_encoding(Encoding::ISO_8859_1)
        csv_text.encode!(Encoding::UTF_8)
      end
      csv_text.squeeze(' ')
    end

    def map_headers(file_headers, header_map)

      mapped_headers = {}
      file_headers.each do |header|
        next unless header_map.keys.include? header
        mapped_headers[header] = header_map[header]
      end
      mapped_headers
    end
  end
end
