require 'rack'

module Nancy
  class Base
    def initialize
      @routes = {}
    end

    attr_reader :routes

    def params
      @request.params
    end

    def get(path, &handler)
      route("GET", path, &handler)
    end

    def call(env)
      @request = Rack::Request.new(env)
      verb = @request.request_method
      requested_path = @request.path_info

      handler = @routes.fetch(verb, {}).fetch(requested_path, nil)

      if handler
        instance_eval(&handler)
      else
        [404, {}, ["Oops! No such route for #{verb} #{requested_path}"]]
      end
    end

    private

    def route(verb, path, &handler)
      @routes[verb] ||= {}
      @routes[verb][path] = handler
    end
  end
end

nancy = Nancy::Base.new

nancy.get "/hello" do
  [200, {}, ["Nancy says hello"]]
end

nancy.get "/" do
  [200, {}, ["Your params are #{params.inspect}"]]
end

Rack::Handler::WEBrick.run nancy, Port: 9292

puts nancy.routes
