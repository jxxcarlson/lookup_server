defmodule MU.CSS do



  def inject do
    """


    .index_word{ color: darkred; }

    .note_index {

      margin-bottom:3em;

    }

    p { margin-bottom:1em;
        font-size: 1em;}

    p.toc {
      margin:0;
      font-size:0.90em;
    }

    p.note_index_item {
       font-size:0.90em;
       margin:0;
       padding:0;
       color: darkred;
     }

     .note_index_item a {
       color: darkred;
     }

    .env {
      margin-top:1em;
      margin-bottom: 1em;
    }

    .env_body {

      margin-top: 0.15em;
      font-style: italic;

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

    h1 {font-size: 1.8em;}
    h2 {font-size: 1.5em;}
    h3 {font-size: 1.3em;}
    h4 {font-size: 1.0em;}
    h5 {font-size: 1.0em;}

    h1 a { color: darkred; }
    h2 a { color: darkred; }
    h3 a { color: darkred; }
    h4 a { color: darkred; }
    h5 a { color: darkred; }

    /*  Table */

    table, th, td {
        border: 1px solid gray;
    }

    td { padding-left:1em;}

    """
  end

end