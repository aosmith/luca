
require 'rubygems'
require 'bundler'
Bundler.require

require 'faker'

module AssetHelpers
  def asset_path(source)
    "/assets/" + settings.sprockets.find_asset(source).digest_path
  end
end

require "#{ File.expand_path('../', __FILE__) }/lib/luca/template.rb"
require "#{ File.expand_path('../', __FILE__) }/lib/luca/code_browser.rb"

module Luca
  class Template
    def self.namespace
      "Luca.templates"
    end
  end
end

class App < Sinatra::Base
  set :root, File.expand_path('../', __FILE__)
  set :sprockets, Sprockets::Environment.new(root)
  set :precompile, [ /\w+\.(?!js|css).+/, /application.(css|js)$/ ]
  set :assets_prefix, 'assets'
  set :assets_path, File.join(root, 'public', assets_prefix)

  sprockets.register_engine '.luca', Luca::Template 

  configure do
    sprockets.append_path(File.join(root, 'assets', 'stylesheets'))
    sprockets.append_path(File.join(root, 'assets', 'javascripts'))
    sprockets.append_path(File.join(root, 'vendor', 'assets', 'javascripts'))
    sprockets.append_path(File.join(root, 'vendor', 'assets', 'stylesheets'))
    sprockets.append_path(File.join(root, 'assets', 'images'))
    sprockets.append_path(File.join(root, 'vendor', 'assets', 'images'))

    sprockets.context_class.instance_eval do
      include AssetHelpers
    end
  end

  helpers do
    include AssetHelpers
  end

  get "/" do
    erb :index
  end

  get "/jasmine" do
    erb :jasmine
  end

  Luca::CodeBrowser.look_for_source_in( File.join(File.expand_path('../', __FILE__),'src') )

  get "/luca/source-map.js" do
    source_map = {}

    files = (["src/**/*.coffee","assets/javascripts/sandbox/**/*.coffee"]).map do |location|
      Dir.glob("#{ App.root }/#{ location }")
    end

    files.flatten.each do |file|
      definitions = IO.read(file).lines.to_a.grep /_\.def/

      definitions.each do |definition|
        component = definition.match(/_\.def\(['"](.+)['"]\)\./)

        if component and component[1]
          componentId = component[1].gsub(/['"].*$/,'')
          if componentId
            source_map[ componentId ] = {className:componentId,file:file,source:IO.read(file)}
          end
        end
      end      
    end

    JSON.generate source_map.values
  end

  get "/components" do
    if params[:component]
      component = params[:component]
      source = Luca::CodeBrowser.get_source_for( component )
      {className:component, source:source}.to_json
    else
      Luca::CodeBrowser.map_source
    end
  end

end
