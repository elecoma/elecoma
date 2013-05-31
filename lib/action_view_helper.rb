# -*- coding: utf-8 -*-
module ActionView
  module Helpers
    module DateHelper
      alias_method :select_year_without_suffix, :select_year
      alias_method :select_month_without_suffix, :select_month
      alias_method :select_day_without_suffix, :select_day
      
      def select_year(date, options = {}, html_options = {})
        select_year_without_suffix(date, options) + " 年 "
      end

      def select_month(date, options = {}, html_options = {})
        select_month_without_suffix(date, options) + " 月 "
      end

      def select_day(date, options = {}, html_options = {})
        select_day_without_suffix(date, options) + " 日 "
      end
    end
    module JavaScriptHelper

=begin rdoc
  *INFO
    JavaScriptのアクション起動用のチェックボックスタグを生成する
    引数として、JavaSctiptの関数名か、ブロックで実行内容を指定できる
    挙動は link_to_functionと同等のものを基準としている

    parametors:
      :function => String[必須ではない][デフォルト値: '']
      :name => String[必須]
      :value => String[必須ではない][デフォルト値: "1"]
      :checked => Boolean[必須ではない][デフォルト値: false]
      :options => Hash[必須ではない][デフォルト値: {}]
      :block => BlockParametor[必須ではない][デフォルト値: nil]

    return:
      <input type="checkbox" value="1" onClick="function(); return false;" />というようなHTMLタグを生成する
=end
      def checkbox_to_function(function, name, value = "1", checked = false, options = {}, &block)
        function = function || ''
        function = update_page(&block) if block_given?
        html_options = { "type" => "checkbox", "name" => name, "id" => name, "value" => value }.update(options.stringify_keys)
        html_options["checked"] = "checked" if checked

        function = update_page(&block) if block_given?
        tag :input, html_options.merge({:onclick => (html_options[:onclick] ? "#{html_options[:onclick]}; " : "") + "#{function}; return false;"})
      end
    end

    module FormOptionsHelper
      def constants_select(object, method, key, options={}, html_options={})
        collection_select(object, method, Constant.list(key), :value, :value, options, html_options)
      end

      def constant_options(key, selected=nil)
        options_for_select(Constant.list_for_options(key), selected)
      end
    end

    class FormBuilder
      def constants_select(method, key, options={}, html_options={})
        @template.collection_select(@object_name, method, key, options, html_options)
      end
      def category_select(method, options={}, html_options={})
        @template.category_select(@object_name, method, options, html_options)
      end
      def number_field(method, options={})
        @template.number_field(@object_name, method, options)
      end
      def birthday_select(method, options={}, html_options={})
        @template.birthday_select(@object_name, method, options, html_options)
      end
    end
  end
end
