# -*- coding: utf-8 -*-
module ActionController
  class Request
    private

    def normalize_parameters_with_force_encoding(value)
      result = normalize_parameters_without_force_encoding(value)
      result.force_encoding(Encoding.default_external) if result.respond_to? :force_encoding
      result
    end

    alias_method_chain :normalize_parameters, :force_encoding
  end
end
