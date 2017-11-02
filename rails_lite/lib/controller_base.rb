require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, params = {})
    @req = req
    @res = res
    @params = params
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise 'Double render/redirect error' if @already_built_response
    @res['Location'] = url
    @res.status = (302)
    session.store_session(@res)
    @already_built_response = true
    #status code 302
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise 'Double render/redirect error'  if @already_built_response
    @res.write(content)
    @res['Content-Type'] = content_type
    session.store_session(@res)
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.name.underscore
    view_template = "views/#{controller_name}/#{template_name}.html.erb"
    template = File.read(view_template)
    content = ERB.new(template).result(binding)
    render_content(content, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  def asset
    # @res['Content-type'] #= mime-type
    path = File.dirname(__FILE__)
    content = File.read(path + "#{@req.path}")
    if content
      @res.write(content)
    else
      @res.status = 404
    end
    @rendered = true
    @res.finish
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    render(name) unless @already_built_response
  end
end
