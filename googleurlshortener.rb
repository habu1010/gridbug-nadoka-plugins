require 'json'
require 'net/https'

class GoogleURLShortener
  def initialize(api_key = nil)
    if api_key.nil?
      open(File.expand_path("~/.google-api-key")) do |f|
        @api_key = f.gets.strip
      end
    else
      @api_key = api_key
    end

    @https = Net::HTTP.new('www.googleapis.com', 443)
    @https.use_ssl = true
    @https.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  def shorten_url(url)
    response = nil
    @https.start do |h|
      request = Net::HTTP::Post.new("/urlshortener/v1/url?key=#{@api_key}",
                                    {'Content-Type' => 'application/json'})
      request.body = {"longUrl" => url}.to_json

      response = h.request(request)
    end

    if Net::HTTPOK === response
      body = JSON.parse(response.body)
      return body["id"]
    end

    return "Google URL Shortener Error"
  end
end

if __FILE__ == $0
  s = GoogleURLShortener.new
  puts s.shorten_url('http://hengband.sourceforge.jp/')
end
