class MobileDevice < ActiveRecord::Base
  acts_as_paranoid
  
  validates_presence_of :mobile_carrier_id, :device_name, :user_agent
  validates_presence_of :width, :height
  validates_format_of :user_agent, :with => /^[ .\-\:;\/%0-9A-Za-z]+$/
  def validate
    check_uniqueness_of_device_name
  end

  def check_uniqueness_of_device_name
    conds = []
    if self.device_name
      conds << ['device_name = ?', self.device_name]
    else
      conds << ['device_name is null']
    end
    if self.id
      conds << ['id <> ?', self.id]
    end
    if self.class.count(:conditions=>flatten_conditions(conds)) != 0
      errors.add :device_name, 'はすでに存在します'
      return false
    end
    true
  end

  belongs_to :mobile_carrier

  def before_save
    self.user_agent = self.user_agent + '%'
  end

  def remove_precent
    self.user_agent = self.user_agent.gsub(/%/, '')
  end

  # 画面サイズ表示
  def human_size
    if width == 480 && height == 640
      'VGA'
    elsif width == 240 && height == 320
      'QVGA'
    else
      '%d x %d' % [width, height]
    end
  end
end
