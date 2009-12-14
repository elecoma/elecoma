class CSVUtil
  class << self
    def valid_data_from_file?(stream_data)
      if stream_data.respond_to?(:original_filename)
        (!stream_data.eof?) && (File.extname(stream_data.original_filename) == ".csv") 
      else
        false
      end
    end
  end
end
