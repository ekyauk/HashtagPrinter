class HashtagsController < ApplicationController

    skip_before_filter :check_login, only: [:callback, :print_photo]
    protect_from_forgery except: :print_photo

    CLOUD_PRINT_URL = 'https://www.google.com/cloudprint/submit'

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
                    sendToGCP(photo_url, params[:id])
                end
            end
        end
    end

    def delete
        if params[:id].nil?
            puts 'Deleting all tags'
            Instagram.delete_subscription(object: 'tag')
            Hashtag.destroy_all
        else
            Instagram.delete_subscription(object: 'tag', object_id: params[:id])
            Hashtag.destroy_all(name: params[:id])

        end
        redirect_to :back
    end

    private

    def sendToGCP(photo_url, user_id)
        user = User.find(user_id)
        uri = URI(CLOUD_PRINT_URL)
        if (user.google_oauth_token != nil)
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE

            #if a printer is selected
            if user.printer_id != nil
                photo_req = printPhotoRequest(user, photo_url)
                res = http.request(photo_req)
                puts 'first response'
                puts res

                #if the google access token needs to be renewed
                if res.code == '403'
                    puts 'renewing google access token'
                    user.renew_google_access_token
                    photo_req = printPhotoRequest(user, photo_url)
                    res = http.request(photo_req)
                end
            end

            #if it should save to gdrive
            if user.save_to_gdrive
                gdrive_save_req = saveToDriveRequest(user.google_oauth_token, photo_url)
                gdrive_res = http.request(gdrive_save_req)

                #if the google access token needs to be renewed
                if gdrive_res.code == '403'
                    puts 'renewing google access token'
                    user.renew_google_access_token
                    gdrive_save_req = saveToDriveRequest(user.google_oauth_token, photo_url)
                    gdrive_res = http.request(gdrive_save_req)
                end
            end
        end
    end

    def printPhotoRequest(user, photo_url)
        uri = URI(CLOUD_PRINT_URL)
        fields = {
            client_id: ENV['GOOGLE_CLIENT_ID'],
            printerid: user.printer_id,
            title: 'Hashtag Printer',
            ticket: {'version' => '1.0', 'print' => {}},
            content: photo_url,
            contentType: 'url'
        }
        puts fields

        req = Net::HTTP::Post.new(uri.request_uri)
        req.set_form_data(fields)
        req.add_field('Authorization', "OAuth #{user.google_oauth_token}")
        req.add_field('X-CloudPrint-Proxy', '0.0.0.0')
        return req

    end

    def saveToDriveRequest(access_token, photo_url)
        uri = URI(CLOUD_PRINT_URL)
        fields = {
                client_id: ENV['GOOGLE_CLIENT_ID'],
                printerid: '__google__docs',
                title: 'Hashtag Printer Picture',
                ticket: {'version' => '1.0', 'print' => {}},
                content: photo_url,
                contentType: 'url'
        }
        req = Net::HTTP::Post.new(uri.request_uri)
        req.set_form_data(fields)
        req.add_field('Authorization', "OAuth #{access_token}")
        req.add_field('X-CloudPrint-Proxy', '0.0.0.0')
        return req

    end

    def hashtag_params(params)
        return params.permit(:name)
    end
end
