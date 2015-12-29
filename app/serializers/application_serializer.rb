class ApplicationSerializer < ActiveModel::Serializer
  def attributes(*args)
    super.transform_values do |value|
      value = value.iso8601 if value.respond_to?(:iso8601)
      value
    end
  end
end
