# -*- encoding: utf-8 -*-

require "rdoc"
require "rdoc/parser/ruby"


#
# Artificial scope for top-level routes.
#
class RDoc::SinatraRoutes < RDoc::AnonClass
end

#
# Sinatra route definition as a method.
#
class RDoc::SinatraRoute < RDoc::AnyMethod

  def initialize(route_definition, content_text)
    super(content_text, route_definition)

    @params = ""
  end

  def aref_prefix
    ""
  end
end

#
# Sinatra routing error definition as a method.
#
class RDoc::SinatraRouteError < RDoc::SinatraRoute
end


#
# An augmented Ruby parser for Sinatra projects.
#
# In addition to normal Ruby doc, documentation is also extracted
# for route definitions.
#
class RDoc::Parser::Sinatra < RDoc::Parser::Ruby

  # Re-declare to force overriding the normal .rb handler.
  parse_files_matching /\.rbw?$/i


  HTTP_VERBS  = %w[GET HEAD POST PUT PATCH DELETE OPTIONS]
  HTTP_ERRORS = {"NOT_FOUND" => 404, "ERROR" => 500}


  #
  # New parser, adds a top-level Application Routes.
  #
  def initialize(top_level, file_name, content, options, stats)
    super

    # Tuck away our little special module
    @routes = @top_level.add_module RDoc::SinatraRoutes, "Application Routes"

    @current_route = nil
  end

  #
  # Override normal meta-method parsing to handle Sinatra routes and errors.
  #
  def parse_meta_method(container, single, token, comment)
    name = token.name.upcase

    case name
    when *HTTP_VERBS
      r = parse_route_definition token
      r.comment = comment
    when "NOT_FOUND", "ERROR"
      r = parse_error_definition token
      r.comment = comment
    else
      super
    end
  end


  private

  def parse_route_definition(http_method_token)
    start_collecting_tokens
    add_token http_method_token

    token_listener(self) {
      skip_tkspace false

      pattern_token = get_tk
      route_pattern = pattern_token.text

      route_name = "#{http_method_token.name.upcase} #{route_pattern}"

      if r = @routes.find_instance_method_named(route_name)
        warn "Redefining route #{route_name}"
        @current_route = r
      else
        @current_route = RDoc::SinatraRoute.new route_name, tokens_to_s
        @routes.add_method @current_route
        @stats.add_method @current_route
      end
    }

    @current_route
  end

  def parse_error_definition(error_token)
    start_collecting_tokens
    add_token error_token

    token_listener(self) {
      skip_tkspace false

      pattern_token = get_tk

      status_codes =  if TkDO === pattern_token
                        HTTP_ERRORS["ERROR"]
                      else
                        pattern_token.text
                      end

      if error_token.name == "not_found"
        route_name = "error #{HTTP_ERRORS["NOT_FOUND"]}"
      else
        route_name = "error #{status_codes}"
      end

      if r = @routes.find_instance_method_named(route_name)
        warn "Redefining error #{error_token.name} #{pattern_token}"
        @current_route = r
      else
        @current_route = RDoc::SinatraRouteError.new route_name, tokens_to_s
        @routes.add_method @current_route
        @stats.add_method @current_route
      end
    }

    @current_route
  end


end
