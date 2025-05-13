module ApplicationHelper
  def translated_payment_status(payment)
    date = l(payment.paid_at || payment.created_at, format: :short)

    case payment.status
    when "paid"
      "Betaald op #{date}"
    when "failed"
      "Mislukt op #{date}"
    when "canceled"
      "Geannuleerd op #{date}"
    when "expired"
      "Verlopen op #{date}"
    when "charged_back"
      "Teruggeboekt op #{date}"
    when "pending"
      volgende = l((payment.created_at || Time.current) + 1.month, format: :short)
      "In behandeling (volgende incasso rond #{volgende})"
    else
      "#{payment.status.humanize} op #{date}"
    end
  end
end
