require "net/http"
require "json"
require "uri"

class HttpJson
  Error = Class.new(StandardError)

  def initialize(base_url:, headers: {})
    @base_url = base_url.to_s.chomp("/")
    @headers = headers
  end

  def get(path)
    request(Net::HTTP::Get, path)
  end

  def post(path, body = {})
    request(Net::HTTP::Post, path, body)
  end

  def patch(path, body = {})
    request(Net::HTTP::Patch, path, body)
  end

  private

  def request(klass, path, body = nil)
    uri = URI.join("#{@base_url}/", path.sub(%r{^/}, ""))
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.read_timeout = 15
    req = klass.new(uri)
    @headers.each { |key, value| req[key] = value }
    req["Content-Type"] = "application/json"
    req["Accept"] = "application/json"
    req.body = JSON.generate(body) if body
    response = http.request(req)
    parsed = parse(response.body)
    unless response.is_a?(Net::HTTPSuccess)
      raise Error, "HTTP #{response.code} #{uri}: #{parsed.inspect}"
    end
    parsed
  end

  def parse(body)
    return {} if body.blank?
    JSON.parse(body)
  rescue JSON::ParserError
    { "raw" => body }
  end
end
