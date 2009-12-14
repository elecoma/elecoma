# CSRF 対策

module ActionView::Helpers
  module TagHelper
    def tag_with_security_token(name, *args)
      if name.to_sym == :form && @form_tag_add_security_token
        tag_without_security_token(name, *args) + hidden_field_tag("_session_token", session_token)
      else
        tag_without_security_token(name, *args)
      end
    end

    alias_method_chain :tag, :security_token
  end

  module FormTagHelper
    def form_tag_with_security_token(url_for_options = {}, options = {}, *parameters_for_url, &proc)
      if (options[:method].nil? || /^post$/i =~ options[:method].to_s) && false != options.delete(:security_token)
        begin
          @form_tag_add_security_token = true
          form_tag_without_security_token(url_for_options, options, *parameters_for_url, &proc)
        ensure
          @form_tag_add_security_token = nil
        end
      else
        form_tag_without_security_token(url_for_options, options, *parameters_for_url, &proc)
      end
    end
    
    alias_method_chain :form_tag, :security_token
    alias_method :start_form_tag, :form_tag
  end
end

module ActionView::Helpers::UrlHelper
  def method_javascript_function_with_session_token(method, url='', href=nil)
    f = method_javascript_function_without_session_token(method, url='', href=nil)
    if method.to_sym == :post
      token_func = "var t = document.createElement('input'); t.type='hidden'; t.name='_session_token'; t.value='#{session_token}'; "
      f.sub!(/f.submit\(\)/, 'f.appendChild(t); \&') || raise("substitution failed")
      token_func << f
      token_func
    else
      f
    end
  end

  alias_method_chain :method_javascript_function, :session_token

  def button_to_with_session_token(*args)
    button_to_without_session_token(*args).sub(/<\/form>$/, 
                                               "#{hidden_field_tag('_session_token', session_token)}</form>")
  end
  
  alias_method_chain :button_to, :session_token
end

class ActionController::Base
  def session_token
    session[:session_token] ||= Digest::MD5.hexdigest("#{session.session_id}#{rand}")
  end

  def verify_session_token
    if request.post? &&
        !request.xhr? &&
        !(::ActionController.const_defined?("TestRequest") && request.is_a?(::ActionController::TestRequest))
      if session_token == params["_session_token"]
        return true
      else
        render :text => 'errors/forbidden', :status => 403, :layout => false
        return false
      end
    end
    true
  end

  helper_method :session_token
end
