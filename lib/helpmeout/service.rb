require 'rest_client'
require 'builder'

module Helpmeout
  class Service
    
    def add_fix(failed_test)
      puts RestClient.post 'http://localhost:3000/fixes', generate_fix_xml(failed_test), :content_type => :xml
    end

    private 
    def generate_fix_xml(failed_test)
      xml = Builder::XmlMarkup.new( :indent => 2 )
      xml.instruct!
      xml.fix do |f|
        f.exception_message failed_test.exception_message
        f.backtrace failed_test.backtrace
        if failed_test.failed_test_files.any? 
          f.fix_files_attributes do |ffa|
            ffa.path "" # hack to always get an array of fixed_files. 
            ffa.content_before ""
            ffa.content_after ""
          end
          failed_test.failed_test_files.each do |failed_test_file|
            f.fix_files_attributes do |ffa|
              ffa.path failed_test_file.path
              ffa.content_before failed_test_file.content
              ffa.content_after File.read(failed_test_file.path)
            end
          end
        end
      end
      xml.target!
    end


  end
end