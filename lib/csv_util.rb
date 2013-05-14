# -*- coding: utf-8 -*-
class CSVUtil
  class << self
    def valid_data_from_file?(stream_data)
      if stream_data.respond_to?(:original_filename)
        (!stream_data.eof?) && (File.extname(stream_data.original_filename) == ".csv") 
      else
        false
      end
    end

    def make_csv_index_pairs(controller, page_cache_directory, page_cache_extension)
      dir = Pathname.new(page_cache_directory).join(controller, 'csv')
      unless FileTest.exist?(dir.to_s)
        FileUtils.mkdir_p(dir.to_s)
        return false
      end

      limit = 1.year.ago
      pairs = dir.enum_for(:each_entry).map do |path|
        dir.join(path)
      end.select do |path|
        path.extname == page_cache_extension or path.extname == '.csv'
      end.map do |path|
        path.basename(path.extname).to_s
      end.map do |id|
        [id, id.to_time(:local)]
      end.select do |_, time|
        time >= limit
      end.sort_by do |_, time|
        time
      end.reverse
      
      return pairs
    end
    
    def make_csv_string(rows, header)
      CSV.generate do |writer|
        writer << header
        rows.each {|row| writer << row }
      end
    end
  end
end
