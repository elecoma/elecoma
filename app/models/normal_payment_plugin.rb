class NormalPaymentPlugin < ActiveForm
  include PaymentPluginBase

  def complete
    return :before_finish
  end

  def next_step(method_name)
    return :before_finish if method_name == :complete
    super
  end

  def has_config?
    false
  end
end
