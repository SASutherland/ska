class TrialMailerPreview < ActionMailer::Preview
  def trial_limit_reached
    TrialMailer.trial_limit_reached(preview_user)
  end

  private

  def preview_user
    User.new(first_name: "Test", last_name: "User", email: "you@yourdomain.nl", trial_active: true, trial_courses_count: 2)
  end
end
