module Filterable
  extend ActiveSupport::Concern

  module ClassMethods
    def filter(params)
      result = self.where(nil)
      params.each do |key, value|
        result = self.public_send("find_by", {"#{key}": value}) if key.present?
      end
      result
    end
  end
end
