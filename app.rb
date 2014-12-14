require 'sinatra' 
require 'sinatra/reloader' if development?
require 'rubygems'
require 'data_mapper'
require 'pp'
require 'restclient'
require 'xmlsimple'
require 'chartkick'

configure :development, :test do
	DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/aditives.db")
	DataMapper::Logger.new($stdout, :debug)
	DataMapper::Model.raise_on_save_failure = true 

	require_relative 'model'

	DataMapper.finalize

	#DataMapper.auto_migrate!
	DataMapper.auto_upgrade!
end

get '/' do
	erb :index
end

post '/' do

	prod = params[:producto].upcase
	consulta = Producto.relacion(prod)
	@consulta = Hash.new

	consulta.each do |i|
		@consulta[i.aditivo_toxicidad.to_s] = i.count.to_i
		puts "#{i.aditivo_toxicidad} - #{i.count}"
		
	end
	erb :index

end	

get '/db' do

	

end




get '/aditivos' do
	@list = Aditivo.all(:order => [ :id.asc ])
	erb :aditivos

end

post '/aditivos' do
	puts "Inside post /ejemplos"
	bus = params[:busqueda].upcase

	@consulta = Aditivo.busqueda(bus)
	puts "busqueda = #{bus}"

	erb :aditivos
end

get '/actualizar' do

	xml = RestClient.get "https://raw.githubusercontent.com/alu0100700435/MyOpenData/master/public/aditivos.xml" 
	datos = XmlSimple.xml_in(xml.to_s)['aditivo']

	datos.each do |i|
		num = i["numero"].to_s.delete "[\"]"
		nombre = i["nombre"].to_s.delete "[\"]"
		tox = i["toxicidad"].to_s.delete "[\"]"
		puts "#{nombre}"
		@info = Aditivo.first_or_create(:numero  => num, :name => nombre, :toxicidad => tox)
		puts "#{@info}"
	end

	#BASE DE DATOS DE PRODUCTOS:

	#Coca-Cola
	numero = Aditivo.first(:numero=> "E150d")
	numero1 = Aditivo.first(:numero=> "E338")
	consult = Producto.first_or_create(:nombre => "Coca-Cola", :aditivo => numero )
	consult = Producto.first_or_create(:nombre => "Coca-Cola", :aditivo => numero1 )
	
end

