module Admin::HomeHelper
  def sold_outs(product_styles)
    if product_styles.blank?
      return "なし"
    end
    html = ""
    (product_styles || []).each_with_index do |product_style,index|
      if index >= 10
        break
      end
      html << h(product_style.code) << "：" << h(product_style.name) << "<br/>"
    end
    html
  end
  
  def sold_out_counts(product_styles)
    unless product_styles.blank?
      "総数：&nbsp;" << product_styles.size.to_s << "&nbsp;品目"
    end
  end
end
