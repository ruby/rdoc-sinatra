# -*- encoding: utf-8 -*-

require "stringio"
require "tempfile"

require "rdoc"
require "rdoc/parser/sinatra"

require "minitest/autorun"


class TestRDocParserSinatra < MiniTest::Unit::TestCase

  def setup
    @tempfile = Tempfile.new self.class.name
    @filename = @tempfile.path

    RDoc::TopLevel.reset
    @top_level = RDoc::TopLevel.new @filename

    @options = RDoc::Options.new
    @options.quiet = true
    @stats = RDoc::Stats.new 0

    @route_definitions = @routes = nil
  end

  def teardown
    @tempfile.close
  end



  def test_routes_stored_in_top_level_application_routes_class_hiding_in_modules
    app = <<-APP
    require "sinatra"

    ##
    # Route 1
    #
    get "/foo" do
      :hi
    end
    APP

    make_a_parser_for app
    @parser.scan

    r = RDoc::TopLevel.find_module_named "Application Routes"
    r.wont_be_nil

    r.method_list.first.name.must_equal 'GET "/foo"'
  end

  def test_route_presented_as_http_method_and_route_pattern
    app = <<-APP
    require "sinatra"

    ##
    # Route 2
    #
    # Some more text goes here.
    #
    get "/foo" do
      :hi
    end
    APP

    make_a_parser_for app
    extract_routes
    
    r = @routes.first

    r.name.must_equal 'GET "/foo"'
    r.comment.text.must_equal "Route 2\n\nSome more text goes here."
  end

  def test_route_pattern_may_be_regexp
    app = <<-APP
    require "sinatra"

    ##
    # Route 3
    #
    get /foo/ do
      :hi
    end

    ##
    # Route 4
    #
    get %r{bar} do
      :ho
    end
    APP

    make_a_parser_for app
    extract_routes
    
    @routes.size.must_equal 2

    r = @routes.first
    r.name.must_equal 'GET /foo/'
    r.comment.text.must_equal "Route 3"

    r = @routes.last
    r.name.must_equal 'GET %r{bar}'
    r.comment.text.must_equal "Route 4"
  end


  %w[GET HEAD POST PUT PATCH DELETE OPTIONS].each {|http|
    define_method("test_parses_#{http}_definition") {
      make_a_parser_for define_all_the_things!
      extract_routes

      @routes.find {|r| r.name.include? http }.wont_be_nil
    }
  }

  def test_parses_error_definitions_without_status_code_defaulting_to_500
    app = <<-APP
    require "sinatra"

    ##
    # Gettersy
    #
    get "foo" do
      :hi
    end

    ##
    # OMG ERROR
    #
    error do
      :haha
    end
    APP

    make_a_parser_for app
    extract_routes
    
    @routes.size.must_equal 2

    r = @routes.last
    r.name.must_equal "error 500"
  end

  def test_parses_error_definitions_with_status_codes
    app = <<-APP
    require "sinatra"

    ##
    # Getters
    #
    get "foo" do
      :hi
    end

    ##
    # Fourohthree
    #
    error 403 do
      :haha
    end
    APP

    make_a_parser_for app
    extract_routes
    
    @routes.size.must_equal 2

    r = @routes.last
    r.name.must_equal "error 403"
  end

  def test_parses_not_found_definition_into_a_404_error
    app = <<-APP
    require "sinatra"

    ##
    # Route 5
    #
    get "foo" do
      :hi
    end

    ##
    # Route 6
    #
    not_found do
      :haha
    end
    APP

    make_a_parser_for app
    extract_routes
    
    @routes.size.must_equal 2

    r = @routes.last
    r.name.must_equal "error 404"
  end

  def test_parses_same_route_pattern_with_different_methods_as_separate
    app = <<-APP
    require "sinatra"

    ##
    # Route 7
    #
    get "foo" do
      :hi
    end

    ##
    # Route 8
    #
    put "foo" do
      :ho
    end
    APP

    make_a_parser_for app
    extract_routes
    
    @routes.size.must_equal 2

    r = @routes.first
    r.name.must_equal 'GET "foo"' 

    r = @routes.last
    r.name.must_equal 'PUT "foo"'
  end

  def test_parses_same_route_pattern_with_same_method_as_the_same_and_latter_overrides
    app = <<-APP
    require "sinatra"

    ##
    # Initial definition
    #
    get "foo" do
      :hi
    end

    ##
    # YAY OVERRIDE
    #
    get "foo" do
      :ho
    end
    APP

    make_a_parser_for app
    extract_routes
    
    @routes.size.must_equal 1

    r = @routes.first
    r.name.must_equal 'GET "foo"' 
    r.comment.text.must_equal "YAY OVERRIDE"
  end

# May end up not doing this at all.
#  def test_get_definitions_automatically_add_a_head_definition_with_same_comment
#    flunk
#  end

  def test_allows_normal_ruby_docs_to_be_mixed_in_same_doc
    app = <<-APP
    require "sinatra"

    ##
    # Route def
    #
    get "foo" do
      :hi
    end

    #
    # Random method
    #
    def foo; end

    #
    # Random class
    #
    class Yay

      ##
      # Random metamethod
      #
      some_meta :metafoo

      #
      # Random method in a class
      #
      def yayfoo; end
    end
    APP

    make_a_parser_for app
    extract_routes

    @routes.size.must_equal 1

    o = RDoc::TopLevel.find_class_named "Object"
    o.method_list.first.name.must_equal "foo"

    y = RDoc::TopLevel.find_class_named "Yay"
    y.method_list.size.must_equal 2

    y.method_list.shift.name.must_equal "metafoo"
    y.method_list.shift.name.must_equal "yayfoo"
  end

  def test_parses_route_inside_a_class_definition
    app = <<-APP
    require "sinatra"

    class Yay < Sinatra::Base
      ##
      # Route 9
      #
      get "foo" do
        :hi
      end
    end
    APP

    make_a_parser_for app
    extract_routes
    
    @routes.size.must_equal 1

    r = @routes.first
    r.name.must_equal 'GET "foo"' 
  end

#  def test_parses_route_inside_a_sinatra_base_inheriting_class_only
#    flunk
#  end
#
#  def test_parses_route_inside_a_base_class_into_that_class_not_application_routes
#    flunk
#  end


  private

  def make_a_parser_for(content)
    @parser = RDoc::Parser::Sinatra.new @top_level, @filename, content, @options, @stats
  end

  def extract_routes
    @parser.scan
    @route_definitions = RDoc::TopLevel.find_module_named "Application Routes"
    @routes = @route_definitions.method_list
  end

  def define_all_the_things!
    <<-END
require "sinatra"

##
# GET route
#
get "/foo" do
  "hi"
end

##
# HEAD route
#
head "/bar" do
  "ho"
end

##
# POST route
#
post "/foo/:id" do
  :yay
end

##
# PUT route
#
put "/foo/:id" do
  :yay
end

##
# DELETE route
#
delete %r{hi there} do
  :ugg
end

##
# PATCH route
#
patch /foo^bar/ do
  :mug
end

##
# OPTIONS route
#
options "foo/" do
  :whatevs
end
    END
  end
end
