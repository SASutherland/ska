class ActivityLogger
  class << self
    def log!(user:, action:, subject: nil, message:, metadata: {})
      ActivityLog.create!(
        user: user,
        action: action,
        subject: subject,
        message: message,
        metadata: metadata.presence || {}
      )
    end

    def log_course_created(user:, course:)
      log!(
        user: user,
        action: "course_created",
        subject: course,
        message: "Gebruiker #{identifier_for(user)} heeft #{course_label(course)} '#{course.title}' aangemaakt.",
        metadata: { course_id: course.id, course_title: course.title, weekly_task: course.weekly_task? }
      )
    end

    def log_course_updated(user:, course:)
      log!(
        user: user,
        action: "course_updated",
        subject: course,
        message: "Gebruiker #{identifier_for(user)} heeft #{course_label(course)} '#{course.title}' bijgewerkt.",
        metadata: { course_id: course.id, course_title: course.title, weekly_task: course.weekly_task? }
      )
    end

    def log_course_deleted(user:, course_title:, weekly_task: false)
      log!(
        user: user,
        action: "course_deleted",
        subject: nil,
        message: "Gebruiker #{identifier_for(user)} heeft #{weekly_task ? 'de weektaak' : 'de cursus'} '#{course_title}' verwijderd.",
        metadata: { course_title: course_title, weekly_task: weekly_task }
      )
    end

    def log_group_created(user:, group:)
      log!(
        user: user,
        action: "group_created",
        subject: group,
        message: "Gebruiker #{identifier_for(user)} heeft de leerlingenlijst '#{group.name}' aangemaakt.",
        metadata: { group_id: group.id, group_name: group.name }
      )
    end

    def log_group_updated(user:, group:)
      log!(
        user: user,
        action: "group_updated",
        subject: group,
        message: "Gebruiker #{identifier_for(user)} heeft de leerlingenlijst '#{group.name}' bijgewerkt.",
        metadata: { group_id: group.id, group_name: group.name }
      )
    end

    def log_group_deleted(user:, group_name:)
      log!(
        user: user,
        action: "group_deleted",
        subject: nil,
        message: "Gebruiker #{identifier_for(user)} heeft de leerlingenlijst '#{group_name}' verwijderd.",
        metadata: { group_name: group_name }
      )
    end

    def log_user_updated(actor:, user:)
      log!(
        user: actor,
        action: "user_updated",
        subject: user,
        message: "Gebruiker #{identifier_for(actor)} heeft gebruiker #{describe_user(user)} bijgewerkt.",
        metadata: { target_user_id: user.id, target_user_email: raw_email(user), target_user_role: user.role }
      )
    end

    def log_user_approved(actor:, user:)
      log!(
        user: actor,
        action: "user_approved",
        subject: user,
        message: "Gebruiker #{identifier_for(actor)} heeft gebruiker #{describe_user(user)} goedgekeurd.",
        metadata: { target_user_id: user.id, target_user_email: raw_email(user), target_user_role: user.role }
      )
    end

    def log_user_deleted(actor:, user_snapshot:)
      log!(
        user: actor,
        action: "user_deleted",
        subject: nil,
        message: "Gebruiker #{identifier_for(actor)} heeft gebruiker #{format_user_snapshot(user_snapshot)} verwijderd.",
        metadata: {
          target_user_id: user_snapshot[:id],
          target_user_email: user_snapshot[:email],
          target_user_name: user_snapshot[:name]
        }
      )
    end

    def log_subscription_created(user:, subscription:)
      log!(
        user: user,
        action: "subscription_created",
        subject: subscription,
        message: "Gebruiker #{identifier_for(user)} heeft het lidmaatschap '#{subscription.membership.name}' geactiveerd.",
        metadata: subscription_metadata(subscription)
      )
    end

    def log_subscription_updated(user:, subscription:, status:)
      log!(
        user: user,
        action: "subscription_updated",
        subject: subscription,
        message: "Status van lidmaatschap '#{subscription.membership.name}' is bijgewerkt naar #{status}.",
        metadata: subscription_metadata(subscription).merge(status: status)
      )
    end

    def log_registration_created(user:, registration:)
      log!(
        user: user,
        action: "registration_created",
        subject: registration,
        message: "Gebruiker #{identifier_for(user)} heeft zich ingeschreven voor cursus '#{registration.course.title}'.",
        metadata: {
          course_id: registration.course_id,
          registration_id: registration.id
        }
      )
    end

    def log_attempt_created(user:, attempt:)
      log!(
        user: user,
        action: "attempt_created",
        subject: attempt,
        message: "Gebruiker #{identifier_for(user)} heeft een poging gedaan voor vraag '#{attempt.question.content}'.",
        metadata: {
          course_id: attempt.question.course_id,
          question_id: attempt.question_id,
          attempt_id: attempt.id
        }
      )
    end

    def log_answer_created(user:, answer:)
      log!(
        user: user,
        action: "answer_created",
        subject: answer,
        message: "Gebruiker #{identifier_for(user)} heeft een antwoord toegevoegd aan vraag '#{answer.question.content}'.",
        metadata: answer_metadata(answer)
      )
    end

    def log_answer_updated(user:, answer:)
      log!(
        user: user,
        action: "answer_updated",
        subject: answer,
        message: "Gebruiker #{identifier_for(user)} heeft een antwoord bijgewerkt voor vraag '#{answer.question.content}'.",
        metadata: answer_metadata(answer)
      )
    end

    def log_email_delivered(user:, recipient:, message_id:, delivered_at:, tag: nil, details: nil, metadata: {}, server_id: nil, message_stream: nil)
      user_identifier = user ? identifier_for(user) : recipient
      
      # Build message with tag if available, otherwise use generic message
      email_description = tag.present? ? "E-mail met tag '#{tag}'" : "E-mail"
      message = "#{email_description} is afgeleverd aan #{user_identifier}."
      
      log!(
        user: user,
        action: "email_delivered",
        subject: nil,
        message: message,
        metadata: {
          recipient: recipient,
          message_id: message_id,
          delivered_at: delivered_at,
          tag: tag,
          details: details,
          server_id: server_id,
          message_stream: message_stream,
          metadata: metadata
        }.compact
      )
    end

    private

    def identifier_for(user)
      user.display_identifier.presence || user.read_attribute(:email)
    end

    def course_label(course)
      course.weekly_task? ? "de weektaak" : "de cursus"
    end

    def describe_user(user)
      "#{user.full_name} (#{raw_email(user)})"
    end

    def raw_email(user)
      user.read_attribute(:email)
    end

    def format_user_snapshot(snapshot)
      "#{snapshot[:name]} (#{snapshot[:email]})"
    end

    def subscription_metadata(subscription)
      {
        subscription_id: subscription.id,
        membership_id: subscription.membership_id,
        membership_name: subscription.membership.name,
        status: subscription.status
      }
    end

    def answer_metadata(answer)
      {
        answer_id: answer.id,
        question_id: answer.question_id,
        course_id: answer.question.course_id,
        correct: answer.correct
      }
    end
  end
end

