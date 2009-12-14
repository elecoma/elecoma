class Veritrans
  @@proxy_command = "(cd #{RAILS_ROOT}/script/veritrans; perl proxy.pl)"
  cattr_accessor :proxy_command
  @@service_type = 'bsx1'
  cattr_accessor :service_type

  attr_accessor :config
  def initialize(proxy_command=@@proxy_command)
    @proxy_command = proxy_command || "(cd #{RAILS_ROOT}/script/veritrans; perl proxy.pl)"
    @config = {}
  end

  def request(command, params)
    yaml = {
      'command' => command,
      'params' => params.stringify_keys
    }.to_yaml
    chunk = nil
    IO.popen(@proxy_command, "r+") {|io|
      io.puts(yaml)
      io.close_write
      chunk = io.read # 向こうで close しないと無限に待つ
    }
    Response.new(YAML.load(chunk))
  end

  # 与信
  def authonly(params)
    auth('authonly', params)
  end

  # 不明
  def mauthonly(params)
    auth('mauthonly', params)
  end

  # 与信+売上
  def authcapture(params)
    auth('authcapture', params)
  end

  # 不明
  def mauthcapture(params)
    auth('mauthcapture', params)
  end

  # 売上
  def postauth(params)
    p = build_params(params, [:order_id, :amount])
    request('postauth', p)
  end

  # キャンセル
  def void(params)
    p = build_params(params, [:order_id, :txn_type])
    request('payrequest', p)
  end

  # 返品
  def return(params)
    p = build_params(params, [:order_id, :txn_type])
    request('payrequest', p)
  end

  # 確認？
  def payrequest(params)
    p = build_params(params, [:order_id, :amount, :note])
    request('payrequest', p)
  end

  # 再試行
  def retry(params)
    p = build_params(params, [:order_id])
    request('retry', p)
  end

  # 検索
  def query(params)
    p = build_params(params, [])
    request('query', p)
  end

  # 複数検索
  def query_orders(params)
    p = build_params(params, [:start_time, :end_time])
    request('query-orders', p)
  end

  # jpo-info に入れる値
  def self.bunkatsu(n)
    n == 1 and return '10'
    '61C%02d' % n
  end

  private

  def auth(command, params)
    p = build_params(params, [:order_id, :amount, :card_number, :card_exp])
    request(command, p)
  end

  def build_params(params, required)
    params = params.inject({}) do |hash, pair|
      k = pair[0].to_s.gsub(/_/, '-')
      hash[k] = pair[1]
      hash
    end
    if @@service_type
      params['service-type'] ||= @@service_type
    end
    missing = required.select do |name|
      name = name.to_s.gsub(/_/, '-')
      params[name].nil?
    end
    unless missing.empty?
      raise ArgumentError, "parameter(s) required: %s" % missing.join(", ")
    end
    params
  end

  class Response
    def initialize(hash)
      @h = hash
    end

    def success?
      @h['MStatus'] == 'success'
    end

    def message
      message = @h['aux-msg']
      if message.blank? || !success?
        message = @h['MErrMsg']
      end
      message && message.toutf8
    end

    def card_number
      n = @h['card-number'].to_s
      if n
        n[0..1] + '*' * 10 + n[2..5]
      end
    end

    def [](key)
      key = translate_key(key)
      @h[key]
    end

    def paid_amount
      s = @h['paid-amount']
      s && s.split(/ /)[1].to_i
    end

    def []=(key, value)
      key = translate_key(key)
      @h[key] = value
    end

    def method_missing(name, *args)
      self[name]
    end

    private

    def translate_key(key)
      if key.is_a?(Symbol)
        key = key.to_s.gsub('_', '-')
      end
      key
    end
  end

end
