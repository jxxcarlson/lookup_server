    cond do
       current_user == nil ->
         channel = site <> ".public"
       current_user.username == site ->
         channel = site <> ".all"
       true ->
         channel = site <>  ".public"
     end

     if current_user != nil do
       User.set_channel(current_user, channel)
     end
