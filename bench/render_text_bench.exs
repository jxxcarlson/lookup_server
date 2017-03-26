defmodule RenderTextBench do
  use Benchfella
  Code.require_file "/Users/carlson/dev/elixir/lookup_phoenix/lib/mu/mu.ex"


@text1  """
*Markdown*
- https://github.com/pragdave/earmark[Earmark]
- https://pragdave.me/blog/2014/09/03/elixir.html[Elixir state machine]
- http://www.sebastianseilund.com/static-markdown-blog-posts-with-elixir-phoenix[Markdown blog posts]
- http://roopc.net/posts/2014/markdown-cfg/[WHY NO FORMAL SYNTAX?]



*Parsing with Haskell*
- http://dev.stephendiehl.com/fun/002_parsers.html[Parsing - Stephen Diehl]
- http://tanakh.github.io/Peggy/[Peggy, a Haskell parser generator]
- https://github.com/tanakh/Peggy[Peggy source code]

*BNF and EBNF*
- http://www.garshol.priv.no/download/text/bnf.html[BNF and EBNF: What are they and how do they work?]
- http://www.cs.utsa.edu/~wagner/CS3723/grammar/examples2.html[Example grammars from a site on the Internet]
- http://dev.stephendiehl.com/fun/002_parsers.html[Grammars and BNF]
- http://www.cis.upenn.edu/~jean/gbooks/tcbookpdf2.pdf[Context-Free Grammars, Context-Free Languages, Parse Trees and Ogden’s Lemma]
- http://courses.cs.washington.edu/courses/cse341/04wi/lectures/11-interpreters.html[CSE 341: Grammars, Language Specification, and Interpreters]
- http://www.cs.miami.edu/home/schulz/CSC519.pdf[CSC519: Programming Languages]

*Yecc*
- http://erlang.org/doc/man/yecc.html[Manual]
- https://en.wikibooks.org/wiki/Erlang_Programming/Making_Parsers_with_yecc[Making parsers with yecc]

*Asciidoctor*
- https://github.com/asciidoctor/asciidoc-grammar-prototype[Github prototype grammar]
- http://discuss.asciidoctor.org/Asciidoc-syntax-definition-td1920i20.html[Discussion of grammar]


- https://github.com/h4cc/awesome-elixir[Awesome Elixir]
"""

@text2 """
This is the first entry in my digital diary.  We will see how the experiment goes. How consistent can I be? Does the technology (LookupNote.io, written in Elixir), really work for this?

Still jet-lagged from trip to India.  It's 4:15am and I've read one article on the latest Donald Trump outrage, and am now reading once again about the http://www.adamwaselnuk.com/elm/2016/05/27/understanding-the-elm-type-system.html[Elm type system] -- haven't put any work into my Elm Noteshare client for a long time, but was able to remember how to run it. (Yay!).  The backend, written in Ruby, has been chugging away reliably now for a year with almost no changes (ditto Yay!).

_Note to myself:_ please study http://www.adamwaselnuk.com/elm/2016/05/27/understanding-the-elm-type-system.html[Elm type system] .

I sometimes (now more often than before) have doubts about the wisdom of my software projects.  On the one hand, very few users, with the prospect of commercialization, much less commercial success seeming remote.  On the other hand, the intellectual challenge is about right for me at this stage of life and it is certainly keeping my aging brain in good shape -- I learned Ruby in 2011 when I got started with this venture and in the last six months have learned Elixir and am starting to learn Erlang.  Elixir and the functional language paradigm it reprsents seem to suit my personal tastes.

Nicole (in New York) and Dylan (here in Columbus, Ohio) are probably up and about as well. I'll get a few things done in the tranquility of the early morning before my doctor's appointment at 8:10.

*Yesterday.* Dylan got his learner's permit for driving.  He is still jet-lagged. Practiced his guitar for 20 minutes before going to bed at 9PM. Beautiful  playing despite the lack of practice -- _Coachman,_ which he is learning, _Blackbird_ and _XX_ from last year.  We both are going to make a big push to practice regularly and a lot in the coming weeks.  Nicole and Dylan had a long conversation at 3AM about their summer plans, love, life, etc.

I've added on piece of digital art to xref::922[Visual Literacy: a Gallery] which I am making for Dylan.

5AM.  Got _benchfella_ working in my LookupNotes project.  A 1600 character, 31 line file of web references is processed by `RenderText` in 1 millisecond. I think that this will be fast enough for my purposes, despite what I hear about Elixirl/Erlang string processing.  And also despite the fact that my implementation of `RenderText.transform` is extremely simple-minded. Should compare with Ruby implementation.

PS to myself:
----

//
//	Dear maintainer:
//
// Once you are done trying to 'optimize' this routine,
// and have realized what a terrible mistake that was,
// please increment the following counter as a warning
// to the next guy:
//
// total_hours_wasted_here = 42
----

*Status report.* I am very thirsty. My feet have not been swollen for several weeks, and they have very little numbness left.  I've been avoiding sugar to the greatest extent possible.  Am worried that I have diabetes.  My appointment with a new doctor today will give the answer.  No food until then.
"""

