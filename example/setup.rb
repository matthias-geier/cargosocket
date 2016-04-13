require 'json'
require 'redis'

Cargobull::Initialize.dir "controller"

$env = Cargobull.env.update(Cargobull.env.get, {
  default_path: "index.html",
  ctype: "application/json",
  e403: { status: 403, body: "Forbidden" }.to_json,
  e404: { status: 404, body: "Not found" }.to_json,
  e405: { status: 405, body: "Method not allowed" }.to_json,
  e500: { status: 500, body: "Internal error" }.to_json,
  transform_in: ->(v) do
    begin
      v[:body] = JSON.parse(v[:body].read) if v[:body].respond_to?(:read)
      [v]
    rescue JSON::ParserError
      [v]
    end
  end,
  transform_out: ->(v){ JSON.dump(v) }
})

if Gem.loaded_specs.has_key?('em-websocket')
  $env = Cargobull.env.update($env, {
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
end
