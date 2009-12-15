require 'pp'
require 'drb'

class Admin::MailMagazinesController < Admin::BaseController
  resource_controller
  before_filter :admin_permission_check_sending, :expect => :history
  before_filter :admin_permission_check_sending_log, :only => :history

  cattr_accessor :drb_uri
  DEFAULT_DRB_URI = 'druby://0.0.0.0:9999'
#  DEFAULT_DRB_URI = 'druby://mail4.kbmj.com'

  emoticon_filter

  index.before do
    @condition = MailMagazineSearchForm.new({})
  end

  def search
    @condition = MailMagazineSearchForm.new(params[:condition])
    if params[:on_form] == 'true'
      session[:except_list] = nil
    end

    unless @condition.valid?
      render :action => 'index'
      return
    end
    session[:condition_save] = @condition
    sql_condition, conditions = MailMagazine.get_sql_condition(@condition)
    sql = MailMagazine.get_sql_select + sql_condition
    sqls = [sql]
    conditions.each do |c|
      sqls << c
    end
    #@customers = Customer.paginate_by_sql(MailMagazine.get_sql_select + MailMagazine.get_sql_condition(@condition),
    @customers = Customer.paginate_by_sql(sqls,
      :page => params[:page],
      :per_page => @condition.search_par_page,
      :order => "id")

    #all_customers = Customer.find_by_sql(MailMagazine.get_sql_select + MailMagazine.get_sql_condition(@condition))
    all_customers = Customer.find_by_sql(sqls)

    @check_all = true
    customer_ids = []
    if !all_customers.blank?
      all_customers.each do |r|
        if !session[:except_list].blank? && session[:except_list].include?(r.id.to_s)
          r.excepted = true
          #画面で表示するのは@customersですので、除外ボックスもセットする
          if !@customers.blank?
            @customers.each do |c|
              if c.id == r.id
                c.excepted = true
                break
              end
            end
          end
        else
          @check_all = false
          r.excepted = false
        end
        customer_ids << r.id
      end
      @customer_ids = customer_ids.join(",")
    end
  end

  def except_customer
    except_list = session[:except_list] ||= []
    if params[:checked] == 'true'
      unless except_list.include?(params[:id])
        except_list << params[:id]
      end
    else
      except_list.delete(params[:id])
    end
    session[:except_list] = except_list
    render :nothing => true
  end

  def except_customers
    except_list = session[:except_list] ||= []
    excepts = params[:customer_ids].blank? ? [] : params[:customer_ids].split(",")
    if params[:checked] == 'true' && !excepts.blank?
      if except_list.size == 0
        except_list << excepts
        except_list.flatten!
      else
        excepts.each do |id|
          unless except_list.include?(id)
            except_list << id
          end
        end
      end
    elsif except_list.size > 0 && !excepts.blank?
      excepts.each do |id|
        except_list.delete(id)
      end
    end
    session[:except_list] = except_list
    render :nothing => true
  end

  def template_search
    @contents = MailMagazineContentsForm.new(params[:contents])
    @customer_ids = params[:customer_ids]
  end

  def template_re_search
    @contents = MailMagazineContentsForm.new(params[:contents])
    @contents.template_id = id = params[:template_id]
    if id.blank?
      @contents.attributes = {:form_type=>"", :subject=>"", :body=>""}
    else
      template = MailMagazineTemplate.find(id, :select => "id,form,subject,body")
      @contents.attributes = {:form_type=>template.form,
                              :subject=>template.subject,
                              :body=>template.body}
    end

    render :partial => "mail_contents"
  end

  def confirm
    @contents = MailMagazineContentsForm.new(params[:contents])
    @contents.body = hidden_tag_check(@contents.body)
    @customer_ids = params[:customer_ids]
    unless @contents.valid?
      render :action => 'template_search'
      return
    end
  end

  #隠れているタグを取り除く
  def hidden_tag_check(body)
    check = body.sub(/<(.*)>/, "")
    if check.blank?
      return check
    else
      return body
    end
  end

  def complete
    @condition = session[:condition_save]
    except_list = session[:except_list] ||= []
    if @condition.blank?
      redirect_to :ation => "index"
    end
    condition_data = MailMagazineCondition.new(@condition).to_yaml
    sql_condition, conditions = MailMagazine.get_sql_condition(@condition, except_list)
    sql = MailMagazine.get_sql_select + sql_condition
    sqls = [sql]
    conditions.each do |c|
      sqls << c
    end
    #@customers = Customer.find_by_sql(MailMagazine.get_sql_select + MailMagazine.get_sql_condition(@condition, except_list))
    @customers = Customer.find_by_sql(sqls)

    @contents = MailMagazineContentsForm.new(params[:contents])
    mm = MailMagazine.new
    mm.subject = @contents.subject
    mm.body = @contents.body
    mm.condition = condition_data
    mm.schedule_case = @customers.size
    mm.delivered_case = 0
    mm.sent_start_at = Time.now

    unless mm.save
      flash[:magazine_e] = "保存に失敗しました"
      redirect_to :action => 'index'
      return
    end

    #customer_ids = params[:customer_ids].split(/\s*,\s*/)
    ids_int = []
    @customers.each do |c|
      ids_int << c.id.to_i
    end
    customers = Customer.find_all_by_id(ids_int)

    #メール送信
    begin
      delivered_case = deliver_mail(customers, @contents)
    rescue =>e
      logger.error(e.message)
      e.backtrace.each{|s|logger.error(s)}
      flash[:magazine_e] = "メールの送信に失敗しました"
      redirect_to :action => 'index'
      return
    end

    mm.delivered_case = delivered_case
    mm.sent_end_at = Time.now
    if mm.save
      flash[:magazine] = "保存しました"
    else
      flash[:magazine_e] = "保存に失敗しました"
      redirect_to :action => 'index'
      return
    end


    session[:condition_save] = nil
    redirect_to :action => "history"
  end

  def history
    @histories = MailMagazine.paginate(
      :page => params[:page],
      :per_page => 20,
      :order => "updated_at DESC")
  end

  def preview
    mm = MailMagazine.find(params[:id])
    @subject = mm.subject
    @body = mm.body.gsub(/\n/,'<br/>') if mm.body
    render :layout=>false
  end

  def condition_view
    mm = MailMagazine.find(params[:id])
    @condition = {}
    if mm && mm.condition
      @condition = YAML.load(mm.condition)
    end
    render :layout => false
  end

  destroy.wants.html do
    redirect_to :action => "history"
  end

  private
  class MailMagazineCondition
    attr_accessor :customer_name_kanji, :customer_name_kana, :prefecture_id, :tel_no
    attr_accessor :sex_male, :sex_female, :birth_month, :form_type
    attr_accessor :order_count_up, :order_count_down, :product_code
    attr_accessor :total_up, :total_down, :email, :mail_type
    attr_accessor :occupation_id, :birthday_from, :birthday_to
    attr_accessor :updated_at_from, :updated_at_to
    attr_accessor :last_order_from, :last_order_to
    attr_accessor :category_id, :product_name, :campaign_id

    def initialize(c)
      c.attributes.each do |k,v|
        if respond_to? k + "="
          if k =~ /_from$/ || k =~ /_to$/
            if !v.blank?
              send(k + "=", v.strftime("%Y-%m-%d %H:%M:%S"))
            end
          else
            send(k + "=", v)
          end
        end
      end
    end
  end

  def deliver_mail(customers, contents)
    customers.blank? and return 0
    delivered_case = 0
    drb = DRb::DRbObject.new_with_uri(@@drb_uri||DEFAULT_DRB_URI)
    customers.each do |c|
      if contents.form_type.to_i == MailMagazineTemplate::TEXT
        mail = Notifier::create_text_mailmagazine(c, contents.body, contents.subject)
      else
        #mail = Notifier::create_html_mailmagazine(c, contents.body, contents.subject)
        mail = MobileHtmlNotifier::create_html_mailmagazine(c, contents.body, contents.subject)
      end
      begin
        timeout(1) do
          drb.add(mail)
          delivered_case += 1
        end
      end
    end #customers.each
    delivered_case
  end
end
