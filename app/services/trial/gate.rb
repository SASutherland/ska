# app/services/trial/gate.rb
module Trial
  class Gate
    def initialize(user) = @user = user

    # Use for "Start course" actions
    def allowed_to_start_new_course?(_course)
      return true if bypass?
      return true if @user.trial_active? && !@user.trial_limit_reached?
      false
    end

    # Use for answering/visiting a course
    def allowed_to_engage?(course)
      return true if bypass?
      return true unless @user.trial_active?  # not in trial => free to engage (e.g., inactive but not trialing)
      return true unless @user.trial_limit_reached? # still under limit => ok

      # Limit reached: only allow if THIS course was already started (counted)
      TrialStart.exists?(user: @user, course: course)
    end

    private

    def bypass?
      @user.admin? || @user.teacher? || @user.active_subscription.present?
    end
  end
end
