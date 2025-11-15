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

  def level_selection_section
    return unless current_user.student?

    user_levels = current_user.levels
    
    if user_levels.any?
      # User has a level, show the level image and edit button
      level = user_levels.first
      level_number = level.name.scan(/\d+/).first&.to_i
      
      content_tag :div, class: "my-5" do
        content_tag(:h2, "Kies je groep en ga direct aan de slag!") +
        content_tag(:div, class: "d-flex align-items-center flex-wrap gap-3") do
          image_tag("groep-#{level_number}.jpg", class: "home-level-image") +
          button_to("Groep wijzigen", destroy_user_levels_path, method: :delete, class: "btn btn-secondary", data: { confirm: "Weet je zeker dat je je groep wilt wijzigen?" })
        end
      end
    else
      # User has no level, show all levels to pick from
      content_tag :div, class: "my-5" do
        content_tag(:h2, "Kies je groep en ga direct aan de slag!") +
        content_tag(:div) do
          [3, 4, 5, 6, 7].map do |n|
            button_to(user_levels_path, method: :post, params: { level_number: n }, form: { style: "display: inline-block; margin: 0;" }, class: "level-selection-button", style: "border: none; background: none; padding: 0; cursor: pointer;") do
              image_tag("groep-#{n}.jpg", class: "home-level-image")
            end
          end.join.html_safe
        end
      end
    end
  end
end
