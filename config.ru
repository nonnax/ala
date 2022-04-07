#!/usr/bin/env ruby
# Id$ nonnax 2022-04-03 12:02:20 +0800
require_relative 'lib/ala'


get '/' do
  res.headers['Content-type']='text/html'
  template = File.read('views/template.erb')
  erb template, locals: {name: params[:name]}
end

post '/' do  
  [:posting, params[:name]].join("\t")
end

get '/r' do  
  res.redirect '/'
end

get '/halt' do  
  res=Rack::Response.new('halting...')
  res.status=401
  halt res.finish
end

post '/hey' do
  erb :template, locals: {name: params[:name]}
end

Ala.run!
