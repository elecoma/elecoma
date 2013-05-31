# 携帯メール対応モジュール
module MbMail

  # HeaderField 操作用に TMail から移管
  class HeaderField < TMail::HeaderField; end

  # デコメールクラス
  class DMail < TMail::Mail

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

    # docomo のデコメールフォーマットに変換する
    def to_docomo_format
      converted_for_carrier(:docomo)
    end

    # au のデコレーションメールフォーマットに変換する
    def to_au_format
      converted_for_carrier(:au)
    end

    # softbank のデコレメールフォーマットに変換する
    def to_softbank_format
      converted_for_carrier(:softbank)
    end

    protected

    # 指定された content-type のパーツを取得する
    def get_specified_type_parts(mimetype)
      specified_type_parts = []
      specified_type_parts << self if Regexp.new("^#{mimetype}$", Regexp::IGNORECASE) =~ self.content_type
      if /^multipart\/(.+)$/ =~ self.content_type then
        self.parts.each do |p|
          specified_type_parts += p.get_specified_type_parts(mimetype)
        end
      end
      specified_type_parts
    end

    private

    # 指定のキャリアのデコメールフォーマットに変換する
    # 現時点では、:docomo, :au, :softbank のみ対応
    def converted_for_carrier(carrier = :docomo)
      organize_mail_parts

      dm = MbMail::DMail.new
      self.header.each do |key,value|
        next if key == 'content-type' # content-type は引き継いだらダメ
        dm[key] = value.to_s
      end
      dm.body = ""
      dm.content_type = 'multipart/mixed'

      # text/plain パートの作成
      tp = MbMail::DMail.new
      case carrier
      when :docomo
        tp.content_type = 'text/plain; charset="Shift_JIS"'
        tp.transfer_encoding = 'Base64'
        tp.body = Base64.encode64(Jpmobile::Emoticon::unicodecr_to_external(NKF.nkf('-m0 -x -Ws', @text_part.body), Jpmobile::Emoticon::CONVERSION_TABLE_TO_DOCOMO))
      when :au
        tp.content_type = 'text/plain; charset="Shift_JIS"'
        tp.transfer_encoding = 'Base64'
        tp.body = Base64.encode64(Jpmobile::Emoticon::unicodecr_to_external(NKF.nkf('-m0 -x -Ws', @text_part.body), Jpmobile::Emoticon::CONVERSION_TABLE_TO_AU))
      when :softbank
        tp.content_type = 'text/plain; charset="UTF-8"'
        tp.transfer_encoding = 'Base64'
        table = Jpmobile::Emoticon::CONVERSION_TABLE_TO_SOFTBANK
        emoticon_converted = @text_part.body.gsub(/&#x([0-9a-f]{4});/i) do |match|
          unicode = $1.scanf("%x").first
          case table[unicode]
          when Integer
            [(table[unicode].to_i-0x1000)].pack('U')
          when String
            table[unicode]
          else
            match
          end.force_encoding(Encoding::ASCII_8BIT)
        end
        tp.body = Base64.encode64(emoticon_converted)
      else
        tp.content_type = 'text/plain; charset="UTF-8"'
        tp.transfer_encoding = 'Base64'
        tp.body = Base64.encode64(@text_part.body)
      end

      # text/html パートの作成
      hp = MbMail::DMail.new
      case carrier
      when :docomo
        hp.content_type = 'text/html; charset="Shift_JIS"'
        hp.transfer_encoding = 'Base64'
        hp.body = Base64.encode64(Jpmobile::Emoticon::unicodecr_to_external(NKF.nkf('-m0 -x -Ws', @html_part.body), Jpmobile::Emoticon::CONVERSION_TABLE_TO_DOCOMO))
      when :au
        hp.content_type = 'text/html; charset="Shift_JIS"'
        hp.transfer_encoding = 'Base64'
        hp.body = Base64.encode64(Jpmobile::Emoticon::unicodecr_to_external(NKF.nkf('-m0 -x -Ws', @html_part.body), Jpmobile::Emoticon::CONVERSION_TABLE_TO_AU))
      when :softbank
        hp.content_type = 'text/html; charset="UTF-8"'
        hp.transfer_encoding = 'Base64'
        table = Jpmobile::Emoticon::CONVERSION_TABLE_TO_SOFTBANK
        emoticon_converted = @html_part.body.gsub(/&#x([0-9a-f]{4});/i) do |match|
          unicode = $1.scanf("%x").first
          case table[unicode]
          when Integer
            [(table[unicode].to_i-0x1000)].pack('U')
          when String
            table[unicode]
          else
            match
          end.force_encoding(Encoding::ASCII_8BIT)
        end
        hp.body = Base64.encode64(emoticon_converted)
      else
        hp.content_type = 'text/plain; charset="UTF-8"'
        hp.transfer_encoding = 'Base64'
        hp.body = Base64.encode64(@html_part.body)
      end

      # キャリアによって multipart 構成を分岐
      alt_p = MbMail::DMail.new
      alt_p.body = ""
      alt_p.content_type = 'multipart/alternative'
      alt_p.parts << tp
      alt_p.parts << hp
      case carrier
      when :au
        dm.parts << alt_p
        @in_lined_image_parts.each do |ip| dm.parts << ip end
        @attached_image_parts.each do |ap| dm.parts << ap end
      else
        rel_p = MbMail::DMail.new
        rel_p.body = ""
        rel_p.content_type = 'multipart/related'
        rel_p.parts << alt_p
        @in_lined_image_parts.each do |ip| rel_p.parts << ip end
        dm.parts << rel_p
        @attached_image_parts.each do |ap| dm.parts << ap end
      end

      dm
    end

    # オリジナルのメール構成を解析し、各パーツに分離する
    def organize_mail_parts
      @text_part = get_specified_type_parts('text/plain').first
      @html_part = get_specified_type_parts('text/html').first
      # いったん全ての画像をインライン扱いとし、
      # その後本文から参照されていない画像を添付扱いとする
      # au でいずれの添付タイプについても同等に扱われているため
      @in_lined_image_parts = get_specified_type_parts('image/(gif|jpeg|jpg)')
      @in_lined_image_parts.map do |ip| ip.content_disposition = 'inline' end
      @attached_image_parts = []
      @in_lined_image_parts.delete_if do |ip|
        if /TMail\:\:MessageIdHeader\s\"<([\.@_0-9a-zA-Z]+)>/ =~ ip["content-id"].inspect then
          unless Regexp.new("src=['\"]cid:#{$1}", Regexp::IGNORECASE) =~ @html_part.body then
            ip.content_disposition = 'attachment'
            @attached_image_parts << ip
            true
          end
        else
          false
        end
      end
    end
  end

end
