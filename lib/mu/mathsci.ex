defmodule MU.MathSci do

   def formatChem(text) do
      Regex.replace(~r/chem:\[(.*)\]/U, text, "$\\ce{\\1}$")
    end

    def formatChemBlock(text) do
      Regex.replace(~r/chem::\[(.*)\]/U, text, "$$\\ce{\\1}$$")
    end

    def insert_mathjax(text, options) do
      if options[:process] == "latex" do
        text = insert_mathjax!(text)
      else
        text
      end
    end

    defp insert_mathjax!(text) do

        text <>  """

          <script type="text/x-mathjax-config">
            MathJax.Hub.Config( {tex2jax: {inlineMath: [['$','$']]},
              TeX: { extensions: ["mhchem.js"]
            } });

          </script>
              <script type="text/javascript" async
                      src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_CHTML">
           </script>

           <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.9.0/styles/default.min.css">
           <script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.9.0/highlight.min.js"></script>
           <script>hljs.initHighlightingOnLoad();</script>


"""

    end

    def inject_mathjax do
"""

          <script type="text/x-mathjax-config">
            MathJax.Hub.Config( {tex2jax: {inlineMath: [['$','$']]}, TeX: { extensions: ["mhchem.js"] } });

          </script>
              <script type="text/javascript" async
                      src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_CHTML">
           </script>

           <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.9.0/styles/default.min.css">
           <script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.9.0/highlight.min.js"></script>
           <script>hljs.initHighlightingOnLoad();</script>


"""
    end


end