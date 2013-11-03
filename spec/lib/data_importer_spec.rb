require 'spec_helper'

describe DataImporter do


  it 'yields the mapped fields from the file to the give block' do
    header_map = {'Header A' => :header_a, 'Header D' => :header_d}

    csv_text = File.read('spec/data/test_import.csv')
    import_data = []
    DataImporter.import_file(csv_text, header_map) do |row_data, md5|
      import_data << row_data
    end
    import_data.size.should == 4
    import_data.each_with_index do |row_data, index|
      row_data.keys.should == [:header_a, :header_d]
      row_data[:header_a].should == "#{index} A"
      row_data[:header_d].should == "#{index} D"
    end
  end

end
