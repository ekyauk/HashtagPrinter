require 'net/http'
require 'json'

class PrintersController < ApplicationController

    def index
        access_token = session[:google_oauth_token]
        uri = URI("https://www.google.com/cloudprint/search")
        params = {
            :client_id => ENV['GOOGLE_CLIENT_ID'],
            :access_token => access_token
        }

        uri.query = URI.encode_www_form(params)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        req = Net::HTTP::Get.new(uri.request_uri)
        req.add_field('X-CloudPrint-Proxy', '0.0.0.0')
        res = http.request(req)
        if res.code == '200'
            @printer_info = JSON.parse(res.body)
        end
    end

    def info
        access_token = session[:google_oauth_token]
        uri = URI("https://www.google.com/cloudprint/printer")
        fields = {
            client_id: ENV['GOOGLE_CLIENT_ID'],
            access_token:  access_token,
            printerid: params[:id]
        }

        uri.query = URI.encode_www_form(fields)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        req = Net::HTTP::Get.new(uri.request_uri)
        req.add_field('X-CloudPrint-Proxy', '0.0.0.0')
        res = http.request(req)
        puts JSON.pretty_generate(JSON.parse(res.body)['printers'])
        if res.code == '200'
            @printer_info = JSON.parse(res.body)['printers']
        end
    end
end
