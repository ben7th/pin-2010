module EmailActorHelper
  def email_actor_link(email_actor,options={})
    case email_actor
    when EmailActor
      _email_actor_link(email_actor,options)
    when String
      _email_actor_link(EmailActor.new(email_actor),options)
    end
  end

  private
  def _email_actor_link(email_actor,options={})
    actor = email_actor.actor
    case actor
    when User
      link_to actor.name,pin_url_for('pin-user-auth',"/users/#{actor.id}"),options
    when Organization
      link_to "#{actor.name}(团队)",pin_url_for('pin-user-auth',"/organizations/#{actor.id}"),options
    when String
      mail_to email_actor.email
    end
  end
end
