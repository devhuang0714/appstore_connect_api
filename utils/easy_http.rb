require 'net/http'

class EasyHTTP

  def self.get(url_str, headers = {}, query = nil)
    url = URI.parse(url_str)
    url.query = URI.encode_www_form(query) unless query.nil? || query.empty?

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    
    puts "#{query}"
    request = Net::HTTP::Get.new(url, headers)
    puts("[EasyHTTP] Request Get: #{url}")
    puts("[EasyHTTP] Headers: #{headers.to_json}")
    puts("[EasyHTTP] Query: #{query.to_json}")

    response = http.request(request)

    puts("[EasyHTTP] Response code: #{response.code}")
    puts("[EasyHTTP] Response body: #{response.body}")
    return response
  end

  def self.post(url_str, headers = {}, body = nil)
    url = URI.parse(url_str)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')

    request = Net::HTTP::Post.new(url, headers)
    request.body = body.to_json unless body.nil? || body.empty?
    puts("[EasyHTTP] Request Post: #{url}")
    puts("[EasyHTTP] Headers: #{headers.to_json}")
    puts("[EasyHTTP] Body: #{body.to_json}")

    response = http.request(request)

    puts("[EasyHTTP] Response code: #{response.code}")
    puts("[EasyHTTP] Response body: #{response.body}")
    return response
  end

  def self.delete(url_str, headers = {})
    url = URI.parse(url_str)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')

    request = Net::HTTP::Delete.new(url, headers)
    puts("[EasyHTTP] Request Delete: #{url}")
    puts("[EasyHTTP] Headers: #{headers.to_json}")

    response = http.request(request)

    puts("[EasyHTTP] Response code: #{response.code}")
    puts("[EasyHTTP] Response body: #{response.body}")
    return response
  end

  def self.patch(url_str, headers = {}, body = nil)
    url = URI.parse(url_str)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')

    request = Net::HTTP::Patch.new(url, headers)
    request.body = body.to_json unless body.nil? || body.empty?
    puts("[EasyHTTP] Request Patch: #{url}")
    puts("[EasyHTTP] Headers: #{headers.to_json}")
    puts("[EasyHTTP] Body: #{body.to_json}")

    response = http.request(request)

    puts("[EasyHTTP] Response code: #{response.code}")
    puts("[EasyHTTP] Response body: #{response.body}")
    return response
  end

end

class Hash

  # 递归移除 nil 键值对
  def deep_compact
    each_with_object({}) do |(key, value), new_hash|
      new_value =
        if value.is_a?(Hash)
          value.deep_compact
        elsif value.respond_to?(:map)
          value.map { |v| v.respond_to?(:deep_compact) ? v.deep_compact : v }
        else
          value
        end

      new_hash[key] = new_value unless new_value.nil? || (new_value.respond_to?(:empty?) && new_value.empty?)
    end
  end

end
