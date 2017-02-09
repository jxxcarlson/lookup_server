def preprocessPDFURLs(text) do

          Regex.replace(~r/[^:]((http|https):\/\/\S*\.(jpg|jpeg|png|gif|tiff)\s/i, text, " iframe::\\1 ")
     end

    def makePDFLink(text, height \\ 200) do
       Regex.replace(~r/\siframe::(.*(pdf))\s/i, " "<>text<>" ", " <iframe src=\"\\1\"></iframe> ")
    end



var answer = document.getElementById("QQ");
    answer.addEventListener("click",function(e){
      if (answer.className == "hide_answer") {
        answer.className = "show_answer";
      } else {
         answer.className = "hide_answer";
      }

    });