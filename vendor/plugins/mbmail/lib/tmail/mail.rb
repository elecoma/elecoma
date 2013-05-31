module TMail

  # Mail 構築時に MessageIdHeader が正しく作成できない処理を修正
  class Mail
    def []=( key, val )
      dkey = key.downcase

      if val.nil?
        @header.delete dkey
        return nil
      end

      case val
      when String
        header = new_hf(key, val)
      when HeaderField
        # HeaderField が与えられた場合、そのままヘッダに代入する
        header = val
      when Array
        ALLOW_MULTIPLE.include? dkey or
                raise ArgumentError, "#{key}: Header must not be multiple"
        @header[dkey] = val
        return val
      else
        header = new_hf(key, val.to_s)
      end
      if ALLOW_MULTIPLE.include? dkey
        (@header[dkey] ||= []).push header
      else
        @header[dkey] = header
      end

      val
    end
  end
end
