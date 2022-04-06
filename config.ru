#!/usr/bin/env ruby
# Id$ nonnax 2022-04-03 12:02:20 +0800
require_relative 'lib/ala'


get '/' do
  template = File.read('views/template.erb')
  erb template, locals: {name: params[:name]}
end

post '/' do  
  [:posting, params[:name]].join("\t")
end

get '/r' do  
  res.redirect '/'
end

post '/hey' do
  erb :template, locals: {name: params[:name]}
end

Ala.run!
