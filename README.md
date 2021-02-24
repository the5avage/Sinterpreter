# Sinterpreter

This is a small interpreter I wrote for learning something about Swift and compilers. It's not intended for any use, but can be useful as a command line calculator due to fast startup and operator associativity. It might be valuable for people interested in learning the same, but right now I don't have the time to write an in depth tutorial about it.

## The Language

It's a toy language, which supports some key features of programming languages. The language knows only two types (double and bool).

Here is a list of the supported features:
* Operator associativity similar to C
* If statement
* While loop
* Function definitions
* Recursive function calls
* Type inference

## Examples

TODO

## Notes on the Implementation

The Interpreter works in three stages (Lexer, Parser and AST-Interpreter). The main abstraction used to connect the stages is a [lazily evaluated stream](Sources/Sinterpreter/Range/forwardrange.swift), which is inspired by [Dlang's Ranges](https://www.informit.com/articles/printerfriendly/1407357).

The Lexer takes a range of characters and turns it into a range of tokens. The parser takes a range of tokens and so on...
Because ranges are evaluated lazily the REPL works without effort.

The Sequence type from Swifts Standard library is similar to the range type used here, but is not suitable in this context, because you can't read a value without removing it from the sequence. One thing I found impressive about Swift is, that it was very easy to make both types (ForwardRange and Sequence) compatible, so you can use all Standard Library functions for Sequences on ForwardRanges.

The parser is a Recursive Descend/Pratt Parser. With this approach it is relatively easy to parse complex grammars. For anyone interested in this I recommend [this article](https://www.crockford.com/javascript/tdop/tdop.html).
