require 'erb'

class ShowExceptions

  attr_accessor :app

  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      app.call(env)
    rescue Exception => e
      render_exception(e)
    end
  end

  private

  def render_exception(e)
    @e = e
    template = File.read('lib/templates/rescue.html.erb')
    content = ERB.new(template).result(binding)
    res = ["500", {'Content-type' => 'text/html'}, content]
    res
  end

end
