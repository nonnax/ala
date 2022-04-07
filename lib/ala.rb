#!/usr/bin/env ruby
# Id$ nonnax 2022-04-03 11:59:22 +0800
%w[rack tilt delegate].map{|l| require l }
$handler, $port= 'thin', 9292
D = Object.method(:define_method)

Ala=Module.new do
  extend self
  app, routes, resp, req=Rack::Builder.new, Hash.new{|h, k| h[k]=[] },nil,nil 
  D.(:resolve){|e| routes[e.values_at('REQUEST_METHOD', 'REQUEST_PATH')]}
  D.(:res){ resp }
  
  %w[get post put delete].map do |m| 
    D.(m){ |u, &b| 
      routes[[m.upcase, u]] = b 
      app.map(u) do 
        run ->(e){
            body = app.instance_eval(&resolve(e)) rescue nil            
            res.write body
            return res.finish if body
            [404, {}, ['Not found']]
          } 
      end 
    } 
  end
  
  Tilt.lazy_map.each do |ext, engines|
    D.(ext) do |arg, *args|
      arg=File.read(File.expand_path("../views/#{arg}.erb", __dir__)) if arg.is_a?(Symbol)      
      Tilt.template_for(ext).new(*args){ arg }
      .then{|t|t.render(app, locals=args.grep(Hash).pop.fetch(:locals, {})) }
    end
  end
    
  D.(:run!){ Rack::Handler.get($handler).run( app, Port:$port ) {|server| $server=server } }
  
  %w[params session].map{ |method| D.( method){ req.send method} }
  %w[set enable disable configure helpers use register].map{|m|D.(m){|*_,&b|b&.[]}} 
  D.(:before){ |&b| app.use Rack::Config, &b}

  app.use Rack::Lock 
  before do |e| 
    req = Rack::Request.new(e); params.transform_keys!(&:to_sym)
    resp = Rack::Response.new
  end  
  self
end.then{|x| include x }
