class Admin::EventsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!

    def index
        @events = Event.all
        render json: @events
    end

    def search
        @events = Event.where("title LIKE ?", "%#{params[:query]}%")
        render :index
    end

    def destroy
        event = Event.find(params[:id])
        event.destroy
        head :no_content
    end

    def bulk_delete
        ids = params[:event_ids] || params[:ids] || params.dig(:event, :event_ids)
        Event.where(id: ids).destroy_all
        if request.format.json?
            render json: { success: true }
        end
    end

    def export
        events = Event.all
        send_data events.to_csv, filename: "events-#{Date.today}.csv"
    end

    private

    def authorize_admin!
        redirect_to root_path, alert: "Access denied" unless current_user.admin?
    end
end
