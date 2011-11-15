rdoc-sinatra
------------

RDoc plugin for documenting Sinatra applications.


Homepage and Bugtracker
=======================

https://github.com/rdoc/rdoc-sinatra


Requirements
============

- rdoc 3+


Installation
============

`$ gem install rdoc-rake`


Usage
=====

`$ rdoc FILE_OR_DIR […]`

The plugin extracts documentation for route definitions marked with
a double-hash (that bit is important):

    ##
    # This is your documentation.
    #
    # And then some.
    #
    get "/foo" do
      :yay
    end

This plugin augments the normal RDoc Ruby parser, so that you can
generate the documentation along with the rest of your methods.

The route docs are placed under a fake class called Application Routes.


Limitations/TODO
================

- Currently all routes are parsed into the top-level Application Routes.
This'll probably change in the next version.
- Does not actually parse the route patterns, so parameters and so
on aren't documented separately (you'll just see the entire pattern).



Licence
=======

(The MIT License)

Copyright (c) 2011 Eero Saynatkari

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

