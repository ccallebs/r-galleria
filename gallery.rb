require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'dm-migrations'
require 'haml'

# setting up datamapper to use sqlite
DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/r-galleria.db")

class Entity
   include DataMapper::Resource

   property :id, Serial
   property :name, String
   
   has n, :galleries
end

class Gallery
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  property :description, String

  belongs_to :entity
end

class Upload
  include DataMapper::Resource

  property :id, Serial
  property :filename, String
  
  belongs_to :gallery
  belongs_to :entity

  def upload_file(file)
    filename = "#{@entity_id}-#{@gallery_id}-#{file[:filename]}"
    @filename = filename
    directory = "#{Dir.pwd}/public/files/"

    # creating file path
    path = File.join(directory, filename)

   # writing the file
   File.open(path, "wb") { |f| f.write(file[:tempfile].read) } 
  end
end

# invoking migration
DataMapper.auto_migrate!

# root
get '/' do
   haml :index
end

# admin index
get '/admin' do
   entities = Entity.all
   galleries = Gallery.all

   haml :'admin/index', :locals => {
      :galleries => galleries,
      :entities => entities
   }
end

# new entity
post '/admin/entities/new' do
   e = Entity.new
   e.attributes = params
   e.save

   redirect "/admin"
end

# destroy entity
post '/admin/entities/destroy' do
   puts params	
   e = Entity.get(params[:id])
   e.destroy

   redirect "/admin"
end

# new gallery
post '/admin/galleries/new' do
  g = Gallery.new
  g.attributes = params

  e = Entity.get(params[:entity_id])
  e.galleries << g

  g.save
  e.save

  redirect "/admin"
end

# new pictures
post '/admin/pictures/new' do
  process_files(params[:files])
end

def process_files(files)
  files.keys.each do |k|
    unless files[:file] && (tmpfile = files[:file][:tempfile]) && (name = file[:file][:filename])
      puts "No file selected."
    end

    f = Upload.new
    f.entity_id = params[:entity_id]
    f.gallery_id = params[:gallery_id]
    f.filename = "#{f.entity_id}-#{f.gallery_id}-#{name}"
    
    f.upload_file(files[k])
    f.save
  end
end
