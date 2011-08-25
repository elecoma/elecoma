class AddServiceCooperationsTemplatesData < ActiveRecord::Migration
  def self.up
    change_column :service_cooperations, :field_items, :text
    change_column :service_cooperations_templates, :field_items, :text
    ServiceCooperationsTemplate.create(
      :template_name      => 'AdvantageSearchTemplate',
      :service_name       => 'AdvantageSearch',
      :description        => %{
        KBMJの検索ASPに対応したアイテムマスタを出力するテンプレートになります。
      },
      :url_file_name       => 'AdvantageSearch_itemmaster',
      :file_type          => 0,
      :encode             => 0,
      :newline_character  => 2,
      :field_items        => 'id,title,text,url,permit,description,key_word,point_granted_rate,image_url,size_txt,material,origin_country,weight,sale_start_at,sale_end_at,public_start_at,public_end_at,price_max,price_mini,icon_states,category1,category2,category3,category4,category5',
      :sql                => %{SELECT
  products.id,
  products.name,
  products.introduction,
  '/products/show/'|| products.id,
  CASE WHEN products.permit THEN '1' ELSE '0' END AS permit,
  products.description,
  products.key_word,
  products.point_granted_rate,
  '/image_resource/show/' || products.small_resource_id,
  products.size_txt,
  products.material,
  products.origin_country,
  products.weight,
  products.sale_start_at,
  products.sale_end_at,
  products.public_start_at,
  products.public_end_at,
  p_style.price_max,
  p_style.price_min,
  ARRAY_TO_STRING(ARRAY(
      SELECT
        statuses.name
       FROM
         product_statuses
         LEFT OUTER JOIN statuses ON product_statuses.status_id = statuses.id
        WHERE
          product_statuses.product_id = products.id
      ),E'\n'
    ),
  categories_table.category1,
  categories_table.category2,
  categories_table.category3,
  categories_table.category4,
  categories_table.category5
 FROM products LEFT OUTER JOIN (
   SELECT
     product_id AS id, MAX(sell_price) AS price_max, MIN(sell_price) AS price_min
    FROM 
      product_styles
     GROUP BY
       product_id
 ) AS p_style ON products.id = p_style.id LEFT OUTER JOIN 
 (
   SELECT
     my.id,
     CASE
      WHEN p4.name IS NOT NULL THEN p4.name
      WHEN p3.name IS NOT NULL THEN p3.name
      WHEN p2.name IS NOT NULL THEN p2.name
      WHEN p1.name IS NOT NULL THEN p1.name
      ELSE my.name END as category1,
     CASE
      WHEN p4.name IS NOT NULL THEN p3.name
      WHEN p3.name IS NOT NULL THEN p2.name
      WHEN p2.name IS NOT NULL THEN p1.name
      WHEN p1.name IS NOT NULL THEN my.name
      ELSE NULL END as category2,
     CASE
      WHEN p4.name IS NOT NULL THEN p2.name
      WHEN p3.name IS NOT NULL THEN p1.name
      WHEN p2.name IS NOT NULL THEN my.name
      ELSE NULL END as category3,
     CASE
      WHEN p4.name IS NOT NULL THEN p1.name
      WHEN p3.name IS NOT NULL THEN my.name
      ELSE NULL END as category4,
     CASE
      WHEN p4.name IS NOT NULL THEN my.name
      ELSE NULL END as category5
    FROM
      categories AS my LEFT OUTER JOIN categories AS p1 ON my.parent_id = p1.id
      LEFT OUTER JOIN categories AS p2 ON p1.parent_id = p2.id
      LEFT OUTER JOIN categories AS p3 ON p2.parent_id = p3.id
      LEFT OUTER JOIN categories AS p4 ON p3.parent_id = p4.id
 ) AS categories_table ON products.category_id = categories_table.id
      }
    )
    ServiceCooperationsTemplate.create(
      :template_name      => 'mobileFlashTemplate',
      :service_name       => 'ケータイFlashASP',
      :description        => %{
        KBMJのケータイFlashASPに対応したアイテムマスタを出力するテンプレートになります。
      },
      :url_file_name       => 'mobileFlash_itemmaster',
      :file_type          => 0,
      :encode             => 0,
      :newline_character  => 2,
      :field_items        => 'id,title,text,url,permit,no_limit_flag,introduction,description,key_word,point_granted_rate,image_url,size_txt,material,origin_country,weight,sale_start_at,sale_end_at,public_start_at,public_end_at,price_max,price_min,selfcategories,p1_categories,p2_categories,p3_categories,p4_categories,icon_status',
      :sql                => %{SELECT
  products.id,
  products.name,
  products.introduction,
  '/products/show/'|| products.id,
  products.permit,
  products.no_limit_flag,
  products.description,
  products.key_word,
  products.point_granted_rate,
  '/image_resource/show/' || products.small_resource_id,
  products.size_txt,
  products.material,
  products.origin_country,
  products.weight,
  products.sale_start_at,
  products.sale_end_at,
  products.public_start_at,
  products.public_end_at,
  p_style.price_max,
  p_style.price_min,
  selfcategories.name,
  p1_categories.name,
  p2_categories.name,
  p3_categories.name,
  p4_categories.name,
  ARRAY_TO_STRING(ARRAY(
    SELECT
      statuses.name
     FROM
       product_statuses LEFT OUTER JOIN statuses ON product_statuses.status_id = statuses.id
      WHERE
        product_statuses.product_id = products.id), ','
  )
 FROM
  products LEFT OUTER JOIN (
    SELECT
      product_id AS id,
      MAX(sell_price) AS price_max,
      MIN(sell_price) AS price_min
     FROM
      product_styles
     GROUP BY product_id
  ) AS p_style ON products.id = p_style.id
  LEFT OUTER JOIN categories AS selfcategories ON selfcategories.id = products.category_id
  LEFT OUTER JOIN categories AS p1_categories ON selfcategories.parent_id = p1_categories.id
  LEFT OUTER JOIN categories AS p2_categories ON p1_categories.parent_id = p2_categories.id
  LEFT OUTER JOIN categories AS p3_categories ON p2_categories.parent_id = p3_categories.id
  LEFT OUTER JOIN categories AS p4_categories ON p3_categories.parent_id = p4_categories.id
      }
    )
  end

  def self.down
    
    p "field_itemsの項目の型が'text' → 'string' にレベルダウンしました"
    p "それに伴って、field_itemsの文字数が255文字を超えるものにはnullが入ります"
    p "お手数ですが再設定お願いします"

    ServiceCooperationsTemplate.find(:all).each do |item|
      item.update_attribute(:field_items, "")
    end
    ServiceCooperation.find(:all).each do |item|
      item.update_attribute(:field_items, "")
    end
    change_column :service_cooperations, :field_items, :string
    change_column :service_cooperations_templates, :field_items, :string
    ServiceCooperationsTemplate.find_all_by_template_name('AdvantageSearchTemplate').each do | item |
      item.delete
    end
    ServiceCooperationsTemplate.find_all_by_template_name('mobileFlashTemplate').each do | item |
      item.delete
    end
    
  end
end
