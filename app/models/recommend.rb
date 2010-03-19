# -*- coding: utf-8 -*-
require 'open-uri'
require 'rexml/document'
require 'timeout'

#以下はKBMJのASPサービスであるパーソナライズド・レコメンダー用のロジックです
class Recommend < ActiveRecord::Base

  TYPE_BUY, TYPE_VIEW = 0, 1

  #XML連携用レコメンドURL
  RECOMMEND_URLS = {
    TYPE_BUY => "RECOMMEND_BUY_URL", #購入履歴用のURLを設定して下さい(&id[]= まで)
    TYPE_VIEW => "RECOMMEND_VIEW_URL", #閲覧履歴用のURLを設定して下さい(&id[]= まで)
  }
  RANKING_URL = "RECOMMEND_RANKING_URL" #ランキング用のURLを設定して下さい(team=w まで)

  def self.recommend_get(product_id, type=TYPE_BUY)
    unless Recommend.find(:first, :conditions => ["product_id = ? and request_type = ? and created_at > ?", product_id, type, Time.now - (60 * 60)])
      self.recommend_network_get(product_id, type)
    end

    logger.info(RecommendXml.find(:first, :conditions => ["product_id = ? and request_type = ?", product_id, type]).to_s)
    RecommendXml.find(:all, :conditions => ["product_id = ? and request_type = ?", product_id, type])
  end

  def self.ranking_get(limit = nil)
    unless Recommend.find(:first, :conditions => ["created_at > ? and product_id is null and request_type is null",Time.now - (60 * 60)])
      self.ranking_network_get
    end

    RecommendXml.find(:all,:conditions => ["product_id is null and request_type is null"],:limit => limit)
  end

  def self.recommend_network_get(product_id, type)
    url = "#{RECOMMEND_URLS[type]}#{product_id}" 
    return  unless self.network_get(url, ["product_id = ? and request_type = ?", product_id, type], product_id,type)
    Recommend.create(:product_id => product_id, :request_type=>type)
  end

  def self.ranking_network_get
    url = RANKING_URL
    return  unless self.network_get(url, ["product_id is null and request_type is null"], nil, nil)
    Recommend.create(:product_id => nil, :request_type=>nil)
  end

  def self.network_get(url, delete_conditions, product_id, type)
    begin
      timeout(1) do 
        open(url) do | http |
          response = http.read
          doc = REXML::Document.new response

          RecommendXml.delete_all(delete_conditions)
          columns = [:name, :url, :categroy, :price]
          doc.elements.each("items/item") do | r |
            recommend_xml = RecommendXml.new(:product_id => product_id, :request_type=>type)
            recommend_xml[:recommend_id] = r.elements["id"].text
            recommend_xml[:image_url] = r.elements["img_url"].text
            columns.each do | column |
              recommend_xml[column.to_s] = r.elements[column.to_s] && r.elements[column.to_s].text
            end
            recommend_xml.save
          end
        end
      end
      return true
    rescue TimeoutError => e
      p "err: #{ e }"
      logger.info "err: #{ e }"
      return false
    rescue 
      return false
    end
  end
end
