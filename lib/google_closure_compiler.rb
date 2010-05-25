require "rexml/document"
require "yaml"

require "app/helpers/google_closure_helper" 

require 'google_closure_compiler/javascript'

ActionView::Base.send :include, GoogleClosureHelper

# Adapted from Smurf plugin http://github.com/thumblemonks/smurf/
module ActionView::Helpers::AssetTagHelper
  private
  def join_asset_file_contents_with_minification(files)
    content = join_asset_file_contents_without_minification(files)

    if !files.grep(%r[/javascripts]).empty?
      content = GoogleClosureCompiler::Javascript.new(content).compiled
    end
    content
  end
  alias_method_chain :join_asset_file_contents, :minification
end # ActionView::Helpers::AssetTagHelper

module GoogleClosureCompiler
  class << self
    CONFIG = YAML.load_file(File.join(Rails.root, 'config', 'google_closure_compiler.yml'))[Rails.env] || {}
    
    def compiler_application_path
      CONFIG['compiler_application_path'] || File.join(File.dirname(__FILE__), '..', 'bin', 'compiler.jar')
    end
  
    def compilation_level
      CONFIG['compilation_level'] || 'SIMPLE_OPTIMIZATIONS'
    end
    
    def java_path
      CONFIG['java_path'] || 'java'
    end
    
    def python_path
      CONFIG['python_path'] || 'python'
    end
    
    def closure_library_path
      CONFIG['closure_library_path'] || 'closure'
    end
    
    def closure_library_full_path
      File.join(Rails.root, 'public', 'javascripts', closure_library_path)
    end
  end
end
