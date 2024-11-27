class DomainValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /^[a-z]*$/
      record.errors[attribute] << (options[:message] || "không đúng định dạng")
    end
  end
end