require 'active_record/fixtures'
class Fixtures

  def insert_fixtures
    now = ActiveRecord::Base.default_timezone == :utc ? Time.now.utc : Time.now
    now = now.to_s(:db)

    # allow a standard key to be used for doing defaults in YAML
    if is_a?(Hash)
      delete('DEFAULTS')
    else
      delete(assoc('DEFAULTS'))
    end

    # track any join tables we need to insert later
    habtm_fixtures = Hash.new do |h, habtm|
      h[habtm] = HabtmFixtures.new(@connection, habtm.options[:join_table], nil, nil)
    end

    each do |label, fixture|
      row = fixture.to_hash

      if model_class && model_class < ActiveRecord::Base
        # fill in timestamp columns if they aren't specified and the model is set to record_timestamps
        if model_class.record_timestamps
          timestamp_column_names.each do |name|
            row[name] = now unless row.key?(name)
          end
        end

        # interpolate the fixture label
        row.each do |key, value|
          row[key] = label if value == "$LABEL"
          unless model_class.column_names.include? key
            p "Warning #{key} column no defined!!!"
            row.delete key
          end
        end

        # generate a primary key if necessary
        if has_primary_key_column? && !row.include?(primary_key_name)
          row[primary_key_name] = Fixtures.identify(label)
        end

        # If STI is used, find the correct subclass for association reflection
        reflection_class =
          if row.include?(inheritance_column_name)
            row[inheritance_column_name].constantize rescue model_class
          else
            model_class
          end

        reflection_class.reflect_on_all_associations.each do |association|
          case association.macro
          when :belongs_to
            # Do not replace association name with association foreign key if they are named the same
            fk_name = (association.options[:foreign_key] || "#{association.name}_id").to_s

            if association.name.to_s != fk_name && value = row.delete(association.name.to_s)
              if association.options[:polymorphic]
                if value.sub!(/\s*\(([^\)]*)\)\s*$/, "")
                  target_type = $1
                  target_type_name = (association.options[:foreign_type] || "#{association.name}_type").to_s

                  # support polymorphic belongs_to as "label (Type)"
                  row[target_type_name] = target_type
                end
              end

              row[fk_name] = Fixtures.identify(value)
            end
          when :has_and_belongs_to_many
            if (targets = row.delete(association.name.to_s))
              targets = targets.is_a?(Array) ? targets : targets.split(/\s*,\s*/)
              join_fixtures = habtm_fixtures[association]

              targets.each do |target|
                join_fixtures["#{label}_#{target}"] = Fixture.new(
                  { association.primary_key_name => row[primary_key_name],
                    association.association_foreign_key => Fixtures.identify(target) }, nil)
              end
            end
          end
        end
      end

      @connection.insert_fixture(fixture, @table_name)
    end

    # insert any HABTM join tables we discovered
    habtm_fixtures.values.each do |fixture|
      fixture.delete_existing_fixtures
      fixture.insert_fixtures
    end
  end

end
