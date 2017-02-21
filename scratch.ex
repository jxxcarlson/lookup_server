

<% if @current_user == nil do %>
  <%= render LookupPhoenix.PublicView, "index.html", assigns %>
<% else %>
  <%= render LookupPhoenix.NoteView, "index.html", assigns %>
<% end %>
