A program to comute primal-dual circle representation of planar graphs

The SageMath [1] script "prog2.sage" expects as input
the path to an ipe file [2] which encodes a planar graph.
In ipe, vertices are drawn as points and edges are drawn 
as straight-line segments (see examples folder).
To run the script on an ipe-file "examples/example6.ipe" 
run "sage prog2.sage examples/example6.ipe".
The generated primal-dual circle representation will be exported
as an svg image "examples/example6.ipe.svg"
and as ipe file "examples/example6.ipe.ipe".
Note that the script can be easily modified to deal with other input formats 
such as a list of edges in plaint text format or sparse6/graphs6 format.
For theoretical background, see the article by Felsner and Rote [3].
Also the output formats are possible.
Please don't hesitate to contact me for questions, suggestions and feedback!

[1] https://www.sagemath.org/
[2] https://ipe.otfried.org/
[3] https://page.math.tu-berlin.de/~felsner/Paper/dcp.pdf
