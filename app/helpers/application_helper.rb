module ApplicationHelper
  def translated_payment_status(payment)
    date = l(payment.paid_at || payment.created_at, format: :short)

    case payment.status
    when "paid"
      "Betaald op #{date}"
    when "failed"
      "Mislukt"
    when "canceled"
      "Geannuleerd"
    when "expired"
      "Verlopen"
    when "charged_back"
      "Teruggeboekt"
    when "pending"
      next_payment_date = l((payment.created_at || Time.current) + 1.month, format: :short)
      "In behandeling (incasso rond #{next_payment_date})"
    else
      "#{payment.status.humanize}"
    end
  end

  def membership_message(membership)
    if membership.name == "Docenten"
      "Je hebt momenteel het lidmaatschap voor #{membership.name}"
    else
      "Je hebt momenteel het #{membership.name} lidmaatschap"
    end
  end

  def builder_for(association, form_builder)
    form_builder.object.send(association).build
    form_builder.fields_for(association, form_builder.object.send(association).last, child_index: "NEW_RECORD") do |ff|
      return ff
    end
  end

  def nav_link(name, path, controller: nil, action: nil)
    active = 'active' if (controller.nil? || controller_name == controller) &&
                         (action.nil? || action_name == action)
    link_to name, path, class: "nav-link #{active}"
  end

  def sidebar_links
    [
      { name: 'Dashboard', path: dashboard_path, controller: 'dashboards', action: 'index' },
      { name: 'Gebruikers', path: dashboard_manage_users_path, controller: 'dashboards', action: 'manage_users', roles: [:admin] },
      { name: 'Mijn cursussen', path: courses_path, controller: 'courses', action: 'index' },
      { name: 'Leerlingenlijst', path: dashboard_my_groups_path, controller: 'dashboards', action: 'my_groups', roles: [:teacher, :admin] },
      
      { name: 'Cursussen', path: my_courses_courses_path, controller: 'courses', action: 'my_courses', roles: [:teacher, :admin] },
      # { name: 'Studenten lijst', path: students_path, controller: 'students', action: 'index', roles: [:teacher, :admin] },
      { name: 'Niveaus/Groepen', path: levels_path, controller: 'dashboards', action: 'levels', roles: [:teacher, :admin] },
      { name: 'Lidmaatschap', path: dashboard_subscriptions_path, controller: 'dashboards', action: 'subscriptions' },
      { name: 'Logboek', path: dashboard_logbook_path, controller: 'dashboards', action: 'logbook', roles: [:admin] }
    ]
  end
end
