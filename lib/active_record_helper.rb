module ActiveRecordHelper
  def flatten_conditions(conditions, op = "and")
    return nil if conditions.empty?
    ps = []
    condition = conditions.collect do |c|
      next if c.nil?
      next if c.size < 1
      ps += c[1..(c.size)]
      "( #{c[0]} )"
      end.delete_if { |c| c.blank? }.join(" #{op} ")
     [condition] + ps unless condition.empty?
  end

  def ilike_conditions(column, query)
	  return [] if column.nil? or column.empty? or query.nil? or query.empty?
	  case column
	  when String
	  	  flatten_conditions( query.split( /[\t\s　]/ ).collect do |q|
			  [ "lower(#{column}) like lower(?)", "%#{q.gsub(/%/,'\%').gsub(/_/,'\_')}%" ]
                  end, "and" )
	  end
  end

end

class ActiveRecord::Base
  include ActiveRecordHelper

  def self.delegate_to(*messages)
    name = messages.last
    if name.respond_to?(:[]) && name[:as]
      messages.pop
      name = name[:as]
    end
    define_method(name) do
      messages.inject(self) do |receiver, message|
        receiver && receiver.send(message)
      end
    end
  end

  class << self
    def self_and_descendants_from_active_record
      [self]
    end

    def human_name(*args)
      name.humanize
    end
  end
end

# avoid Rails 2.3.2 sessions problem of active record
require "active_record/session_store"
module ActiveRecord #:nodoc:
  class SessionStore #:nodoc:
    private
      def set_session(env, sid, session_data)
        Base.silence do
          record = get_session_model(env, sid)
          record.data = session_data
          return false unless record.save

          session_data = record.data
          if session_data && session_data.respond_to?(:each_value)
            session_data.each_value do |obj|
              obj.clear_association_cache if obj.respond_to?(:clear_association_cache)
            end
          end
        end

        return true
      end

      def get_session_model(env, sid)
        if env[ENV_SESSION_OPTIONS_KEY][:id].nil?
          env[SESSION_RECORD_KEY] = find_session(sid)
        else
          env[SESSION_RECORD_KEY] ||= find_session(sid)
        end
      end
  end
end

