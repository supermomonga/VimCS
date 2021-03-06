require 'mini_magick'
require 'net/http'
require 'uri'

class VimCheetSheet

  def overlay_remote(img_url)
    file_name = "./img_tmp_remote/#{ Time.now.to_i }_#{ File.basename img_url }" 
    begin
      open(file_name, 'wb') do |file|
        uri = URI.parse(img_url)
        http = Net::HTTP.new(uri.host, uri.port)
        if /^https:\/\// =~ img_url
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
        file.puts response.body
      end
      overlay file_name
    rescue
      nil
    end
  end

  def overlay(img_path)
    image = MiniMagick::Image.open( img_path , 'png')
    overlay = MiniMagick::Image.open('./resources/2560x1600_transparent_blur.png','png')
    overlay.resize "#{ image[:width] }x#{ image[:height] }!"
    puts
    result = image.composite overlay do |c|
      c.resize "#{ image[:width] }x#{ image[:height] }!"
      c.gravity 'center'
      c.quality '100'
    end
    result_path = "./img_tmp_local/#{ Time.now.to_i }.png"
    result.write result_path
    result_path
  end
  
end
