require 'fileutils'
require_relative '../utils/easy_http'
require_relative 'generate_jwt_token'
require_relative 'models/certificates_models'

class Certificates
  # https://developer.apple.com/documentation/appstoreconnectapi/create_a_certificate

  def initialize(token)
    @token = token 
    @headers = {
      'Authorization' => "Bearer #{@token}",
      'Content-Type' => 'application/json'
    }
  end

  # res.code: 201 success
  def create(certificate_create_request)
    url = 'https://api.appstoreconnect.apple.com/v1/certificates'
    body = certificate_create_request.to_hash
    EasyHTTP.post(url, @headers, body)
  end

  # certificateType: DEVELOPMENT, DISTRIBUTION
  def list(query = nil)
    url = 'https://api.appstoreconnect.apple.com/v1/certificates'
    EasyHTTP.get(url, @headers, query)
  end

  def info(id)
    url = "https://api.appstoreconnect.apple.com/v1/certificates/#{id}"
    EasyHTTP.get(url, @headers)
  end
  
  # res.code: 204 success
  def revoke(id)
    url = "https://api.appstoreconnect.apple.com/v1/certificates/#{id}"
    EasyHTTP.delete(url, @headers)
  end
  
  def download(id, output_dir)
    res = info(id)
    if res.code == '200'
      data = JSON.parse(res.body)['data']
      cert_name = data['attributes']['certificateType'].downcase
      cert_content = data['attributes']['certificateContent']
      save_certificate(cert_name, cert_content, output_dir)
    end
  end

  private

  def save_certificate(cert_name, cert_content, output_dir)
    begin
      # 解码字符串
      decoded_string = Base64.decode64(cert_content)
      
      FileUtils.mkdir_p(output_dir)
      file_path = "#{output_dir}/#{cert_name}.cer"
      # 保存（下载）描述文件
      File.open(file_path, 'w') do |file|
        file.puts decoded_string
        puts "Certificate Downloaded: #{file_path}"
      end
    rescue ArgumentError => e
      # 捕捉解码错误（无效的 Base64 编码）
      puts "Error decoding Base64: #{e.message}"
      
    rescue StandardError => e
      # 捕捉其他可能的错误
      puts "An unexpected error occurred: #{e.message}"
    end
  end

end
    
if __FILE__ == $0
  token = GenerateJWTToken.test_generate_token
  certs = Certificates.new(token)
  # 创建一个证书
  #certificateType = 'DEVELOPMENT'
  #csr_file = '/Users/huangyuxun/Desktop/证书管理/CertificateSigningRequest.certSigningRequest'
  #cert_signing_request = File.read(csr_file)
  #matches = cert_signing_request.match(/-----BEGIN CERTIFICATE REQUEST-----(.*?)-----END CERTIFICATE REQUEST-----/m)
  #if matches
  #  csr_content = matches[1].gsub(/\s+/, '') #去除换行符
  #  attributes = CertifiateCreateRequest::Data::Attributes.new(certificateType, csr_content)
  #  data = CertifiateCreateRequest::Data.new(attributes, 'certificates')
  #  request = CertifiateCreateRequest.new(data)
  #  res = certs.create(request)
  #  if res.code == '201'
  #    puts "证书创建成功"
  #  end
  #end

  # 删除证书
  #id = 'NJT2S4SQ8J'
  #res = certs.revoke(id)
  #if res.code == '204'
  #  puts "#{id}证书删除成功"
  #end

  # 获取证书列表
  # query = {
  #   'limit' => 10,
  #   'filter[certificateType]' => ['DEVELOPMENT']
  # }
  #certs.list(query)
  #certs.list

  # 获取证书信息
  id = '58TTKY6QNW'
  res = certs.info(id)
  if res.code == '200' 
    res_data = JSON.parse(res.body)
    certificateType = res_data["data"]["attributes"]["certificateType"]
    puts certificateType
  end

  # 下载证书
  #id = '58TTKY6QNW'
  #certs.download(id)

end
