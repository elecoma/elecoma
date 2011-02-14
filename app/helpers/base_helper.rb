# -*- coding: utf-8 -*-
module BaseHelper

  def show_retailer_shop(product)
    if product.master_shop?
      return product.retailer.name
    else
      return link_to product.retailer.name, { :controller => :retailers, :action => "index", :id => product.retailer_id}
    end
  end

  def link_to_product(product, name=nil, options = {})
    product or return name
    name ||= h(product.name)
    if product.permit
      link_to name, {:controller => "/products", :action => "show", :id => product.id, :category_id => product.category_id}, options
    else
      name
    end
  end

  def link_to_product_image(product, size=:large)
    link_to_product(product, product_image_tag(product, size))
  end

  def link_to_category(category, type = "PC", image_flg=false)
    if type == "MOBILE"
      if params[:category_id] && params[:category_id].to_s == category.id.to_s
        return_str = h(category.name)
      else
        return_str = link_to h(category.name), :controller => "/products" ,:action => "index", :category_id => category.id
      end
    else
      if params[:category_id] && params[:category_id].to_s == category.id.to_s
        return_str = image_flg ? category_image_tag(category) : h(category.name)
      else
        return_str = link_to((image_flg ? category_image_tag(category) : h(category.name)), :controller => "/products" ,:action => "index", :category_id => category.id)
      end
    end
    return return_str
  end

  def link_to_campaign(name, dir_name, options={}, html_options={})
    options = {
      :controller=>'campaigns',
      :action=>'show',
      :dir_name=>dir_name
    }.merge(options)
    link_to(name, options, html_options)
  end

  def category_list_view(type = "PC", image_flg = false)
    id = params[:category_id] || 0
    return_array = []
    Category.find(:all, :conditions => ["parent_id is null"], :order => "position" ).each do |category|
     unless type == "MOBILE" && !category.get_child_category_ids.include?(id.to_i) && id != 0
         return_str = category_list_view_child(category, id, image_flg, type)
     end
      return_array <<   return_str unless return_str.blank?
    end
    if type == "MOBILE"
      return return_array.join("|")
    else
      return return_array.join
    end
  end

  def category_list_view_child(category, id, image_flg = false, type = "PC",  depth = 0)
    return "" unless category.product_count > 0
    return_str =""
    return_array = []
    if type == "MOBILE"
      return_str += link_to_category(category, type)
      return_str += ' '
    else
      return_str += "<li>"
      return_str += "　"*depth + "<img src='" + ActionController::Base.relative_url_root.to_s + "/images/common/list_ore_s.gif' width='4' height='5' alt='>' />　" unless image_flg
      return_str += link_to_category category, type, image_flg
      return_str += "</li>"
    end
    return_array << return_str
    if  category.get_child_category_ids.include?(id.to_i)
      if get_categories = Category.find(:all, :conditions => ["parent_id = ?", category.id], :order => "position")
        unless get_categories.blank?
           get_categories.each do |get_category|
          if (get_category.get_child_category_ids.include?(id.to_i) && type == "MOBILE") || get_category.parent_id == id.to_i || type == "PC"
             return_str = category_list_view_child(get_category, id, image_flg, type, depth + 1)
             return_array << return_str unless return_str.blank?
          end
         end
        end
      end
    end
    return return_array
  end

  def view_resource(resource, options={})
    return options[:alt] || '' if resource.nil?
    if resource
      view_resource_id(resource.id, options)
    else
      image_tag "/images/no_image.gif", options
    end
  end

  def view_resource_mobile(resource, options={})
    if request.mobile?
      width = request.mobile.display.width
      if width
        options[:width] = width - 10
      end
    end
    view_resource(resource, options)
  end

  def view_resource_id(resource_id, options = {})
    if resource_id && resource_id != 0
      if request.mobile?
        format = nil
        if request.mobile.instance_of?(Jpmobile::Mobile::Docomo)
          format = :gif
        elsif request.mobile.instance_of?(Jpmobile::Mobile::Au)
          format = :gif
        elsif request.mobile.instance_of?(Jpmobile::Mobile::Softbank)
          format = :png
        else
          format = :jpg
        end
        #image_tag url_for(:controller => "/image_resource", :action => "show", :id => resource_id, :format => format, :height => options[:height], :width => options[:width]), options
        image_tag url_for(:controller => "/image_resource", :action => "show", :id => resource_id, :format => format, :height => options[:height], :width => options[:width]), options.merge({:height => nil})
      else
        image_tag url_for(:controller => "/image_resource", :action => "show", :id => resource_id, :height=>options[:height], :width=>options[:width]), options
      end
    elsif resource_id == 0
      ""
    else
      image_tag "/images/no_image.gif", options
    end
  end

  #  * INFO お届け先の追加・変更時に開くサブウィンドウ制御用のJavaScriptTagを生成。
  def popup_for_delivery_address_script
    js = <<"EJS"
      function popdelivery(URL,Winname,Wwidth,Wheight){
        var WIN;
        WIN = window.open(URL,Winname,"width="+Wwidth+",height="+Wheight+",scrollbars=yes,resizable=yes,toolbar=no,location=no,directories=no,status=no");
        WIN.focus();
      }
      Event.observe(window, 'load', function() {
        $$('.delivery_edit').each(function(link) {
          Event.observe(link, 'click', function(e) {
            var url = e.target.href;
            popdelivery(url, 'update_deliv', 600, 640);
            e.stop();
          });
        });
      });
