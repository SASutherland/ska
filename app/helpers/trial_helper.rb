module TrialHelper
  include TrialConfig

  def trial_remaining(user)
    return 0 unless user.trial?
    [TrialConfig::TRIAL_LIMIT - user.trial_courses_count.to_i, 0].max
  end

  def trial_banner?(user)
    user.trial? && trial_remaining(user) > 0
  end

  def trial_locked?(user)
    user.trial_active? && user.active_subscription.nil? && user.trial_limit_reached?
  end

  # CTA target: if locked => memberships, else => start course
  def start_course_path_for(course, user)
    if trial_locked?(user)
      dashboard_subscriptions_path
    else
      start_course_path(course) # courses/:course_id/start (POST)
    end
  end

  # Decide CTA label
  def start_course_label(user)
    trial_locked?(user) ? "Word lid" : "Start cursus"
  end

  # Small badge next to avatar or in nav
  def trial_badge(user)
    return unless user.trial?
    content_tag(:span, "Proef · #{trial_remaining(user)} over", class: "badge badge--trial")
  end

  # An optional banner partial
  def render_trial_banner(user)
    return unless trial_banner?(user)

    render partial: "shared/trial_banner", locals: { remaining: trial_remaining(user) }
  end
end
