class Static

  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    @req = Rack::Request.new(env)
    @res = Rack::Response.new
    router = Router.new
    router.draw do
      get Regexp.new('^/public/(?<asset_path>)'), ControllerBase, :asset
    end
    router.run(@req, @res)
    # @app.call(env) unless @rendered
  end
end
