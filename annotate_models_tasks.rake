desc "Add schema information (as comments) to model files. (params: MODEL_NAMES=csv_header,csv_column)"

task :annotate_models do
   require File.join(File.dirname(__FILE__), "../../vendor/plugins/annotate_models/lib/annotate_models.rb")
   AnnotateModels.do_annotations ENV['MODEL_NAMES']
end

VO_SUFFIX = '.as'

desc "Generates the VO files for the project models.
    Note: Pass the model names as params, 
    for ex: 'rake annotate_models MODEL_NAMES=address,city'"
  task :create_vo_files do
    require File.join(File.dirname(__FILE__), "../../vendor/plugins/annotate_models/lib/annotate_models.rb")
    require File.join(File.dirname(__FILE__), "vo_file_creation.rb")
    if ENV['MODEL_NAMES'].nil?
      class_names = AnnotateModels.get_model_names.collect do |x|
        x.chomp(".rb").camelize
      end
    else
      class_names = ENV['MODEL_NAMES'].split(',').collect do |x|
        x.capitalize      
      end      
    end      
      class_names.each do |class_name|
        FileUtils.mkpath("flexapp/BankingSystemVO") unless File.directory?('flexapp/BankingSystemVO')
        new_vo_file = File.new("flexapp/BankingSystemVO/#{class_name+'VO'+VO_SUFFIX}", "w+") 
        puts "Creating vo file for #{class_name}"
        write_into_vo_file(new_vo_file,class_name.constantize)
      end  
  end