class UsersController < ApplicationController

def index
    puts 'called users/index'
end

def add_printer
    current_user.printer_id = params[:id]
    puts 'pinrtayuntwfyutatnwfuynt'
    puts current_user.printer_id
    current_user.save
    redirect_to '/printers'
end

end
