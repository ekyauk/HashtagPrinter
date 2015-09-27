class HashtagsController < ApplicationController

    skip_before_filter :check_login, only: [:callback, :print_photo]

    SUBSCRIPTION_CALLBACK = 'http://hashtag-printer.herokuapp.com/hashtags/callback'

    def create
        hashtag = Hashtag.find_by_name(params[:hashtag][:name]) ? Hashtag.find_by_name(params[:hashtag][:name])  : Hashtag.new(hashtag_params(params[:hashtag]))
        if hashtag.users.include?(current_user)
            flash[:message] = "Already subscribed to '#{params[:hashtag][:name]}'"
        else
            hashtag.users << current_user
            if hashtag.save
                options = { object_id: params[:hashtag][:name] }
                begin
                    Instagram.create_subscription('tag', SUBSCRIPTION_CALLBACK,'media', options)
                    puts 'output above'
                    flash[:message] = "Successfully subscribed to '#{params[:hashtag][:name]}'"
                rescue Exception => e
                    hashtag.destroy
                    puts "Instagram fail: #{e}"
                    @error = "Something went wrong. Cannot subscribe to #{params[:hashtag][:name]}"
                end
            end
        end
        redirect_to :back
    end

    def callback
        puts 'SUBSCRIPTION_CALLBACK'
        puts params
        render text: params['hub.challenge']
    end

    def print_photo
        Instagram.process_subscription(request.body.read) do |handler|
            handler.on_tag_changed do |tag|
                photos = Instagram.tag_recent_media(tag).data
                for photo in photos
                    puts 'should print photo'
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
    def hashtag_params(params)
        return params.permit(:name)
    end
end
