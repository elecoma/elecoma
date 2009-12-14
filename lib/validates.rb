module ActiveRecordValidate
  STRING_MAX_LENGTH = 300
  TEXT_MAX_LENGTH = 100000
  INTEGER_MAX_LENGTH = 10
  def after_initialize
    @@load_validates ||= []
    return if @@load_validates.include?(self.class)
    @@load_validates << self.class
    attributes.each do | self_attribute |
      eval_expr = ""
      self_column = column_for_attribute(self_attribute[0])
      next if self_column.nil? || self_attribute.blank?
      if attributes =~ /name/
        eval_expr = <<EVAL_EXPR
send(validation_method(:on)) do |record|
  if #{attributes}.blank?
    record.errors.add_on_blank(:#{attributes})
  end
end
EVAL_EXPR
      elsif self_column.type == :string && self_column.name =~ /(email|mail_)/
        eval_expr = "validates_format_of :#{self_column.name}, :with =>Customer::EMAIL_PATTERN , :allow_blank => true "
      elsif self_column.type == :string
        eval_expr = "validates_length_of :#{self_column.name}, :allow_blank => true, :maximum => #{STRING_MAX_LENGTH}"
      elsif self_column.type == :text
        eval_expr = "validates_length_of :#{self_column.name}, :allow_blank => true, :maximum => #{TEXT_MAX_LENGTH}"
      elsif self_column.type == :integer
        eval_expr = %{
          validates_length_of :#{self_column.name}, :allow_blank => true, :maximum => #{INTEGER_MAX_LENGTH}
          validates_numericality_of :#{self_column.name}, :only_integer => true, :allow_blank => true
        }
      end
      self.class.class_eval eval_expr unless eval_expr.blank?
    end
  end
end

class ActiveRecord::Base
  include ActiveRecordValidate
end
