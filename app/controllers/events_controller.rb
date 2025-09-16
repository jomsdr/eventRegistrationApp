class EventsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_event, only: [:show, :edit, :update, :destroy, :join :leave]

    def index
        @events = Event.all
        render json: @events
    end

    def show
        render json: @event
    end

    def create
        @event = current_user.created_events.build(event_params)

        if @event.save
            render json: @event, status: :created
        else
            render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def update
        if @event.update(event_params)
            render json: @event
        else
            render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def destroy
        @event.destroy
        head :no_content
    end

    # registrations controller create and destroy update
    def join
        registration = current_user.event_registrations.build(event: @event)
        if registration.save
            render json: { message: "Successfully joined the event!" }
        else
            render json: { errors: registration.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def leave
        registration = current_user.event_registrations.find_by(event_id: @event.id)
        if registration&.destroy
            render json: { message: "Successfully left the event." }
        else
            render json: { message: "You are not part of this event." }, status: :unprocessable_entity
        end
    end

    private

    def set_event
        @event = Event.find(params[:id])
    end

    def event_params
        params.require(:event).permit(:title, :description, :date, :location)
    end
end
