# app/controllers/concerns/ensures_course_access.rb
module EnsuresCourseAccess
  extend ActiveSupport::Concern

  included do
    class_attribute :trial_access_mode, default: :engage
    before_action :ensure_course_access!
  end

  class_methods do
    def trial_mode(mode) = self.trial_access_mode = mode # :start or :engage
  end

  private

  def ensure_course_access!
    course_id = params[:course_id] || params.dig(:registration, :course_id) || params[:id]
    course    = Course.find(course_id)
    gate      = Trial::Gate.new(current_user)

    allowed = case self.class.trial_access_mode
              when :start  then gate.allowed_to_start_new_course?(course)
              else               gate.allowed_to_engage?(course)
              end

    return if allowed
    redirect_to dashboard_subscriptions_path, alert: "Je proefperiode is op. Kies een lidmaatschap om verder te gaan."
  end
end
