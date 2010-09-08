class JavascriptController < ApplicationController
  caches_page :application
  ssl_allowed :application, :thickbox, :treemenu
  after_filter {|c| c.headers["Content-Type"] = 'application/javascript' }
  def application
  end

  def thickbox
  end

  def treemenu
  end
end
