class Admin::RegistrationsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!

    def index
        @registrations = Registration.includes(:event, :user).all
    end

    def search
        @registrations = Registration.joins(:user, :event)
                                    .where("users.email LIKE ? OR events.title LIKE ?", 
                                            "%#{params[:query]}%", "%#{params[:query]}%")
        render :index
    end

    def bulk_delete
        Registration.where(id: params[:registration_ids]).destroy_all
        redirect_to admin_registrations_path, notice: "Selected registrations deleted successfully."
    end

    def export
        registrations = Registration.all
        send_data registrations.to_csv, filename: "registrations-#{Date.today}.csv"
    end

    private

    def authorize_admin!
        redirect_to root_path, alert: "Access denied" unless current_user.admin?
    end
end
