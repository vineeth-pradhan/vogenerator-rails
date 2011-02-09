require "config/environment"

MODEL_DIR   = File.join(RAILS_ROOT, "app/models")
EXCLUDED_COLUMNS = ["id","created_at","updated_at","lock_version"]

module VoGeneratorRails
  def self.get_model_names
    models=[]
      Dir.chdir(MODEL_DIR) do
        models = Dir["**/*.rb"]
      end
    models
  end

  def self.write_into_vo_file(new_vo_file,klass)
    new_vo_file.puts(package_name)
    new_vo_file.puts('{')
      new_vo_file.printf(insert_space(5)+"import com.ndsi.core.valueobjects.base.NdsVersionedVO;; \n")
      new_vo_file.printf(insert_space(5)+"[RemoteClass(alias='#{klass.name}VO')] \n")
      new_vo_file.printf(insert_space(5)+"[Bindable]")
      new_vo_file.print("\n")


      new_vo_file.printf(insert_space(5)+"public dynamic class #{klass.name}VO extends NdsVersionedVO \n")
      new_vo_file.puts(insert_space(5)+"{ \n")


      new_vo_file.printf(insert_space(9)+"public static const NAME:String = '#{klass.name.underscore.upcase}'; \n")
      new_vo_file.print(insert_space(9))
      new_vo_file.printf("public static const IDENTITY:String = '#{methodize(klass.name)}'; \n")

      new_vo_file.print("\n")
      new_vo_file.print(insert_space(9))
      new_vo_file.printf("public function #{klass.name}VO() \n")
      new_vo_file.print(insert_space(9))
      new_vo_file.printf("{ \n")
      new_vo_file.print(insert_space(9))
      new_vo_file.printf("} \n")

      table_columns = klass.columns
      table_arrys = build_columns_hash(table_columns)

      for table_arry in table_arrys
        new_vo_file.print insert_space(9);new_vo_file.print("public var ");new_vo_file.print methodize(table_arry.keys.to_s.camelize);new_vo_file.print ':';new_vo_file.print "String"; new_vo_file.print "; \n"
      end

      new_vo_file.print("\n\n")
      new_vo_file.print(insert_space(9)+"public static function factory():NdsVersionedVO {\n")
      new_vo_file.print(insert_space(9)+"return new #{klass.name}VO; \n")
      new_vo_file.print(insert_space(9)+"} \n\n")

      new_vo_file.print(insert_space(9)+"public static function moldDie(value:Object):#{klass.name}VO { \n")
      new_vo_file.print(insert_space(9)+"return #{klass.name}VO(value); \n")
      new_vo_file.print(insert_space(9)+"} \n")

    new_vo_file.print(insert_space(5)+"} \n")
    new_vo_file.print('}')

    close(new_vo_file)
  end

  def self.package_name
    "package com.#{RAILS_ROOT.split('/').last}.valueobjects"
  end

  # converts strings like 'AddressInfo' to 'addressInfo'
  def self.methodize(str)
    # Note: str should be in camel case before calling this method
    ch = ""
    str.chars.to_a.each_with_index {|c,i|
    if i.zero?
      ch << c.downcase
    else
      ch << c
    end
    }
  ch
  end

  def self.build_columns_hash(table_columns)
    table_arrys = []
    for table_column in table_columns
      next if EXCLUDED_COLUMNS.include?(table_column.name)
      table_arrys << {table_column.name.to_s => table_column.type.to_s} #works
    end
    table_arrys
  end

  def self.insert_space(num)
    " "*num
  end

  def self.close(new_vo_file)
    new_vo_file.close
  end
end