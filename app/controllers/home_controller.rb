class HomeController < ApplicationController

    def index
        render controller: :user, action: :index
    end

end
