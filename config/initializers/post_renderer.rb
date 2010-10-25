class PostRenderer < WillPaginate::LinkRenderer
  
  def page_link(page, text, attributes = {})
    attributes.merge!({:method => :post})
    @template.link_to text, url_for(page), attributes
  end

end
