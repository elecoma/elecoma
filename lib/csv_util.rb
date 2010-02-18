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
    
    def make_csv_string_with_cache(rows, title, controller, page_cache_directory, filename, perform_caching)
      date = DateTime.now

      # CSV に吐く
      path = Pathname.new(page_cache_directory).join(controller, 'csv').join(filename)
      f = StringIO.new('', 'w')

      CSV::Writer.generate(f) do | writer |
        writer << title
        rows.each do |row|
          writer << row
        end
      end
      unless perform_caching
        fw = File.open(path.to_s, 'w')
        fw << Iconv.conv('cp932', 'UTF-8', f.string)
        fw.close
      end
      return f
    end

  end
end
