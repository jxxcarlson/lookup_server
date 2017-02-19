<ol class="breadcrumb text-right" style="background-color:#d9d9d9">

           <li style="font-size:1.25em; color:cornflowerblue  ; float:left;"> <%= link "Home", to: page_path(@conn, :index), id: 'home' %> </li>

           <%= if @current_user do %>

                <li style="font-size:1.25em; color:cornflowerblue  ; float:left;"> <%= link "Notes", to: note_path(@conn, :index), id: 'notes' %> </li>
                <li style="font-size:1.25em; color:cornflowerblue  ; float:left;"> <%= link "New", to: note_path(@conn, :new),   class: "", color: "blue", id: "new_note" %></li>
                <li style="font-size:1.25em; color:cornflowerblue  ; float:left;"> <%= link "Tags", to: user_path(@conn, :tags), id: 'tags' %> </li>

           <% end %>

           <li class="small hidden-xs" style="font-size:1.25em; color:cornflowerblue; float:left;"> <%= link "Manual", to: page_path(@conn, :tips), id: 'tips' %> </li>

           <%= if @current_user do %>
                 <%= if @current_user.admin == true do %>
                    <li class="small hidden-xs" style="font-size:1.25em; color:cornflowerblue  ; float:left;"> <%= link "Users", to: user_path(@conn, :index), id: 'users' %> </li>
                 <% end %>

                 <li class="link1 small hidden-xs"><span style="font-weight:bold; color:black"><%= @current_user.username %></span>: <%= LookupPhoenix.Search.count_for_user(@current_user.id) %> Notes</li>
                 <li class="link1">
                   <%= link "Sign out", to: session_path(@conn, :delete, @current_user), method: "delete" %>
                 </li>
           <% else %>
                 <li class="link1"> <%= link "Sign up", to: user_path(@conn, :new) %> </li>
                 <li class="link1"> <%= link "Sign in", to: session_path(@conn, :new) %> </li>
           <% end %>
         </ol>