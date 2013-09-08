require 'sinatra'
require 'sinatra/reloader' if development?

require 'erb'
require 'rinda/tuplespace'

class RdVSpace
	def initialize
		@ts = Rinda::TupleSpace.new(1)
		@expires = 30
	end

	def write(name, type, body)
		_,_,key = @ts.take([:get, name, nil], @expires)
		@ts.write([:post, key, type, body], @expires)
	end

	def take(name)
		key = Object.new
		@ts.write([:get, name, key], @expires)
		_,_, type, body = @ts.take([:post, key, nil, nil], @expires)
		[type, body]
	end
end

set :rdv, RdVSpace.new

get '/' do
	erb RHTML
end

get '/upload' do
	name = params[:name]
	if name != ''
		type, body = settings.rdv.take(name)
		content_type type
		body
	else
		"no name fail."
	end
end

post '/upload' do
	name = params[:name]
	if params[:file]
		type = params[:file][:type]
		file_body = params[:file][:tempfile]
		settings.rdv.write(name, type, file_body)
		"success write"
	else
		redirect "/upload?name=#{name}"
	end
end




	RHTML = <<EOS
<html>
  	<title>RdVUp!</title><meta name="viewport" content="width=320" />
  	<body>
    	<form method='post' action='/upload' enctype='multipart/form-data'>
	      <input type='file' name='file'/><br />
	   	key: <input type='textfield' name='name' value=''/><br />
	   	<input type='submit' value='RdV' />
    	</form>
	</body>
</html>
EOS
	
