# Programming Language Project
Project realized for the bachelor course of Programming Language for Università Milano Bicocca.

The aim of this project is to realize two libraries, one in **Prolog** and the other in **Common Lisp**, that build data structures representing JSON objects starting from their representation as strings.

### Syntax:


JSON ::= Object | Array


Object ::= '{}' | '{' Members '}'


Members ::= Pair | Pair ',' Members


Pair ::= String ':' Value


Array ::= '[]' | '[' Elements ']'


Elements ::= Value | Value ',' Elements


Value ::= JSON | Number | String


Number ::= Digit+ | Digit+ '.' Digit+


Digit ::= 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9


String ::= '"' AnyCharSansDQ* '"' | '’' AnyCharSansSQ* '’'


AnyCharSansDQ ::= <any char (ASCII) different from '"'>


AnyCharSansSQ ::= <any char (ASCII) different from '’'>