@text3 """
This is the first entry in my digital diary.  We will see how the experiment goes. How consistent can I be? Does the technology (LookupNote.io, written in Elixir), really work for this?

Still jet-lagged from trip to India.  It's 4:15am and I've read one article on the latest Donald Trump outrage, and am now reading once again about the http://www.adamwaselnuk.com/elm/2016/05/27/understanding-the-elm-type-system.html[Elm type system] -- haven't put any work into my Elm Noteshare client for a long time, but was able to remember how to run it. (Yay!).  The backend, written in Ruby, has been chugging away reliably now for a year with almost no changes (ditto Yay!).

_Note to myself:_ please study http://www.adamwaselnuk.com/elm/2016/05/27/understanding-the-elm-type-system.html[Elm type system] .

I sometimes (now more often than before) have doubts about the wisdom of my software projects.  On the one hand, very few users, with the prospect of commercialization, much less commercial success seeming remote.  On the other hand, the intellectual challenge is about right for me at this stage of life and it is certainly keeping my aging brain in good shape -- I learned Ruby in 2011 when I got started with this venture and in the last six months have learned Elixir and am starting to learn Erlang.  Elixir and the functional language paradigm it reprsents seem to suit my personal tastes.

Nicole (in New York) and Dylan (here in Columbus, Ohio) are probably up and about as well. I'll get a few things done in the tranquility of the early morning before my doctor's appointment at 8:10.

*Yesterday.* Dylan got his learner's permit for driving.  He is still jet-lagged. Practiced his guitar for 20 minutes before going to bed at 9PM. Beautiful  playing despite the lack of practice -- _Coachman,_ which he is learning, _Blackbird_ and _XX_ from last year.  We both are going to make a big push to practice regularly and a lot in the coming weeks.  Nicole and Dylan had a long conversation at 3AM about their summer plans, love, life, etc.

I've added on piece of digital art to xref::922[Visual Literacy: a Gallery] which I am making for Dylan.

5AM.  Got _benchfella_ working in my LookupNotes project.  A 1600 character, 31 line file of web references is processed by `RenderText` in 1 millisecond. I think that this will be fast enough for my purposes, despite what I hear about Elixirl/Erlang string processing.  And also despite the fact that my implementation of `RenderText.transform` is extremely simple-minded. Should compare with Ruby implementation.

PS to myself:
----

//
//	Dear maintainer:
//
// Once you are done trying to 'optimize' this routine,
// and have realized what a terrible mistake that was,
// please increment the following counter as a warning
// to the next guy:
//
// total_hours_wasted_here = 42
----

*Status report.* I am very thirsty. My feet have not been swollen for several weeks, and they have very little numbness left.  I've been avoiding sugar to the greatest extent possible.  Am worried that I have diabetes.  My appointment with a new doctor today will give the answer.  No food until then.

This is the first entry in my digital diary.  We will see how the experiment goes. How consistent can I be? Does the technology (LookupNote.io, written in Elixir), really work for this?

Still jet-lagged from trip to India.  It's 4:15am and I've read one article on the latest Donald Trump outrage, and am now reading once again about the http://www.adamwaselnuk.com/elm/2016/05/27/understanding-the-elm-type-system.html[Elm type system] -- haven't put any work into my Elm Noteshare client for a long time, but was able to remember how to run it. (Yay!).  The backend, written in Ruby, has been chugging away reliably now for a year with almost no changes (ditto Yay!).

_Note to myself:_ please study http://www.adamwaselnuk.com/elm/2016/05/27/understanding-the-elm-type-system.html[Elm type system] .

I sometimes (now more often than before) have doubts about the wisdom of my software projects.  On the one hand, very few users, with the prospect of commercialization, much less commercial success seeming remote.  On the other hand, the intellectual challenge is about right for me at this stage of life and it is certainly keeping my aging brain in good shape -- I learned Ruby in 2011 when I got started with this venture and in the last six months have learned Elixir and am starting to learn Erlang.  Elixir and the functional language paradigm it reprsents seem to suit my personal tastes.

Nicole (in New York) and Dylan (here in Columbus, Ohio) are probably up and about as well. I'll get a few things done in the tranquility of the early morning before my doctor's appointment at 8:10.

*Yesterday.* Dylan got his learner's permit for driving.  He is still jet-lagged. Practiced his guitar for 20 minutes before going to bed at 9PM. Beautiful  playing despite the lack of practice -- _Coachman,_ which he is learning, _Blackbird_ and _XX_ from last year.  We both are going to make a big push to practice regularly and a lot in the coming weeks.  Nicole and Dylan had a long conversation at 3AM about their summer plans, love, life, etc.

I've added on piece of digital art to xref::922[Visual Literacy: a Gallery] which I am making for Dylan.

5AM.  Got _benchfella_ working in my LookupNotes project.  A 1600 character, 31 line file of web references is processed by `RenderText` in 1 millisecond. I think that this will be fast enough for my purposes, despite what I hear about Elixirl/Erlang string processing.  And also despite the fact that my implementation of `RenderText.transform` is extremely simple-minded. Should compare with Ruby implementation.

PS to myself:
----

//
//	Dear maintainer:
//
// Once you are done trying to 'optimize' this routine,
// and have realized what a terrible mistake that was,
// please increment the following counter as a warning
// to the next guy:
//
// total_hours_wasted_here = 42
----

*Status report.* I am very thirsty. My feet have not been swollen for several weeks, and they have very little numbness left.  I've been avoiding sugar to the greatest extent possible.  Am worried that I have diabetes.  My appointment with a new doctor today will give the answer.  No food until then.

"""

  # First bench mark
  bench "transform input 1: wc 31, 104, 1594" do
    MU.RenderText.transform(@text1)
  end

  bench "transform input 2: wc 31, 513, 3150" do
    MU.RenderText.transform(@text2)
  end

  bench "transform input 3: wc 62, 1026, 6300" do
    MU.RenderText.transform(@text3)
  end


end