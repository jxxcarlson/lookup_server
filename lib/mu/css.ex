defmodule MU.CSS do



  def inject do
    """
    .index_word{ color: darkred; }

    .note_index {

      margin-bottom:3em;

    }

    .note_index_item {
       font-size:0.90em;
       margin-top:0;
       margin-bottom:-0.75em;
       padding-top:0;
       padding-bottom:0;
       color: darkred;
     }

     .note_index_item a {
       color: darkred;
     }


    /* Quote */

    .quote {

        font-style: italic;
        margin-left:2em;
        margin-right:2em;
        margin-bottom:1em;
    }


    .display {

        margin-left:2em;
        margin-right:2em;
        margin-bottom:1em;
    }

    /* QA */

    .answer_head{ color: darkred; margin-left:2em;}
    .hide_answer{ color: blue; display:none }
    .show_answer{color: blue; display:inline; margin-left:0.6em;}

    /* Sections */

    h1 {font-size: 1.7em;}
    h2 {font-size: 1.3em;}
    h3 {font-size: 1.0em;}
    h4 {font-size: 1.0em;}

    /*  Table */

    table, th, td {
        border: 1px solid red;
    }

    td { padding-left:1em;}

    """
  end

end