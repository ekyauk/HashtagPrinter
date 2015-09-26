class HashtagsController < ApplicationController
    SUBSCRIPTION_CALLBACK = 'http://hashtag-printer.herokuapp.com/hashtags/callback'
    def create
        hashtag = Hashtag.where(name: params[:hashtag][:name]).first ?? Hashtag.new(hashtag_params(params[:hashtag]))
        hashtag.users << current_user.id
        if hashtag.save
            options = { object_id: params[:hashtag][:name] }
            puts Instagram.create_subscription('tag', SUBSCRIPTION_CALLBACK,'media', options)
            puts 'output above'
            flash[:message] = "Successfully subscribed to '#{params[:hashtag][:name]}'"
        end
        render controller: :home, action: :index
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

    private
    def hashtag_params(params)
        return params.permit(:name)
    end
end
