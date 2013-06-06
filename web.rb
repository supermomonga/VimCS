# -*- encoding: utf-8 -*-

require 'rubygems'
require 'sinatra'
require 'haml'
require 'json'

load 'vimcheatsheet.rb'
load 'gyazo.rb'


get '/' do
  haml :index
end

post '/generate' do
  content_type :text
  res = {
    status: 'error'
  }
  if params[:url]
    cs = VimCheetSheet.new
    begin
      result_path = cs.overlay_remote params[:url]
      if result_path
        gyazo = Gyazo.new '54bd49da75d131e7416544ed649b20e6'
        gyazo_url = gyazo.upload result_path
        res[:status] = 'ok'
        res[:url] = gyazo_url
      else
        res[:message] = "画像を取得できな…かっ……た…"
      end
    rescue
      res[:message] = "画像の合成がむずかしかった"
    end
  else
    res[:message] = '画像を指定されてない気がする'
  end
  res.to_json
end

