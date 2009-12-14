# -*- coding: utf-8 -*-
require 'RMagick'
class ImageResource < ActiveRecord::Base
  acts_as_paranoid
                  
  has_many :resrouce_datas

  def view(width = nil, hight = nil)
    resource_data = ResourceData.find_by_resource_id(self.id)
    resource_data.content
  end

  def content_data
    resource_data = ResourceData.find_by_resource_id(self.id)
    resource_data.content
  end

  def self.new_file(file, file_name)
    resource = ImageResource.new
    resource.name = file_name
    resource.content_type = file.content_type
    resource.save
    ResourceData.create(:resource_id => resource.id, :content => file.read)
    resource
  end

  def scaled_image(width, height)
    image = read_image(content_data)
    image.change_geometry("#{width}x#{height}") do |cols,rows,img|
      rows = 1 if rows == 0
      cols = 1 if cols == 0
      if cols <= 64 && rows <= 64
        # 画像が小さいときはこっちのほうが速いらしい
        img.thumbnail!(cols, rows)
      else
        img.resize!(cols, rows)
      end
    end
    data = image_data(image)
    run_gc
    data
  end
  
  def read_image(data)
    temp_filename do |filename|
      File.open(filename, "w+b") do |file|
        file.write(data)
      end
      Magick::Image.read(filename)[0]
    end
  end

  def temp_filename(&block)
    filename = File.join('/tmp', "user_photo_tmp.#{$$}")
    begin
      yield filename
    ensure
      File.delete filename if File.exist?(filename)
    end
  end

  def image_data(image)
    temp_filename do |filename|
      image.write(filename)
      File.open(filename, "rb") do |file|
        file.read
      end
    end
  end

  def run_gc
    fDisabled = GC.enable
    GC.start
    GC.disable if fDisabled
  end
  
end
