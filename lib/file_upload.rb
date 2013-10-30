class FileUpload
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :upload_file

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
end

