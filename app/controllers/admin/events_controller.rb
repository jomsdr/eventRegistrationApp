class Admin::EventsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!

    def index
        @events = Event.all
    end

    def search
        @events = Event.where("title LIKE ?", "%#{params[:query]}%")
        render :index
    end

    def bulk_delete
        Event.where(id: params[:event_ids]).destroy_all
        redirect_to admin_events_path, notice: "Selected events deleted successfully."
    end

    def bulk_close
        Event.where(id: params[:event_ids]).update_all(status: "closed")
        redirect_to admin_events_path, notice: "Selected events closed successfully."
    end

    private

    def authorize_admin!
        redirect_to root_path, alert: "Access denied" unless current_user.admin?
    end
end
