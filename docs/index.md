@def title = "DesignByContract.jl"
@def tags = ["description"]

# DesignByContract.jl

\marginnote{
<blockquote>
Dealing with computer systems is hard. Dealing with people is even harder. But as a species,
we've had longer to figure out issues of human interactions. Some of the solutions we've come
up with during the last few millennia can be applied to writing software as well.
One of the best solutions for ensuring plain dealing is the contract.

<br>
<br>

- The Pragmatic Programmer

<br>

Andrew Hunt, David Thomas
</blockquote>
}

**DesignByContract.jl** is an implementation of the _Design by Contract_ paradigm in **Julia**.
The method for software design was first introduced in the **Eiffel** programming language and has
been adapted to other production languages such as Java and C++. It has since been praised by
producing readable, easily testable code.

_Design by Contract_ prescribes formal conditions to the state of a method's execution, loop and even
data structures. *E.g.* one must define the prerequisites and post-conditions expected so that the function
is better described and, thus, contributes to the general safety, predictability and readability of
the program’s state.

---

In the following sections, we specify the functions and structures this package provides:

- [Function Contracts](/functions/functions)
- [Loop Invariants](/loopinvariant/loopinvariant)
