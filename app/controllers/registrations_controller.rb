class RegistrationsController < ApplicationController
  # GET /events/:event_id/registrations/:id
  def show
    event = Event.find_by(id: params[:event_id])
    unless event
      render json: { error: 'Event not found' }, status: :not_found and return
    end
    registration = event.event_registrations.find_by(id: params[:id])
    unless registration
      render json: { error: 'Registration not found' }, status: :not_found and return
    end
    render json: { id: registration.id, name: registration.name, email: registration.email }
  end
  # GET /events/:event_id/registrations
  def index
    event = Event.find_by(id: params[:event_id])
    unless event
      render json: { error: 'Event not found' }, status: :not_found and return
    end
    registrations = event.event_registrations.select(:id, :name, :email)
    render json: registrations
  end

  # POST /events/:event_id/registrations
  def create
    event = Event.find_by(id: params[:event_id])
    unless event
      render json: { error: 'Event not found' }, status: :not_found and return
    end

      # Find user by exact (case-sensitive) email
      user = User.find_by(email: registration_params[:email])
      unless user
        render json: { error: 'Email does not exist in our records.' }, status: :unprocessable_entity and return
      end

    registration = event.event_registrations.new(registration_params.merge(user_id: user.id))
    
    if registration.save
      render json: registration, status: :created
    else
      render json: { error: registration.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  def update
    event = Event.find_by(id: params[:event_id])
    unless event
      render json: { error: 'Event not found' }, status: :not_found and return
    end

    registration = event.event_registrations.find_by(id: params[:id])
    unless registration
      render json: { error: 'Registration not found' }, status: :not_found and return
    end

    name = params[:registration][:name]
    email = params[:registration][:email]
    unless name.present? && email.present?
      render json: { error: 'Name and email are required.' }, status: :unprocessable_entity and return
    end
    unless email.match?(/\A[^\s@]+@[^\s@]+\.[^\s@]+\z/)
      render json: { error: 'Email is invalid.' }, status: :unprocessable_entity and return
    end
    user = User.find_by(email: email)
    unless user
      render json: { error: 'Email does not exist in our records.' }, status: :unprocessable_entity and return
    end

    if registration.update(name: name, email: email, user_id: user.id)
      render json: registration, status: :ok
    else
      render json: { error: registration.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  # DELETE /events/:event_id/registrations/:id
  def destroy
    event = Event.find_by(id: params[:event_id])
    unless event
      render json: { error: 'Event not found' }, status: :not_found and return
    end
    registration = event.event_registrations.find_by(id: params[:id])
    unless registration
      render json: { error: 'Registration not found' }, status: :not_found and return
    end
    registration.destroy
    render json: { message: 'Registration deleted' }, status: :ok
  end

  private

  def registration_params
    params.require(:registration).permit(:name, :email)
  end
end
