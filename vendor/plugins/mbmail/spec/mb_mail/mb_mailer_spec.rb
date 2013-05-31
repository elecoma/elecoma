require File.dirname(__FILE__) + '/../spec_helper'

describe MbMail::MbMailer, "は" do
  before do
    class TestMbMailer < MbMail::MbMailer
      def testmail(sent_at = Time.now)
        @subject = base64('日本語subject')
        @recipients = [ INVALID_ADDRESS ]
        @from = "#{base64('日本語from')} <#{INVALID_ADDRESS}>"
        @sent_at = sent_at
      end
    end
    TestMbMailer.template_root = SAMPLE_DIR
    TestMbMailer.delivery_method = :test
  end
  it "日本語ヘッダを作成するためのbase64メソッドが使用できる" do
    MbMail::MbMailer.instance_methods.should include('base64')
  end
  it "送信先および送信元に3つ以上の連続ドットを含むメールを正しく作成できる" do
    TestMbMailer.deliver_testmail
    TestMbMailer.deliveries.first.to.first.should == INVALID_ADDRESS
    TestMbMailer.deliveries.first.from.first.should == INVALID_ADDRESS
  end
  it "本文に含まれる機種依存文字を iso-2022-jp エンコードにて正しく送信できる" do
    TestMbMailer.deliver_testmail
    TestMbMailer.deliveries.first.charset.should == "iso-2022-jp"
    TestMbMailer.deliveries.first.body.match(Regexp.new("㌧")).should_not be_nil
  end
end
