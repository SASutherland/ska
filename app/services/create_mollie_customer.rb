class CreateMollieCustomer
  def initialize(user)
    @user = user
  end

  def call
    log("Creating Mollie customer for user ##{@user.id}")
    Mollie::Customer.create(
      name: @user.name,
      email: @user.email
    )
  rescue => e
    log("Error: #{e.message}")
    raise
  end

  private

  def log(msg)
    Rails.logger.info("[CreateMollieCustomer] #{msg}")
  end
end
