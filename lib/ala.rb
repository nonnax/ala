#!/usr/bin/env ruby
# Id$ nonnax 2022-04-03 11:59:22 +0800
%w[rack tilt delegate].map{|l|
  require l
}

$handler='thin'
$port=9292

Ala=Module.new do
  extend self
  app, req=Rack::Builder.new

  %w[get post].map do |m|
    define_method(m){ |u, &b|
      app.map(u) do
        run ->(env){[200, {"Content-Type" => "text/html"}, [app.instance_eval(&b)]]}
      end
    }
  end
  
  Tilt.default_mapping.lazy_map.each do |ext, engines|
    define_method(ext) do |arg, *args|
      arg=File.read(File.expand_path("../views/#{arg}.erb", __dir__)) if arg.is_a?(Symbol)      
      Kernel.const_get(engines.last.first).new(*args){ arg }
      .then{|template|template.render(app, locals=args.grep(Hash).pop.fetch(:locals, {})) }
    end
  end
 # locals = (args[0].respond_to?(:[]) ? args[0][:locals] : nil) || {}    # (args, args[0]&.[](:locals) || {})
    
  define_method(:run!) do
    Rack::Handler.get($handler).run( app, Port:$port ) {|server| $server=server }
  end
  
  %w[params session].map{ |method| define_method( method){ req.send method} }
  
  %w[set enable disable configure helpers use register].map{|m|define_method(m){|*_,&b|b&.[]}} 
  
  # app.use Rack::Session::Cookie, secret: '__a_very_Very_lo0Ong_sess1on_str1ng__'
  
  define_method(:before) do |&b|
    app.use Rack::Config, &b
  end

  app.use Rack::Lock
  
  before do |e|
    req = Rack::Request.new e
    req.params.dup.map do |k, v|
      params[k.to_sym] = v
    end
  end
end.then{|x| include x }
