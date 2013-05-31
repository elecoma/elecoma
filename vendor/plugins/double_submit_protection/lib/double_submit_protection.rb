module Hervalicious
  module DoubleSubmitProtection

    DEFAULT_TOKEN_NAME = 'submit_token'

    module View
      def double_submit_token(token_name=nil)
        token_name ||= DEFAULT_TOKEN_NAME
        flash[token_name] = Digest::MD5.hexdigest(rand.to_s)
        hidden_field_tag(token_name, flash[token_name])
      end
    end

    module Controller
      def double_submit?(token_name=nil)
        token_name ||= DEFAULT_TOKEN_NAME
        token = flash[token_name]
        token.nil? || ( (request.post? || request.put?) && (token != params[token_name]) )
      end
    end
  end
end

