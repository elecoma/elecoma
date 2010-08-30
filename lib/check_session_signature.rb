# -*- coding: utf-8 -*-

# CheckSessionSignature
module CheckSessionSignature
  ##　使い方:
  ##   include CheckSessionSignature
  
  def self.included(base)
    base.send :before_filter, :check_session_signature
  end
  
  def check_session_signature
    signature = Zlib.crc32([request.env['HTTP_USER_AGENT'].to_s,
                            request.env['HTTP_X_MSIM_USE'].to_s,
                            request.env['HTTP_X_UP_SUBNO'].to_s,
                            request.env['HTTP_X_JPHONE_UID'].to_s,
                            ].join('\1'))
    session[:_signature] ||= signature
    session_key = ActionController::Base.session_options.merge(request.session_options || {})[:key]
    if params[session_key] && session[:_signature] != signature
      logger.error('session hijack:%s from %s ' % [session.session_id, request.referer])
      reset_session
    end
    true
  end

end
