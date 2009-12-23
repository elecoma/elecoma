class Admin::BaseController < ApplicationController
  before_filter :load_system
  before_filter :load_admin
  before_filter :admin_login_check

  layout 'admin/base'
  #バリデーションエラーの時、レイアウトが崩れる対応
  ActionView::Base.field_error_proc = Proc.new{ |snippet,
  instance| "<span class=\"error\">#{snippet}</span>"
  }
  def up
    get_model(params[:model])
    @record = @model.find_by_id(params[:id])
    @record.move_higher
    @record.save
  end

  def down
    get_model(params[:model])
    @record = @model.find_by_id(params[:id])
    @record.move_lower
    @record.save
  end

  def change_position
    get_model
    @record = @model.find_by_id(params[:id])
    @record.insert_at(params[:position])
    @record.save
  end

  private

  def get_model(model_name = nil)
    @model_name = ""
    @model_name = $1 if self.class.to_s =~ /Admin::(.*)sController/
    @model_name = model_name || $1 if self.class.to_s =~ /Admin::(.*)Controller/
    @model_name = model_name || @model_name if defined? model_name
    @model_name = params[:model] || @model_name
    @model = eval @model_name.classify
  end

  #管理側ユーザーのログインフィルター
  def load_admin
    @login_admin = AdminUser.find(:first, :conditions=>["id=?", session[:admin_user]["id"]]) if session[:admin_user]
  end

  #管理側ユーザーのログインチェック
  def admin_login_check
    @login_check_error = false
    unless session[:admin_user]
      session[:return_to_admin] = params if params
      redirect_to(:controller => 'admin/accounts', :action => 'login')
      return false
    end
  end

  #管理側ユーザーの処理実行権限チェック
  Function.find(:all).each do |rec|
    name = "admin_permission_check_" + rec.code
    define_method(name.to_sym) do
      current_user = session[:admin_user]
      current_controller_name = params[:controller]
      current_action_name = params[:action]

      unless Authority.find(:first,
       :conditions => ["authorities.id=? and functions.id=?", current_user.authority_id, rec.id],
       :include=> :functions)

        flash[:notice] = "該当機能にアクセスする権限がありません"
        redirect_to :controller => "home", :action => "index"
        return false
      end
    end
  end

  # 例外発生時、public/admin/#{status_code}.html を表示
  def render_optional_error_file(status_code)
    status = interpret_status(status_code)
    num = status[0,3]
    root = Pathname.new(Rails.public_path)
    filename = '%s.html' % num
    path = root.join('admin', filename) # public/admin/xxx.html
    path.exist? or path = root.join(filename) # public/xxx.html
    if path.exist?
      render :file => path.to_s, :status => status
    else
      head status
    end
  end

  def get_conditions(model_name = nil)
    get_model(model_name)
    @year = Hash.new
    @month = Hash.new
    @day = Hash.new
    @search_list = []
    if params[:search]
      hash = SearchForm.new(params[:search]).attributes
      params[:search].find_all{|k,v| k.include?('.')}.each do |k,v|
        hash[k] = v
      end
      hash.each do | column, value |
        if column =~ /^(search_)?(.*)(_from|_to)(.*)/
          column = $2
          status = $3
          date = $4
        end
        model = @model
        # カラム名に . が含まれるならテーブル名付きで検索
        if column.include?(?.)
          table, column = column.split('.')
          ActiveRecord::Base.connection.table_exists?(table) or next
          model = Object.const_get(table.classify)
        else
          model.columns_hash.include? column or next
        end
        full_name = "%s.%s" % [model.table_name, column]

        op = "="
        if status == "_from"
          op = ">="
        elsif status == "_to"
          op = "<="
        end
        case model.columns_hash[column].type.to_s
        when "integer"
          @search_list << ["#{full_name} #{op} ?", value.to_i] unless value.blank?
        when "boolean"
          @search_list << ["#{full_name} #{op} ?", value] unless value.blank?
        when "string", "text"
          if op == "="
            @search_list << ilike_conditions(full_name, value) unless value.blank?
          else
            @search_list << ["#{full_name} #{op} ?", value] unless value.blank?
          end
        when "datetime", "date"
          key = column+status
          if date == "(1i)"
            @year[key] = value
          elsif date == "(2i)"
            @month[key] = value
          elsif date == "(3i)"
            @day[key] = value
          end

          time = nil
          if !@year[key].blank? && !@month[key].blank? && !@day[key].blank?
            time = Time.zone.local(@year[key].to_i, @month[key].to_i, @day[key].to_i)
          elsif [Date, Time].any?{|c| value.is_a?(c)}
            time = value
          elsif date.empty? # search[:foo]='1900-01-01 00:00:00' みたいに来た場合
            time = Time.zone.parse(value) # 失敗したときは nil になる
          end


          if time && status == "_from"
            @search_list << ["#{full_name} >= ?", time]
          elsif time && status == "_to"
            @search_list << ["#{full_name} < ?", time+(1.day)]
          end
        end
      end
    end
  end

end
