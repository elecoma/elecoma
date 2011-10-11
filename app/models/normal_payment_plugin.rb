# -*- coding: undecided -*-
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

  def has_info?
    false
  end

  def has_data_management?
    false
  end

  def payment_validate(payment)
    return true, ""
  end

  def use_smartphone?
    return true
  end

end
