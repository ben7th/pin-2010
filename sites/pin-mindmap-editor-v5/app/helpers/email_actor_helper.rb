module EmailActorHelper
  def email_actor_link(email_actor)
    actor = email_actor.actor
    path = case actor
    when User
      "/users/#{actor.id}/mindmaps"
    when Organization
      pin_url_for('pin-user-auth',"/organizations/#{actor.id}")
    when String
      'javascript:;'
    end
    link_to email_actor.name,path
  end
end
