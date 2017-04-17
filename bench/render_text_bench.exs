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

@text4 """
// this is a comment

[env.equation]
--
a^2 + b^2 = c^2
--

[quote, M. Twain]
--
A stitch in time saves nine.
--


Our aim is to understand the force mediated by the particles associated with a massive free scalar field.  Is it attractive, repulsive, or both?  What is its range?  To do this, let $H_0$ be Hamiltonian for the free scalar field, and consider a perturbation
\[
  J(x) = g_a(x_0)\delta^3(\vec x - \vec a) + g_b(x_0)\delta^3(\vec x - \vec b),
\]
Here $x$ is a four-vector, and we regard $J(x)$ as modeling point sources located at $\vec a$ and $vec b$.  The strength of the sources are defined by the functions $g_a$ and $g_b$. These depend on time.  We imagine that the sources are fully switched on for a time interval of length $\tau$, and that outside this interval, their strength decays to zero.  Thus $\lim_{x_0 \to \pm \infty} g_a(x_0) = 0$, and likewise for $g_b$. We further assume that the switching on and off of the interaction is "slow." This is the index:[adiabatic hypothesis].  Although we do not prove it here, the hypothesis implies that during swtiching, the system remains in its ground-state-of-the-moment.


=== S-matrix

Consider as system as just described.  It fits into the interaction picture with Hamiltonia $H = H_0 + H'$, with interaction Hamiltonian $H'$ given by the scalar function $J(x)$.  The evolution operator $U(t_2,t_1))$  for the interaction picture gives the probability amplitude $\langle b | U(t_2,t_1) | a \rangle$ for a system that is in state $a$ at time $t_1$ to be found in state $b$ at time $t_2$.

In our case, we are interested in the index:[S-matrix] amplitude
\[
  \langle 0 | S | 0 \rangle =_{def} \langle 0 | U(\infty, -\infty) | 0 \rangle \\
  =_{def} \lim_{t \to \infty} \langle 0 | U(t, -t | 0 \rangle
\]
We imagine $-\infty$ to stand for the remote past, where the interaction is turned off, so the behavior of particles is governed by the unperturbed Hamiltonian.  The same considerations apply to the remote future (all of this on the time-scale of a particle life-time).  For a time-independent Hamiltonian, we have
\[
  U(t_2,t_1) = e^{-iH'(t_2-t_1)}
\]
Using $H = H_0 + H'$, we can rewrite this as
\[
U(t_2,t_1) = e^{iH_0t_2} e^{-iH(t_2-t_1)} e^{-iH_0t_1}
\]
In the time dependent case, this reads as
\[
U(t_2,t_1) = e^{iH_0t_2} T e^{-i\int_{t_1}^{t_2}H(t_2-t_1)} e^{-iH_0t_1}
\]
Thus
\[
  \langle 0 | T e^{-i\int_{t_1}^{t_2}H(t_2-t_1)} | 0 \rangle e^{iE_0(t_2 - t_1)},
\]
where $H_0 | 0 \rangle = E_0 | 0 \rangle$.

Now comes a crucial point.  The adiabatic evolution of the system from remote times to time $t_1$ when the interaction is fully switched on evolves the vacuum to the ground state of $H(t_1)$, which has energy $E(g(t_1)) = E_J$.  Thus, to a very good approximation,
\[
  \langle 0 | S | 0 \rangle = e^{-(E_J - E_0)\tau} = e^{-\tau\Delta E},
\]
where $\tau$ is the time the interaction is on, and $\Delta E$ is the change in energy from the background state to the end of the interaction.  In the next section, we will compute the $S$-matrix in another way to show that
\[
  \Delta E= -g_1g_2\frac{1}{4\pi} \frac{ e^{-m|\vec x_1 - \vec x_2|}} { | \vec x_1 - \vec x_2 |}
\]
Since the energy is an increasing function of the separation $|\vec x_1 - \vec x_2 |$, the force is an attractive one:  by moving the sources closer, the total energy is decreased. Moreover, since the change in $\Delta E$ is negligible once the separation exceeds a few multiples of $1/m$, the range of the force is roughly $1/m$.

=== Time-ordered exponentials

Computation of the $S$-matrix requires evaluation of the time-ordered exponentail
\[
T\exp \left\{ -i \int d^4x J(x)\hat \phi(x) \right\}
\]
The theorem below reduces its computation to the computation of two factors.  The first factor does not depend on the separation between the sources; we shall ignore it.  The Feynman propagator appears in the second factor;  and we shall use the integral formula for the propagator to evaluate it.

We proceed to the proof of the theorem and will evaluate the time-ordered exponential in the next section.

[env.theorem]
--
\[
T\exp \left\{ -i \int d^4x J(x)\hat \phi(x) \right\}
  =\\ N \left\{ -i \int d^4x J(x)\hat \phi(x) \right\}
 \exp \left\{ - \frac{1}{2} \int d^4x d^4y J(x)
   \langle 0 | T \{ \hat \phi(x) \hat \phi(y) | 0 | \rangle J(y) \right\}
\]
--

*Proof.* The Hamiltonian is
\[
  \hat H(t) = \int d^3x J(x)\hat \phi(t,x)
\]
and the integral on the left in the theorem is
\[
T \left\{ \exp\left( -i \hat H(t) dt \right) \right\}
\sim
e^{-i \hat H(t_n) \Delta t}
e^{-i \hat H(t_{n-1}) \Delta t}
\cdots
e^{-i \hat H(t_1) \Delta t}
\]
For operators $A$ and $B$ which commute with $[A,B]$, we have
\[
  e^Ae^B = e^{A + B + \frac{1}{2}[A,B]},
\]
from which it follows that
\[
T \left\{ \exp\left( -i \hat H(t) dt \right) \right\}
\sim
\exp \left(  -i \Delta t \sum_j\hat H(t_j)
  - \frac{1}{2}  \sum_{k > \ell} [\hat H(t_k), \hat H(t_\ell)]
\right)
\]
Passing to the limit, we find
\[
T\exp \left\{ -i \int d^4x J(x)\hat \phi(x) \right\} =\\
  \exp \left\{ -i \int d^4x J(x)\hat \phi(x) \right\}
  \exp \left\{ -i \frac{1}{2}\int d^4x d^4y J(x)J(y)\theta(x_0 - y_0)[\hat \phi(x), \hat \phi(y) \right\}
\]
To put the right-hand side in better form,
consider first the normal-ordered form of the first factor:
\[
N\left\{
\exp \left\{ -i \int d^4x J(x)\hat \phi(x) \right\}
\right\} =
\exp \left\{ -i \int d^4x J(x)\hat \phi^{(+)}(x) \right\}
\exp \left\{ -i \int d^4x J(x)\hat \phi^{(-)}(x) \right\}
\]
Here $\hat \phi^{(+)}$ is the positive-frequency part of $\hat \phi$, i.e., the part with the annihilation operators;  $\hat \phi^{(-)}$ is the negative-frequency part of $\hat \phi$, i.e., the part with the creation operators.  We can rewrite this as
\[
N\left\{ \cdots \right\} =
 \exp \left\{ -i \int d^4x J(x)\hat \phi(x) \right\}
  \exp \left\{ -i \frac{1}{2}\int d^4x d^4y J(x)J(y))[\hat \phi^{(-)}(x), \hat \phi^{(+)}(y) \right\}
\]
Consequently, we can write
\[
T\left\{ \cdots \right\} =
 N\left\{
\exp \left\{ -i \int d^4x J(x)\hat \phi(x) \right\}
\right\} \times \\
\exp \left\{  \frac{i}{2}\int d^4x d^4y J(x)J(y)
\left([\hat \phi^{(-)}(x), \hat \phi^{(+)}(y)] - \theta(x_0 - y_0)[\hat \phi(x), \hat \phi(y)] \right)
\right\}
\]
The expression in parentheses is a scalar function, and so can be evaluated as a vacuum expectation:
\[
\left( \cdots \right) =
\langle 0 | [\hat \phi^{(-)}(x), \hat \phi^{(+)}(y)] | 0 \rangle
 - \theta(x_0 - y_0)\langle 0 | [\hat \phi(x), \hat \phi(y)] | 0 \rangle \\
\]
The first term on the right-hand side is
\[
\langle 0 | [\hat \phi^{(-)}(x), \hat \phi^{(+)}(y)] | 0 \rangle
 = \langle 0 | \hat \phi^{(-)}(x)\hat \phi^{(+)}(y) - \hat \phi^{(+)}(y)\hat \phi^{(-)}(x)| 0 \rangle \\ = -\langle 0 |  \hat \phi^{(+)}(y)\hat \phi^{(-)}(x)| 0 \rangle =  - \langle 0 | \hat\phi(y) \hat\phi(x) | 0 \rangle
\]
 Therefore
\[
\left( \cdots \right) =
 - \langle 0 | \hat\phi(y) \hat\phi(x)
 - \theta(x_0 - y_0) [\hat \phi(x), \hat \phi(y)] | 0 \rangle
\]
If $x_0 > y_0$, the expression on the right is
\[
 - \langle 0 | \hat\phi(y) \hat\phi(x)
 + [\hat \phi(x), \hat \phi(y)] | 0 \rangle =
 - \langle 0 | \hat \phi(x) \hat \phi(y) | 0 \rangle
\]
If $x_0 < y_0$, the expression on the right is $ - \langle 0 | \hat\phi(y) \hat\phi(x) | 0 \rangle$.  Therefore
\[
   \left( \cdots \right) = - \langle 0 | T\{ \hat\phi(x)\hat\phi(y) \} | 0 \rangle
\]

=== Evaluation of the vacuum expectaton

We must evaluate the vacuum expectation
\[
T\exp \left\{ -i \int d^4x J(x)\hat \phi(x) \right\}
\]
By the theorem, this is a factor times the expression
\[
\langle 0 | \exp \left\{ - \frac{1}{2} \int d^4x d^4y J(x)
   \langle 0 | T \{ \hat \phi(x) \hat \phi(y) | 0 | \rangle J(y) \right\}
| 0 \rangle
\]
Begin by substituting the integral formula for the propagator and formula for $J$.
One obtains a sum of terms, the one of which is
\[
\int d^4 x d^4 y  \frac{d^4 k}{(2\pi)^4} g_a(x_0) g_b(y_0)
  \frac{  \delta^3(\vec x - \vec a)  \delta^3(\vec y - \vec b) e^{ik(x-y) }}
 {k^2 - m^2}
\]
Integrate with respect to $d^3\vec x$ to obtain
\[
\int d x_0 d^4 y  \frac{d^4 k}{(2\pi)^4} k g_a(x_0) g_b(y_0)
  \frac{ \delta^3(\vec y - \vec b) e^{ik_0(x_0-y_0) } e^{i\vec k(\vec a- \vec y) }}
 {k^2 - m^2}
\]
Next, integrate with respect to $\vec y$ to obtain
\[
\int d x_0 dy_0 \frac{d^4 k}{(2\pi)^4} g_a(x_0) g_b(y_0)
  \frac{  e^{ik_0(x_0-y_0) } e^{i\vec k(\vec a- \vec b) }}
 {k^2 - m^2}
\]
The next step is to introduce a new variable $u_0 = x_0  - y_0$ and write the integral as
\[
\int \frac{d u_0}{2\pi} dy_0  \frac{d^3\vec k}{(2\pi)^3}d k_0 g_a(x_0) g_b(y_0)
  \frac{   e^{ik_0u_0 } e^{i\vec k(\vec a- \vec b) }}
 {k^2 - m^2},
\]
Introduce a new variable $u_0 = x_0 - y_0$ and write the preceding expression as
\[
\int \frac{d u_0}{2\pi} dy_0  \frac{d^3\vec k}{(2\pi)^3}d k_0 g_a(u_0 + y_0) g_b(y_0)
  \frac{   e^{ik_0u_0 } e^{i\vec k(\vec a- \vec b) }}
 {k^2 - m^2},
\]
Since $g_a(u_0 + y_0)$ is a slowly varying function of its argument for the interval over which the interaction is switched on, we have
\[
\int \frac{d u_0}{2\pi} dy_0  g_a(u_0 + y_0)   e^{ik_0u_0}
\sim
g_a \delta(k_0),
\]
where we write $g_a$ for the "switched on" value.
Therefore the main integral is approximately
\[
g_a\int dy_0 \frac{ d^3\vec k }{ (2\pi)^3} d k_0\delta(k_0)g_b(y_0)
  \frac{  e^{i\vec k(\vec a- \vec b) }}
 {k^2 - m^2},
\]
Integrate with respect to $y_0$ over to obtain
\[
g_ag_b\tau\int \frac{ d^3\vec k }{ (2\pi)^3}dk_0 \delta(k_0)
  \frac{  e^{i\vec k(\vec a- \vec b) }}
 {k^2 - m^2},
\]
Finally, integrate over $k_0$ and use  $k^2 = k_0^2 - \vec k^2$ to obtain
\[
 - g_ag_b\tau\int \frac{ d^3\vec k }{ (2\pi)^3}
  \frac{  e^{i\vec k(\vec a- \vec b) }}
 {\vec k^2 + m^2},
\]

=== Conclusions

The last integral is one we have seen before in our xref::1010[discussion of the Feynman propagator and the decay of solutions to the static Klein-Gordon equation]. Referring to it, we find that
\[
\Delta E = -\frac{g_ag_b\tau}{4\pi} \frac{e^{-m|\vec a - \vec b|}}{|\vec a - \vec b|}
\]
 This formula is what was claimed earlier. It shows that the force is attractive, and that its range is roughly $1/m$.

=== References

- The Physics of Quantum Fields, Michael Stone



// - http://pages.uoregon.edu/soper/QFT/Smatrix.pdf[S-Matrix (U Oregon)]

// - http://edu.itp.phys.ethz.ch/hs12/qft1/Chapter10.pdf[S-matrix, eth]

//- http://www.ecm.ub.es/~espriu/teaching/classes/fae/LECT6.pdf[Perturbation Theory and Feynman Diagrams (Domènec Espriu)]

// - http://www.nhn.ou.edu/~milton/p6433/chap3.pdf[Scalar Field Theory]
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

   bench "transform input 4: wc 251, 1727, 10553 " do
      MU.RenderText.transform(@text4)
    end


end