EJS
    javascript_tag js
  end

  #  * INFO お届け先の追加・変更時にサブウィンドウを閉じるためのJavaScriptTagを生成。
  def closer_for_delivery_address_script
    js = <<"EJS"
      function checkDelivAddress() {
      var ua = navigator.userAgent;
      if( !!window.opener ) {
        if( ua.indexOf('MSIE 4')!=-1 && ua.indexOf('Win')!=-1 ) {
          return !window.opener.closed;
        } else {
          return typeof window.opener.document == 'object';
        }
      } else {
        return false;
      }
    }

    function closeDeliveryAddress(url){
      if(checkDelivAddress()){
        window.opener.location.href = url;
      }else{
        window.close();
      }
    }
EJS
    javascript_tag js
  end

  #  * INFO 追加お届け先が20件未満の場合、お届け先追加アクション用のリンクを生成する
  def link_to_create_address(str = '新規登録')
    @address_size < DeliveryAddress::MAXIMUM_POSITION or return nil
    link_to(str, {:controller => :accounts, :action => :delivery_new_popup}, :class => 'delivery_edit')
    #    link_to_function(str, "popdelivery('/account/delivery_new_popup', 'create_deliv', '600', '640')") if @address_size < DeliveryAddress::MAXIMUM_POSITION
  end

  #  * INFO 会員の場合は hidden_field に会員IDを埋め込む。
  def hidden_address_customer_id
    hidden_field_tag('address[customer_id]', @login_customer.id) if @login_customer
  end

  def confirm_select(nomal, confirm, object_name)
    if params[:action] =~ /confirm/  || params[:action] =~ /create/|| params[:action] =~ /update/
      if (object = self.instance_variable_get("@#{object_name}")) && object.errors.empty?
        return confirm
      end
    end
    return nomal
  end

  def image_field(*args)
    return_str = ""
    return_str = send(:file_field, *args)
    return_str += "<br>"
    object_name, method_name = args[0].to_s.dup, args[1].to_s.dup
    object = self.instance_variable_get("@#{object_name}")
    resource_id = object.send "#{method_name}_id"
    if resource_id
      return_str += "<div id=\"#{object_name}_#{method_name}_old_file\">"
      return_str += view_resource_id resource_id
      return_str += hidden_field_tag "#{object_name}_#{method_name}_old_id", resource_id
      return_str += link_to_function "この画像を削除する", "document.getElementById(\"#{object_name}_#{method_name}_old_file\").style.display = 'none';document.getElementById(\"#{object_name}_#{method_name}_old_id\").value=0"
      return_str += "</div>"
    end
    return return_str
  end

  def confirm_tag(*args)
    if params[:action] =~ /confirm/  || params[:action] =~ /create/ || params[:action] =~ /update/
      if args.size >= 3
        object_name, method_name = args[1].to_s.dup, args[2].to_s.dup
        object_name.sub!(/\[\]$/,"")
        if (object = self.instance_variable_get("@#{object_name}")) && object.errors.empty?
          if method_name =~ /_resource$/
            return  view_resource_id( object.send("#{method_name}_id"))
          else
            if method_name == "permit"
              return object.send("permit_label")
            elsif method_name == "category_id"
              return h(object.category_name)
            else
              method = object.send(method_name)
              if method.class == ActiveSupport::TimeWithZone
                return  h_br( method.strftime("%Y年%m月%d日"))
              else
                return  h_br( method )
              end
            end
          end
        else
          return send(*args)
        end
      else
        return nil
      end
    end
    return send(*args)
  end

  #商品画像を出すimage_tag
  def product_image_tag(product, type=:large, options={})
    return nil if product.nil?
    options = ({
      :alt => product.name
    }).merge(options)
    id = nil
    case type
    when :large
      id = product.large_resource_id
    when :medium
      id = product.medium_resource_id
    when :small
      id = product.small_resource_id
      options = ({:width=>120}).merge(options)
    end
    if id
      view_resource_id(id, options)
    else
      ''
    end
  end

  def payment_image_tag(payment, options={})
    return nil if payment.nil?
    options = ({
      :alt => payment.name
    }).merge(options)
    id = payment.resource_id
    if id
      view_resource_id(id, options)
    else
      ''
    end
  end

  def sub_product_image_tag(sub_product, options={})
    return nil if sub_product.nil?
    options = ({
#      :alt => payment.name
    }).merge(options)
    id = sub_product.medium_resource_id
    if id
      view_resource_id(id, options)
    else
      ''
    end
  end

  def column_name(model,column,astarisk = false)
    if object = self.instance_variable_get("@#{model}")
      "<th>#{object.class.field_names[column]}#{astarisk ? " <font color=\"red\">*</font>" : ""}</th>"
    else
      ""
    end
  end

  def column_confirm_tag(method, model, column, *args)
    if object = self.instance_variable_get("@#{model}")
      "<tr>#{ column_name(model, column) }<td>#{confirm_tag(method, model, column, *args)}</td></tr>"
    else
      ""
    end
  end

