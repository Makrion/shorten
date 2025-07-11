class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from ActionController::ParameterMissing do |exception|
    render json: { message: exception.message }, status: :bad_request
  end

  rescue_from CustomExceptions::DatabaseException do |exception|
    render json: { message: exception.message }, status: :unprocessable_entity
  end

  rescue_from CustomExceptions::InvalidUrl do |exception|
    render json: { message: exception.message }, status: :unprocessable_entity
  end

  rescue_from CustomExceptions::LinkExpired do |exception|
    render json: { message: exception.message }, status: :gone
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: {
      message: "#{exception.model.split(/(?=[A-Z])/).join(' ')} not found"
    }, status: :not_found
  end
end
