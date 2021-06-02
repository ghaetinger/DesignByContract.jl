@def title = "Function Contracts"

# Function Contracts
\toc

## Pre-conditions

Prerequisites have the unique goal of filtering the arguments of the function
and blocking invalid ones that come from different parts of a program. This can
help finding errors in other functionalities as soon as possible. Here is an
example of a function that has prerequisites breached:

\textoutput{./code/ex1}

```julia:./code/ex1
style = "style=\"display: inline-block;white-space: normal;max-width:100%; word-break:break-all; word-wrap:break-word;\"" #hide
printval(x) = print("\\marginnote{<pre><code " * style * ">$(x)</code></pre>}") #hide

using DesignByContract

maxDictSize = 2

# Function for adding a variable to a
# string-key dictionary with a non-null key
@contract begin
    require(length(dict) < maxDictSize, length(key) > 0)
    function putItem!(dict :: Dict{String, Any}, key :: String, item)
        dict[key] = item
        return nothing
    end
end
```

Adding an apple should be fine.

\textoutput{./code/ex2}
```julia:./code/ex2
fruits = Dict{String, Any}()

putItem!(fruits, "apple", :red)
printval(fruits) #hide
```

\\

Adding a blueberry should still be fine.

\textoutput{./code/ex3}

```julia:./code/ex3
putItem!(fruits, "blueberry", :blue)
printval(fruits) #hide
```

\\

Adding a new fruit breaks the first condition, as the dictionary is full! This
breaks the pre-requisite and should raise an error pointing out the
`require` expression that failed.

\textoutput{./code/ex4}
```julia:./code/ex4
try #hide
putItem!(fruits, "", :purple)
catch e #hide
    printval(e) #hide
end #hide
```

\\

Now, by removing an item, we can add a new value. However, adding a `""` is a
shouldn't be accepted as its length is less than 0! Thus, a new exception
should be raised pointing out, again, where the error happened.

\textoutput{./code/ex5}
```julia:./code/ex5
delete!(fruits, "blueberry")
try #hide
putItem!(fruits, "", :purple)
catch e #hide
    printval(e) #hide
end #hide
```

## Post-conditions

Post-conditions work to find errors inside the contracted function. It is also
used to find errors easily and as soon as possible. Here is an example of a
function that breaches its post-conditions:

```julia:./code/ex6
minVal = 5

# Function that adds 1 to the values
# of an int array with len > 5
# and guarantees the sum of its elements
# will be > minVal
@contract begin
    require(length(arr) >= 5)
    ensure(sum(arr) > minVal)
    function incrArr!(arr :: Array{Int64, 1})
        for index in 1:length(arr)
            arr[index] += 1
        end
        return nothing
    end
end
```

Making an all-positive array has no chance to have a negative sum.
Thus, if the array has more than 4 elements, we know it won't break any
agreements.

\textoutput{./code/ex7}
```julia:./code/ex7
arr = collect(1:5)
printval(arr) #hide
```
\textoutput{./code/ex8}
```julia:./code/ex8
incrArr!(arr)
printval(arr) #hide
```

\\

As seen before, if the pre-condition is broken, it will raise an exception.
However, we see that the sum of the following array would also break the
post-condition array. It's intuitive that the pre-conditions break first, as
they are checked first.

\textoutput{./code/ex9}
```julia:./code/ex9
arr = collect(-4:-1)
printval(arr) #hide
```
\textoutput{./code/ex10}
```julia:./code/ex10
try #hide
  incrArr!(arr)
catch e #hide
  printval(e) #hide
end #hide
```

\\

Now, seen as the input array has a negative sum and is over 5 elements,
we'll get a breach on the post-requirement, raising an exception.

\textoutput{./code/ex11}
```julia:./code/ex11
arr = collect(-1 .* ones(Int64, 5))
printval(arr) #hide
```
\textoutput{./code/ex12}
```julia:./code/ex12
try #hide
  incrArr!(arr)
catch e #hide
  printval(e) #hide
end #hide
```

\\

### Return contract 

It's important to make sure there are _return_ expressions where you want to
return a value. This is both to make sure you understand the endpoints of the
function and to enable the macro `@contract` to see them as well. This helps
when you want to ensure the result value. Having this said, we can use the name
`result` inside `ensure` expressions to test the returning value. The following
is an example:

```julia:./code/ex13
# returns the value of a sum or product operation in
# an integer array depending on the parity of it's size.
# Says the final value is positive
@contract begin
    ensure(result > 0)
    function processArr(arr :: Array{Int64, 1})
        if length(arr) % 2 == 0
            return prod(arr)
        else
            return sum(arr)
        end
    end
end
```

As the input array has an odd parity size and all positive integers,
the return value will be a sum result and will be validated. 

\textoutput{./code/ex14}
```julia:./code/ex14
processArr([1, 2, 3])
printval(processArr([1, 2, 3])) #hide
```

\\

As the next input array is of even parity size, the result will be a product.
There is one negative number in it, the result will be negative as well,
breaking the post-condiition contract. 

\textoutput{./code/ex15}
```julia:./code/ex15
try #hide
  processArr([1, 2, 3, -1])
catch e #hide
  printval(e) #hide
end #hide
```
