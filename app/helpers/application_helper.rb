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
end