=begin rdoc
  <select>
   <option value="x">食料</option>
   <option value="x">>和食</option>
   <option value="x">>>たくあん</option>
   <option value="x">>洋食</option>
   <option value="x">>>オムレツ</option>
   <option value="x">衣料</option>
  </select>
  という感じです。
=end
def category_select(object, method, options={}, html_options={})
  select object, method, category_options, options, html_options
end

def category_options(include_blank=false)
  category_options_internal(Category.find_as_nested_array)
end

def category_options_internal(tree, indent='')
  tree.inject([]) do |array, item|
    if item.instance_of? Category
      array << ['%s%s' % [indent, item.name], item.id.to_s]
    else
      array += category_options_internal(item, indent + '>')
    end
  end
end

def number_field(object_name, method, options = {})
  class_name = 'number'
  options[:class].blank? or class_name += ' ' + options[:class]
  text_field(object_name, method, options.merge(:class=>class_name))
end

def product_category_image_tag(product)
  category_image_tag(product && product.category)
end

def category_image_tag(category)
  default = image_tag('title_cat00.jpg', :alt=>"カテゴリー")
  category or return default
  category.resource_id.blank? and return default
  view_resource_id(category.menu_resource_id, :alt=>category.name)
end

def each_product_styles(product)
  product or return
  style_categories1 = []
  style_categories2 = []
  product.product_styles.each do |ps|
    style_categories1 << ps.style_category1 if ps.style_category1
    style_categories2 << ps.style_category2 if ps.style_category2
  end
  style_categories1 = style_categories1.uniq
  style_categories2 = style_categories2.uniq
  all = [[product.style1, style_categories1, 1],
    [product.style2, style_categories2, 2]]
  all.each do |style,style_categories,index|
    if style && !style_categories.empty?
      yield style,style_categories,index
    end
  end
end

def image_tag_mobile(prefix, options={})
  width = request.mobile.display.width if request.mobile and request.mobile.display
  width = options[:width] if options[:width]
  size = 'q' # q = QVGA, v = VGA
  size = 'v' if !width.blank? && width.to_i >= 480
  format = 'gif'
  #キャリア毎に変更するなら以下を利用する（今は使わないのでコメントアウト
  #format = 'gif' if request.mobile.is_a?(Jpmobile::Mobile::Docomo)
  #format = 'gif' if request.mobile.is_a?(Jpmobile::Mobile::Au)
  #format = 'gif' if request.mobile.is_a?(Jpmobile::Mobile::Softbank)
  image_tag("/images/mobile/%s_%s.%s" % [prefix, size, format], options)
