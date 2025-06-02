class SubscriptionObserver
  def self.call(user)
    new(user).call
  end

  def initialize(user)
    @user = user
  end

  def call
    return if @user.admin?

    subscription = @user.subscriptions.active.first # Or logic to get most relevant sub

    case subscription&.membership&.name
    when "Docenten"
      @user.update!(role: :teacher)
    when "Basis"
      @user.update!(role: :student)
    else
      @user.update!(role: :inactive)
    end
  end
end
