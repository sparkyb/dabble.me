class UserMailer < ActionMailer::Base
  helper.extend(ApplicationHelper)
   add_template_helper(EntriesHelper)

  default from: "Dabble Me Support <hello@#{ENV['MAIN_DOMAIN']}>"

  def welcome_email(user)
    @user = user
    @user.increment!(:emails_sent)
    email = mail(from: "Dabble Me ✏ <#{user.user_key}@#{ENV['SMTP_DOMAIN']}>", to: user.cleaned_to_address, subject: "Let's write your first Dabble Me entry")
    email.mailgun_options = {tag: 'Welcome'}
  end

  def confirm_user(user)
    @user = user
    return nil unless @user.paranoid_verification_code.present?
    email = mail(to: user.cleaned_to_address, subject: "Login code for Dabble Me")
    email.mailgun_options = {tag: 'Login Code'}
  end

  def second_welcome_email(user)
    @user = user
    @user.increment!(:emails_sent)
    @first_entry = user.entries.first
    if @first_entry.present?
      @first_entry_image_url = @first_entry.image_url_cdn
    end
    email = mail(from: "Dabble Me ✏ <#{user.user_key}@#{ENV['SMTP_DOMAIN']}>", to: user.cleaned_to_address, subject: 'Congrats on writing your first entry!')
    email.mailgun_options = {tag: 'Welcome'}
  end

  def thanks_for_paying(user)
    @user = user
    @user.increment!(:emails_sent)
    email = mail(to: user.cleaned_to_address, subject: 'Thanks for subscribing to Dabble Me PRO!')
    email.mailgun_options = {tag: 'Thanks'}
  end

  def downgraded(user)
    @user = user
    @user.increment!(:emails_sent)
    email = mail(to: user.cleaned_to_address, subject: '[ACTION REQUIRED] Account Downgraded')
    email.mailgun_options = {tag: 'Downgraded'}
  end

  def no_user_here(email, source, payer_id)
    add_id = payer_id.present? ? " #{source} ID is #{payer_id}" : ""
    mail(to: "hello@#{ENV['MAIN_DOMAIN']}", subject: '[REFUND REQUIRED] Payment Without a User', body: "#{email} does not exist as a user at #{ENV['MAIN_DOMAIN']}. Payment via #{source}.#{add_id}")
  end

  def referred_users(id, email)
    @ref_id = id
    if id == '*'
      @users = User.referrals.where('created_at > ?', 1.week.ago)
    else
      @users = User.referrals.where(referrer: id).where('created_at > ?', 1.week.ago)
    end
    return unless @users.present?

    email = mail(to: email, subject: 'Dabble Me Referrals')
    email.mailgun_options = {tag: 'Referrals'}
  end  
end