end

def link_to_mobile(name, options = {}, html_options = nil)
  if html_options and html_options[:accesskey]
    accesskey = html_options[:accesskey].to_i
    accesskey = 0 if accesskey < 0
    accesskey = 9 if accesskey > 9
    h = {
      1 => '&#xe6e2;',
      2 => '&#xe6e3;',
      3 => '&#xe6e4;',
      4 => '&#xe6e5;',
      5 => '&#xe6e6;',
      6 => '&#xe6e7;',
      7 => '&#xe6e8;',
      8 => '&#xe6e9;',
      9 => '&#xe6ea;',
      0 => '&#xe6eb;',
    }
    if request.mobile.is_a?(Jpmobile::Mobile::Softbank)
      h = {
        1 => '$F<',
        2 => '$F=',
        3 => '$F>',
        4 => '$F?',
        5 => '$F@',
        6 => '$FA',
        7 => '$FB',
        8 => '$FC',
        9 => '$FD',
        0 => '$FE',
      }
    end
    h[accesskey] + link_to(name, options, html_options)
  else
    link_to(name, options, html_options)
  end
end

def compound_title_tag(parts, options={})
  title = parts.reject(&:nil?).join(options.delete(:delimiter) || ' - ')
  content_tag('title', h(title), options)
end

#KBMJのASPサービスであるパーソナライズド・レコメンダー用のロジックです
def recommend_beacon(ids)
  unless ids.is_a?(Array)
    ids = [ids]
  end
  query = {:k=>'dummy_id', :id=>ids}.to_param  #TODO:dummy_idにレコメンド用ビーコンIDを設定して下さい。
  url = request.protocol + 'recommend.kbmj.com/bcon/heavier/?' + query
  image_tag(url, :width=>1, :height=>1, :alt=>'')
end

def link_to_new_information(new_information, options={}, html_options={})
  name = options.delete(:body) || new_information.body
  return name if new_information.url.blank?
  url = new_information.url
  html_options = {
    :target => "_blank"
  }.merge(html_options) if new_information.new_window
  u = URI.parse(url)
  if request.host == u.host
    path = u.path
    params = ActionController::Routing::Routes.recognize_path(path)
    url = url_for(params.merge(options)) + (u.query ? "?"+u.query : "")
  end
  link_to(name, url, html_options)
end

    # 携帯各キャリアの入力モード指定用のハッシュを取得
    # DoCoMo：style="-wap-input-format:…;"
    # au : format="…"
    # Softbank : mode="…"
    # Softbankのmode指定
    # (hankakukana, alphabet, numeric)
    # をシンボルで引数に渡す
    def mobile_input_mode(mode)
      istyle_hash = {"K" => 2, "E" => 3, "N" => 4}
      hash = {
        :hankakukana => {
          :docomo   => {:istyle => istyle_hash["K"],
            :style => "-wap-input-format:&quot;*&lt;ja:hk&gt;&quot;"},
          :au       => {:istyle => istyle_hash["K"],
            :format => "*M"},
          :softbank => {:istyle => istyle_hash["K"],
            :mode => "hankakukana"},
        },
        :alphabet => {
          :docomo   => {:istyle => istyle_hash["E"],
            :style => "-wap-input-format:&quot;*&lt;ja:en&gt;&quot;"},
          :au       => {:istyle => istyle_hash["E"],
            :format => "*m"},
          :softbank => {:istyle => istyle_hash["E"],
            :mode => "alphabet"},
        },
        :numeric => {
          :docomo   => {:istyle => istyle_hash["N"],
            :style => "-wap-input-format:&quot;*&lt;ja:n&gt;&quot;"},
          :au       => {:istyle => istyle_hash["N"],
            :format => "*N"},
          :softbank => {:istyle => istyle_hash["N"],
            :mode => "numeric"},
        },
      }
      mode = mode.to_sym
      hash[mode][mobile_carrer_type] || {}
    end

    def mobile_carrer_type
      case request.mobile
        when Jpmobile::Mobile::Docomo
        :docomo
        when Jpmobile::Mobile::Au
        :au
        when Jpmobile::Mobile::Softbank
        :softbank
      end
    end
end

