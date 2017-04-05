defmodule MU.JS do

  def inject do
    """

  var x = document.getElementById("rendered_text").querySelectorAll(".answer_head");
  var answer_head = [];
  var answer_tail = [];


    function registerEvent(head, tail) {
      head.addEventListener("click", function(e) {
        if (tail.className == "hide_answer") {
          tail.className = "show_answer";
        } else {
          tail.className = "hide_answer";
        }
      });
    }

  for(i = 0; i < x.length; i++) {
    answer_head.push(document.getElementById(x[i].id));
    answer_tail.push(document.getElementById(x[i].id + ".A"));
    }

  for (i = 0; i < x.length; i++) {
    registerEvent(answer_head[i], answer_tail[i]);
  }

"""
  end
end