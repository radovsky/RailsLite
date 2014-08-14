require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'


class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req, route_params)
    @already_built = false
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    raise if @already_built
    @res.body = content
    @res.content_type = type
    @already_built = true
  end

  # helper method to alias @already_built_response
  def already_built_response?
    @already_built
  end

  # set the response status code and header
  def redirect_to(url)
    raise if @already_built
    @res.header["location"] = url
    @res.status = 302
    @already_built = true
    session.store_session(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.name.underscore
    f = File.read("views/#{controller_name}/#{template_name}.html.erb")
    template = ERB.new(f).result(binding)
    render_content(template, "text/html")
    session.store_session(@res)
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name.to_sym)
  end
end
