class HashtagsController < ApplicationController

    skip_before_filter :check_login, only: [:callback, :print_photo]
    protect_from_forgery except: :print_photo


    def create
        hashtag = Hashtag.find_by_name(params[:hashtag][:name]) ? Hashtag.find_by_name(params[:hashtag][:name])  : Hashtag.new(hashtag_params(params[:hashtag]))
        if hashtag.users.include?(current_user)
            flash[:message] = "Already subscribed to '#{params[:hashtag][:name]}'"
        else
            hashtag.users << current_user
            if hashtag.save
                hashtag.create_subscription(current_user.id)
            end
        end
        redirect_to :back
    end

    def callback
        render text: params['hub.challenge']
    end

    def print_photo
        puts 'SUBSCRIPTION_CALLBACK'
        Instagram.process_subscription(request.body.read) do |handler|
            handler.on_tag_changed do |tag|
                photos = Instagram.tag_recent_media(tag)
                for photo_hash in photos
                    photo_url = photo_hash['images']['standard_resolution']['url']
                    puts "about to print #{photo_url}"
                    puts sendToGCP(photo_url, params[:id]).body
                end
            end
        end
    end

    def delete
        if params[:id].nil?
            Instagram.delete_subscription(object: 'tag')
            Hashtag.destroy_all
        else
            Instagram.delete_subscription(object: 'tag', object_id: params[:id])
            Hashtag.destroy_all(name: params[:id])

        end
        redirect_to :back
    end

    private

    def sendToGCP(photo_url, printer_id)
        access_token = session[:google_oauth_token]
        uri = URI("https://www.google.com/cloudprint/submit")
        fields = {
            client_id: ENV['GOOGLE_CLIENT_ID'],
            access_token: access_token,
            printerid: printer_id,
            title: 'Hashtag Printer',
            ticket: {},
            content: photo_url,
            content_type: 'url'
        }

        uri.query = URI.encode_www_form(params)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        req = Net::HTTP::Post.new(uri.request_uri)
        req.add_field('X-CloudPrint-Proxy', '0.0.0.0')
        res = http.request(req)
    end

    def hashtag_params(params)
        return params.permit(:name)
    end
end
