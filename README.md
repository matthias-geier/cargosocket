# cargosocket

A library based on **em-websocket** and **cargobull** to easily create a
websocket service. It hooks into the cargobull-dispatcher for an easy setup.

This code and gem is published under the BSD 2-clause license.


# Usage

Similar to **cargobull** the server requires an upstart file which requires
the gems and initializes the server. It also autoloads a **setup.rb** that
may contain additional configuration. Since **cargosocket** does not require
**rack**, simply starting the script is enough.

```ruby
  # filename: upstart.rb
  require 'cargosocket'
  require 'json'

  class Bluebeard
    include Cargobull::Service

    def channels(params)
      [params["channel"]]
    end

    def reference(params)
      params["user"]
    end

    def subscribe(ref, channel)
    end

    def unsubscribe(ref, channel)
    end

    def error(ref, channel)
    end

    def pop(ref, channel, message)
      { body: message }
    end

    def push(ref, channel, message)
      "#{channel}: #{ref} pushed #{message}"
    end
  end

  env = Cargobull.env.update(Cargobull.env.get, {
    host: "0.0.0.0",
    port: 3001,
    adapter: Cargosocket::StreamAdapters::EMChannelAdapter,
    transform_in: ->(*args) do
      next args unless args.last.is_a?(String)
      begin
        args[0...-1] << JSON.parse(args.last)
      rescue JSON::ParserError
        args
      end
    end,
    transform_out: ->(v){ v.nil? || v.empty? ? "" : JSON.dump(v) }
  })

  Cargobull.streamer(env)
```

Going through this step by step, it works similar to **cargobull**. The
class is registered by including a service module. After that the server
will be able to dispatch to it.

Backend communication between all connected websocket clients is handled
by **EM::Channel**s. These channels are identified by a named list and
a new connection finds the channels it should join by calling the **channels**
method on the service class. In our case, a connecting client can specify
the channel via GET parameter.

The **reference** method provides an identifier for the connected client.
While you could use a timestamp or a UUID, you can also allow the client
to specify its own.

```
  ws://localhost:3001/bluebeard?channel=pirates&user=blackbeard
```

This websocket call will join the client into the pirates broadcasting
channel by the reference of blackbeard.

When a client connects, disconnects or an error occurs, the associated
methods **subscribe**, **unsubscribe** and **error** are called. The
return value, unless nil, is then pushed onto the channel. With that,
you can notify other connected clients of the arrival or departure of
connected clients.

Finally when a new message is pushed onto the socket by the client, this
message passes through the **push** method. Any new message on the
respective channel will pass through the **pop** method and be returned
to the client.

So far it's pretty straight forward. The mechanism to control the channels
is the **adapter** configuration. In our example this is the EMChannelAdapter,
but you can easily roll your own.

Further configuration is required for **em-websocket**. Check the respective
documentation for the gem for configuration options. As of right now, all
of them are supported and are being passed into the websocket instance.

The final configuration are the transformers. You can of course leave them
out completely, since they are a little fiddly. For a simple text-based
service they are not necessary. Even JSON can work without, you need to
parse and dump your JSON strings manually then. A word of advice though,
when available, the **transform_in** option has the **ref** as first argument.

Returning **nil** values for the callback methods will lead them to be
ignored in the processing. So if you need no notification for new clients,
leave the **subscribe** method and have it return nil. When **reference**
returns nil or **channels** does not return an array of strings or symbols,
the connecting client will automatically rejected.

Sidenote: you cannot and should not start the websocket inside the
**setup.rb**!


# Testing websockets and irb

Since websockets are concurrent, you should consider testing the service
as a whole through one or more websocket clients. There is no reliable way
to integration-test your application without using a websocket client.
This also means, no easy irb support for your application.

Your units on the other hand can be tested similarily to **cargobull**.
Look at the **CargobullAdapter** which just forwards your call.

```ruby
  before do
    @env = Cargobull.env.get # should be your env, with transformers
  end

  it "should filter the correct channel from params" do
    cb_adapter = Cargosocket::StreamAdapters::CargobullAdapter
    assert_equal ['pirates'], cb_adapter.
      channels(@env, 'bluebeard', { 'channel' => 'pirates' })
  end
```

The **CargobullAdapter** can of course also be used in irb.


# Example

Building on the example from **cargobull**, it includes a consumer
of the websocket and through it sorts of a channel-based webchat.
Clients can create channels and join them with a username, chat and
leave again.

The example has the same dependencies as before, **json** and **redis**.
Plus the **cargobull** gem.

```bash
  git clone git@github.com:matthias-geier/cargosocket
  cd cargosocket/example

  # first shell
  thin start

  # second shell
  # leave the -I../lib if you have cargosocket installed
  ruby -I../lib upstart.rb
```

Navigate to the host and port of the service, usually **localhost:3000**
in your web browser and you will be able to see the web service in action.


# Tests

Running the existing test suite for **cargosocket** is simple. Checkout
the master, navigate into the git root and run:

```bash
  ruby -Ilib test/test_runner.rb
```

The dependency of this is the **cargobull** gem.

