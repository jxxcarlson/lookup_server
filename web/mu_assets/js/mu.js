

var answer_head = document.getElementById("QQ");
var answer_tail = document.getElementById("QQA");
answer_head.classname = "answer_head"
answer_head.addEventListener("click",function(e){
    if (answer_tail.className == "hide_answer") {
        answer_tail.className = "show_answer"
    } else {
        answer_tail.className = "hide_answer";
    }

});
