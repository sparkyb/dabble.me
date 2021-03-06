class AdminController < ApplicationController
  before_action :authenticate_user!, except: [:mailgun]
  before_action :authenticate_admin!, except: [:mailgun]
  skip_before_action :verify_authenticity_token, only: [:mailgun]

  def users
    if params[:email].present?
      users = User.where("email LIKE '%#{params[:email].downcase}%'")
    elsif params[:user_key].present?
      users = User.where("user_key LIKE '%#{params[:user_key]}%'")
    else
      users = User.all
    end
    @user_list = users.order('id DESC').page(params[:page]).per(params[:per])
    render 'users'
  end

  def photos
    @entries = Kaminari.paginate_array(Entry.only_images.order('id DESC')).page(params[:page]).per(params[:per])
  end

  def stats
    @dashboard = AdminStats.new
  end

end
