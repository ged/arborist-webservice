# Arborist-Webservices

home
: http://bitbucket.org/ged/Arborist-Webservice

github
: https://github.com/ged/arborist-webservice

docs
: http://deveiate.org/code/arborist-webservice


## Description

This is a collection of webservice monitoring tools for the Arborist monitoring toolkit (http://arbori.st/).

It can be used to describe and monitor HTTP services in more detail than a simple port check.


### Examples

Webservice nodes, like `service` nodes, are specified under a `host` node, which should be a single
instance of physical hardware that is hosting the service.

The simplest example is an unauthenticated REST service running on port 80:

    Arborist::Host 'example-webserver' do
        address 'ws01-01.example.com'
        webservice 'api-v1', 'http://api.example.com/v1/heartbeat'
    end

This adds a `webservice` child node to the containing host with an identifier of
`example-webserver-api-vi`.

The simplest monitor setup to monitor that service might look something like:

    # -*- ruby -*-
    #encoding: utf-8
    
    require 'arborist/monitor/webservice'
    Arborist::Monitor::Webservice::HTTP.default

This would check that an HEAD HTTP request to `http://api.example.com/v1/heartbeat` responds with a 2xx status code.


## Prerequisites

* Ruby


## Installation

    $ gem install arborist-webservice


## Contributing

You can check out the current development source with Mercurial via its
{project page}[http://bitbucket.org/ged/arborist-webservice]. Or if you prefer Git, via 
{its Github mirror}[https://github.com/ged/arborist-webservice].

After checking out the source, run:

    $ rake newb

This task will install any missing dependencies, run the tests/specs,
and generate the API documentation.


## License

Copyright (c) 2016-2018, Michael Granger
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the author/s, nor the names of the project's
  contributors may be used to endorse or promote products derived from this
  software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


