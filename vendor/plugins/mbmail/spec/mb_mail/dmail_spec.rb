require File.dirname(__FILE__) + '/../spec_helper'

describe MbMail::DMail, "は" do
  it "引数無しで正しく初期化できる" do
    @d = MbMail::DMail.new
    @d.should satisfy { |d| d.instance_of? MbMail::DMail }
  end
  it "既存の HTML メールを元に正しく初期化できる" do
    @d = MbMail::DMail.load("#{SAMPLE_DIR}/decomail.eml")
    @d.should satisfy { |d| d.instance_of? MbMail::DMail }
  end
  describe "構築済みの HTML メールを" do
    before do
      @dm = MbMail::DMail.new

      # ヘッダの作成
      @dm.from = "=?iso-2022-jp?B?#{[NKF.nkf('-j -m0', '日本語from')].pack('m').delete("\r\n")}?= <test@example.com>"
      @dm.subject = "=?iso-2022-jp?B?#{[NKF.nkf('-j -m0', '日本語subject')].pack('m').delete("\r\n")}?="
      @dm.body = ''
      @dm.content_type = 'multipart/mixed'

      # 各パートを作成
      ## インライン画像パート
      ### インライン画像の content_id
      ### au 向けは '@' を一つだけ含むようにすること
      @sample_cid = '<sample_cid@example.com>'
      @inlined_image_parts = []
      inlined_image_part = MbMail::DMail.new
      inlined_image_part.content_type = 'image/gif; name="inlined.gif"'
      cid_header = MbMail::HeaderField.new('content-id', @sample_cid)
      cid_header.id = @sample_cid
      inlined_image_part['content-id'] = cid_header
      inlined_image_part.transfer_encoding = 'Base64'
      inlined_image_part.content_disposition = 'inline'
      inlined_image_part.body = Base64.encode64(File.open("#{SAMPLE_DIR}/inlined.gif").read)
      @inlined_image_parts << inlined_image_part
      ## 添付画像パート
      @attached_image_parts = []
      attached_image_part = MbMail::DMail.new
      attached_image_part.content_type = 'image/gif; name="attached.gif"'
      attached_image_part.transfer_encoding = 'Base64'
      attached_image_part.content_disposition = 'attachment'
      attached_image_part.body = Base64.encode64(File.open("#{SAMPLE_DIR}/attached.gif").read)
      @attached_image_parts << attached_image_part
      ## 本文 text/plain パート
      @text_part = MbMail::DMail.new
      @text_part.transfer_encoding = 'Base64'
      ### 絵文字変換を使うのであれば Unicode 実体参照に変換しておく
      @text_part.content_type = 'text/plain; charset="UTF-8"'
      @text_part.body = Base64.encode64(Jpmobile::Emoticon.utf8_to_unicodecr("日本語メールです。\n絵文字を使用する場合はdocomoのUnicode表記を使用します。\n&#xE63E;これは「晴れ」"))
      ## 本文 text/html パート
      @html_part = MbMail::DMail.new
      @html_part.transfer_encoding = 'Base64'
      @html_part.content_type = 'text/html; charset="UTF-8"'
      @html_part.body = Base64.encode64(Jpmobile::Emoticon.utf8_to_unicodecr("<HTML><BODY><DIV>日本語メールです。</DIV><DIV><FONT color='#FF0000;'>絵文字を使用する場合はdocomoのUnicode表記を使用します。</FONT></DIV> <DIV>&#xE63E;これは「晴れ」</DIV> <DIV>インライン画像はcidを指定して<IMG src='cid:#{@sample_cid}'>このように表記します。</DIV></BODY></HTML>"))

      # 各パートを組み立てる
      # サンプルは docomo と同形式
      @alt_part = MbMail::DMail.new
      @alt_part.body = ''
      @alt_part.content_type = 'multipart/alternative'
      @alt_part.parts << @text_part
      @alt_part.parts << @html_part
      @rel_part = MbMail::DMail.new
      @rel_part.body = ''
      @rel_part.content_type = 'multipart/related'
      @rel_part.parts << @alt_part
      @inlined_image_parts.each { |ip| @rel_part.parts << ip }
      @dm.parts << @rel_part
      @attached_image_parts.each { |ap| @dm.parts << ap }
    end
    it "docomo 向けに変換できる" do
      lambda { @dm.to_docomo_format }.should_not raise_error
    end
    it "au 向けに変換できる" do
      lambda { @dm.to_au_format }.should_not raise_error
    end
    it "softbank 向けに変換できる" do
      lambda { @dm.to_softbank_format }.should_not raise_error
    end
  end
end
