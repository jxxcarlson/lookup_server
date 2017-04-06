defmodule MU.CSS do



  def inject do
    """

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


    .display {

        margin-left:2em;
        margin-right:2em;
    }

    /* QA */

    .answer_head{ color: darkred; margin-left:2em;}
    .hide_answer{ color: blue; display:none }
    .show_answer{color: blue; display:inline; margin-left:0.6em;}

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

    """
  end

end