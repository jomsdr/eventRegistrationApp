class Admin::RegistrationsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!


    def index
        @registrations = EventRegistration.includes(:event, :user).all
        render json: @registrations.as_json(include: { event: { only: [:id, :title] }, user: { only: [:id, :name, :email] } })
    end


    def search
        @registrations = EventRegistration.joins(:user, :event)
                                    .where("users.email LIKE ? OR events.title LIKE ?", 
                                            "%#{params[:query]}%", "%#{params[:query]}%")
        render :index
    end

    def destroy
        registration = EventRegistration.find(params[:id])
        registration.destroy
        head :no_content
    end

    def bulk_delete
        ids = params[:registration_ids] || params[:ids] || params.dig(:registration, :registration_ids)
        EventRegistration.where(id: ids).destroy_all
        if request.format.json?
            render json: { success: true }
        end
    end


    def export
        registrations = EventRegistration.all
        send_data registrations.to_csv, filename: "registrations-#{Date.today}.csv"
    end

    private

    def authorize_admin!
        redirect_to root_path, alert: "Access denied" unless current_user.admin?
    end
end
