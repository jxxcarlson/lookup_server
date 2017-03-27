


<style>

span.standard {

 float:right;
 margin-right:8px;

}



.navarrow { float:right; font-weight:bold;}

.rendered_text {
  background-color: #f4f4f4;
  padding-left: 1em;
  margin-top:3em;
  clear: right; padding-top:1em;
  overflow: scroll;
  height: 150px;
  white-space:pre-line;
}

</style>

<style>

h1 {font-size: 1.7em;margin-bottom:-1.7em;}
h2 {font-size: 1.3em;margin-bottom:-2.4em;}
h3 {font-size: 1.0em;margin-bottom:-3em;}
h4 {font-size: 1.0em; margin-bottom:-3.5em;}

.index_word{ color: darkred; }

/* Quote */

.quote {

    font-style: italic;
    margin-left:2em;
    margin-right:2em;
}


/* QA */

.answer_head{ color: blue;}
.hide_answer{ color: blue; display:none }
.show_answer{color: blue; display:inline}

/* Sections */

h1 {font-size: 1.7em;margin-bottom:-1.7em;}
h2 {font-size: 1.3em;margin-bottom:-2.4em;}
h3 {font-size: 1.0em;margin-bottom:-3em;}
h4 {font-size: 1.0em; margin-bottom:-3.5em;}

/*  Table */

table, th, td {
    border: 1px solid red;
}

td { padding-left:1em;}

</style>

<div style="font-size: 1.2em; margin-top:-0.5em;">

 <span style="font-size:2.1rem; font-style:bold; margin-bottom:0"> <%= @note.title  %> </span>

 <p style="margin-bottom:1em;margin-top:1rem;">

  <!-- <span class="small hidden-xs" style="margin-left:0;"> <%= @inserted_at %> </span> -->
  <span class="small hidden-xs" style="float:left; margin-right:3em;margin-top:2px;"> <%= @inserted_at %> </span>




  <span class="standard" ><%= link "Edit", to: note_path(@conn, :edit, @note, index: @index, id_string: @id_string) %></span>
  <span class="standard" ><%= link "Back", to: note_path(@conn, :index) %></span>
  <span class="standard hidden-xs" >Channel <%= @channela %></span>

  <%= if @note_count > 1 do %>

    <span style="float:left;margin-right:9px; font-weight:bold;" ><%= link "first", to: note_path(@conn, :show, @first_id, index: 0, id_string: @id_string) %></span>
    <span style="float:left;margin-right:9px; font-weight:bold;" ><%= link "prev", to: note_path(@conn, :show, @previous_id, index: @previous_index, id_string: @id_string) %></span>
    <span style="background-color:#35d; color: white; padding-left:5px; padding-right:8px; float:left;margin-right:8px;" ><%= @index + 1 %>:<%= @note_count %></span>
    <span class: "btn btn-primary" style="float:left;margin-right:8px; font-weight:bold;" ><%= link "next", to: note_path(@conn, :show, @next_id, index: @next_index, id_string: @id_string) %></span>
    <span class: "btn btn-primary" style="float:left;margin-right:28px; font-weight:bold;" ><%= link "last", to: note_path(@conn, :show, @last_id, index: @last_index, id_string: @id_string) %></span>


  <% end %>

</p>


<div id="rendered_text" class="rendered_text">
   <%= raw(@rendered_text) %>
</div>



</div>


<p style="margin-top:1em;"> <i>
  <span class="small hidden-xs"><b><%= LookupPhoenix.Note.public_indicator(@note) %></b>, Last updated: <%= @updated_at %></span>

  <span class="small hidden-xs" style='margin-left:2em;'>ID: <%= @note.id %> </span>
  <span class="small hidden-xs" style='margin-left:2em;'>Word count: <%= @word_count %> </span>
  <span style='margin-left:2em;'>Tags: <%= @note.tag_string %></span></i>
  <%= if @sharing_is_authorized do %>
    <span style='margin-left:2em;'>
      <%= link "Email Note", to: note_path(@conn, :mailto, @note.id, index: @next_index, id_string: @id_string) %>
    </span>
  <% end %>

  </p>
<br>

<script>
    document.getElementById("rendered_text").style.height = (window.innerHeight - 230) + 'px'
</script>


<script>

  var x = document.getElementById("rendered_text").querySelectorAll(".answer_head");
  var answer_head = [];
  var answer_tail = [];

  function bar(i) {
     if (answer_tail[i].className == "hide_answer") {
        answer_tail[i].className = "show_answer"
     } else {
        answer_tail[i].className = "hide_answer";
     }
   }
   function foo(i) {
      alert("Hey: " + answer_head[i].id)
   }

  for(i = 0; i < x.length; i++) {
    console.log (i + ": " + x[i].id)
    answer_head.push(document.getElementById(x[i].id));
    answer_tail.push(document.getElementById(x[i].id + ".A"));
    }
  for(i = 0; i < x.length; i++) {
     console.log("(1) item: " + i + ": " + answer_head[i].id +", " + answer_tail[i].id)
     console.log("contents (head): " + i + ": " + answer_head[i].innerHTML)
     console.log("contents (tail): " + i + ": " + answer_tail[i].innerHTML)
     console.log("class (tail): " + i + ": " + answer_tail[i].className)

   }
  for(i = 0; i < x.length; i++) {
    console.log("(2) item: " + i + ": " + answer_head[i].id +", " + answer_tail[i].id)
    answer_head[i].addEventListener("click",foo(i));
  }


</script>
