# app/services/trial/usage_recorder.rb
module Trial
  class UsageRecorder
    TRIAL_LIMIT = 3

    def initialize(user)
      @user = user
    end

    # Call this from ANY student-triggered place (start, first answer, deep link)
    # Pass a source so you can see where it came from.
    def record_course_started!(course, source: nil)
      return if bypass?
      return if @user.trial_limit_reached?

      created = nil
      ApplicationRecord.transaction do
        # Will raise on unique violation; we treat that as "already recorded"
        created = TrialStart.create!(user: @user, course: course, source: source)
        # Only reached if not duplicate:
        @user.increment!(:trial_courses_count)
      rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
        created = false
      end

      return unless created # no-op on duplicates

      if @user.trial_courses_count === TRIAL_LIMIT
        TrialMailer.trial_limit_reached(@user).deliver_later
      end
    end

    private

    def bypass?
      @user.admin? || @user.teacher? || @user.active_subscription.present? || !@user.trial_active?
    end
  end
end
