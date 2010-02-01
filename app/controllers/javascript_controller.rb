class JavascriptController < ApplicationController
  caches_page :application
  after_filter {|c| c.headers["Content-Type"] = 'application/javascript' }
  def application
  end

  def thickbox
  end

  def treemenu
  end
end
