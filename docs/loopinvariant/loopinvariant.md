@def title = "Loop Invariants"

# Loop Invariant

Loop invariants throw errors when a condition goes invalid after an iteration. 
This is very simple and works as in the following example:

\textoutput{./code_loop/ex1}
```julia:./code_loop/ex1
style = "style=\"display: inline-block;white-space: normal;max-width:100%; word-break:break-all; word-wrap:break-word;\"" #hide
printval(x) = print("\\marginnote{<pre><code " * style * ">$(x)</code></pre>}") #hide
using DesignByContract

global a = 100
@loopinvariant (a>0) while(a > 10)
  global a -= 10;
end
printval(a) #hide
```


Now, if we make the loop go `while(a >= 0)`, it will run into a loop in which
`a <= 0`, which is unwanted and should raise an exception.

\textoutput{./code_loop/ex2}
```julia:./code_loop/ex2
global a = 100
try #hide
@loopinvariant (a>0) while(a >= 10)
  global a -= 10;
end
catch e #hide
  printval(e) #hide
end #hide
```
