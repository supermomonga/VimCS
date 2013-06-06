
require 'net/http'

class Gyazo

  attr_reader :id

  def initialize(id = '',
                 boundary = '----BOUNDARYBOUNDARY----',
                 host = 'gyazo.com',
                 cgi = '/upload.cgi',
                 ua = 'Gyazo/1.0')
    @id = id
    @boundary = boundary
    @host = host
    @cgi = cgi
    @ua   = ua
  end

  def upload(img_path)

    if !File.exists? img_path
      exit
    end

    img = File.read img_path

    data = <<EOF
--#{@boundary}\r
content-disposition: form-data; name="id"\r
\r
#{@id}\r
--#{@boundary}\r
content-disposition: form-data; name="imagedata"; filename="gyazo.com"\r
\r
#{img}\r
--#{@boundary}--\r
EOF

    header ={
      'Content-Length' => data.length.to_s,
      'Content-type' => "multipart/form-data; @boundary=#{@boundary}",
      'User-Agent' => @ua
    }

    env = ENV['http_proxy']
    if env then
      uri = URI(env)
      proxy_host, proxy_port = uri.host, uri.port
    else
      proxy_host, proxy_port = nil, nil
    end

    url = ''
    Net::HTTP::Proxy(proxy_host, proxy_port).start(@host,80) {|http|
      res = http.post(@cgi,data,header)
      url = res.response.body
      newid = res.response['X-Gyazo-Id']
      @id = newid if @id == '' and newid and newid != ''
    }

    "#{ url }.png"
  end
  
end
