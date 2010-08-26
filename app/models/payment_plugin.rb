class PaymentPlugin < ActiveRecord::Base
  
  def get_plugin_instance
    ret = nil
    class_name = self.model_name.classify
    if Object.const_defined?(class_name)
      ret = Object.const_get(class_name).new
    end
    return ret
  end

end
