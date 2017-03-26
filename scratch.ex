<style>

.channel {
  float:right;
  display:inline;
  margin-top:0px;
  margin-bottom:3px;
  padding-left:4px;
  width:160px;
  height:35px;
  font-size:1.5rem;
  color:#222;
  font-weight:400;
  background-color:#fdeded;
}

</style>

<!-- style: "display:inline-block; margin-top:-18px; margin-bottom:3px; width:190px; height:35px; font-size:1.8rem; color:#222; font-weight:400; background-color:#fdeded;" -->

<div style="clear: left; font-size:1.2em; margin-top:0px; background-color:#eee; padding:5px; height:40px;">

<div style="height:40px;margin-top:-20px;">

  <span class="hidden-xs">
  <span  style="margin-left:0.25em; float: right; background-color: white;"><%= button("My channel", to: "/set_channel", method: "post", channel: "jxxcarlson.all", class: "btn") %></span>
   <%= form_for @conn, note_path(@conn, :set_channel), [as: :set], fn f -> %>
        <%= text_input f, :channel, placeholder: "Enter channel ...", autocorrect: "off", autocapitalize: "off",
            value: @conn.assigns.current_user.channel, class: "channel", id: "search_notes" %>
        <!-- <%= submit "cc", as: "save_option", value: "continue", class: "btn btn-primary", style: "width: 20px;", id: 'save1', style: "float:right;margin-right:6px;" %> -->
    <%= end %>
  <span>

  <span>
   <!-- <%= link "Get", to: note_path(@conn, :index, mode: "all"), class: "btn btn-default btn-s", id: "all_notes", style: "" %> -->
   <!-- <%= link "Random", to: search_path(@conn, :random), class: "btn btn-default btn-s", id: "random_notes", style: "" %> -->
   <%= link "Lead", to: "/tag_search/lead_article?site=#{@conn.assigns.current_user.username}", class: "btn btn-default btn-s", id: "lead", style: "background-color:cornflowerblue; color:white" %>
   <span style="margin-left:10px;">Recently</span>
   <%= link "Viewed", to: "/recent/#{@conn.assigns.current_user.channel}?max=19&mode=viewed", class: "btn btn-default btn-s", id: "recent_notes", style: "margin-left:0px;" %>
   <%= link "Updated", to: "/recent/#{@conn.assigns.current_user.channel}?max=19&mode=updated", class: "btn btn-default btn-s", id: "less_recent_notes" %>
   <%= link "Created", to: "/recent/#{@conn.assigns.current_user.channel}?max=19&mode=created", class: "hidden-xs btn btn-default btn-s", id: "less_recent_notes" %>

  </span>

   <!-- <span style="float:right; margin-right:5px;margin-top:4px;"><%= @conn.assigns.current_user.channel %> <span> -->

</div>
</div>