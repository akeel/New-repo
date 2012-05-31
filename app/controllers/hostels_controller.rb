class HostelsController < ApplicationController

	before_filter :login_required
  
  def index
    @hostels = Hostel.all
  end

  def new
    @hostel = Hostel.new
  end

  def create
    @hostel= Hostel.new(params[:hostel])
    if @hostel.save
    flash[:notice] = 'New House Added Successfully.'
    redirect_to "/hostels"
    else
		flash[:notice] = 'Please fill the field'
		redirect_to :back
    end
  end

  def edit
  	@hostel = Hostel.find(params[:id]) 
  end

  def update
  	@hostel = Hostel.find(params[:id])
    if @hostel.update_attributes(params[:hostel])
      flash[:notice] = 'Updated hostel details successfully.'
      redirect_to "/hostels"
    else
      flash[:notice] = "Please fill the field"
      redirect_to  :back
    end
  end

  def destroy
     @hostel = Hostel.find(params[:id])
		 if @hostel.destroy
		 flash[:notice] = 'House Destroyed Successfully'
		 redirect_to :back
		 else
      flash[:notice] = "Could not destroy the house"
      redirect_to  :back
     end
  end


end
