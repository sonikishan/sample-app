class MicropostsController < ApplicationController
  include SessionsHelper

  before_filter :authenticate, :only => [:create, :destroy]
  before_filter :authorized_user, :only => :destroy

  # GET /microposts
  def index

  end

  # POST /microposts
  def create
    @micropost = current_user.microposts.build(params[:micropost])

    if @micropost.save
      flash[:success] = "Micropost created successfully."

      redirect_to(root_path)
    else
      @feed_items = []
      render('pages/home')
    end
  end

  # DELETE /microposts/1
  def destroy
    @micropost.destroy
    redirect_back_or(root_path)
  end

  private

    def authorized_user
      @micropost = Micropost.find(params[:id])
      redirect_to(root_path) unless current_user?(@micropost.user)
    end

end
