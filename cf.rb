# cf.rb
# Cloudflare settings

require 'net/http'
require 'openssl'
require 'logger'

class CloudFlare
  def self.zone_id
    "8c029dad95bd8d6414c62a4889e7fa81"
  end

  def self.api_key
    ENV["CLOUDFLARE_API_KEY"]
  end

  def self.email
    ENV["CLOUDFLARE_EMAIL"]
  end

  def self.authenticated?(req_zone)
    false
    if zone_id == req_zone
      true
    end
  end

  def self.purge_cache(zone)
    logger = Logger.new(STDOUT)
    logger.level = Logger::INFO
    ### EXAMPLE ###
    # curl -X POST "https://api.cloudflare.com/client/v4/zones/023e105f4ecef8ad9ca31a8372d0c353/purge_cache" \
    #  -H "X-Auth-Email: user@example.com" \
    #  -H "X-Auth-Key: c2547eb745079dac9320b638f5e225cf483cc5cfdda41" \
    #  -H "Content-Type: application/json" \
    #  --data '{"purge_everything":true}'

    uri = URI.parse("https://api.cloudflare.com")
    ep = "/client/v4/zones/#{zone}/purge_cache"
    logger.info("Querying #{uri}#{ep}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(ep)
    request.add_field('Content-Type', 'application/json')
    request.add_field('X-Auth-Email', email)
    request.add_field('X-Auth-Key', api_key)
    request.body = '{"purge_everything": true}'
    response = http.request(request)
    if response.code != "200"
      raise RuntimeError, "CloudFlare cache was not successful. Response: #{response.code}"
    else
      logger.info("Purge OK.")
    end
  end
end