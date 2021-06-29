%Membri Gruppo:
%Gabriele Ferrario 817518
%Fernando Acuna Cama 817399
json_parse(JSONString, JSON) :-
                               name(JSONString, Codes),
                               decomposition(Codes, JSON),
                               !.

% il predicato "decompositon" tramite il phrase verifica se la lista
% "codes" rappresenta corretamente un json object O un json array
decomposition(Codes, JSON) :-
                               phrase(json_obj(JSON), Codes, []).

decomposition(Codes, JSON) :-
                               phrase(json_array(JSON), Codes, []).

%--il predicato "s" elimina spazi, newline , tab.
s -->
                               ([0' ];
                               "\t";
                               "\n";
                               "\r"),
                               s,
                               !.

s -->
                               [],
                               !.

%--gestione json_object
json_obj(json_obj([])) -->
                               s,
                               "{",
                               s,
                               "}",
                               s.

json_obj(json_obj(Members)) -->
                               s,
                               "{",
                               s,
                               json_members(Members),
                               s,
                               "}",
                               s.
%--gestione json_array
json_array(json_array([])) --> s,
                               "[",
                               s,
                               "}",
                               s,
                               !,
                               {
                                   false
                               }.

json_array(json_array([])) -->
                               s,
                               "[",
                               s,
                               "]",
                               !,
                               s.

json_array(json_array(Elements)) -->
                               s,
                               "[",
                               s,
                               json_elements(Elements),
                               s,
                               "]",
                               s.

%--elaborazione degli elementi e dei membri
json_elements([Value]) -->
                               s,
                               json_value(Value),
                               s.

json_elements([Value| Elements]) -->
                               s,
                               json_value(Value),
                               s,
                               ",",
                               s,
                               json_elements(Elements),
                               s.

%--identifico il tipo di "value", che può essere :
%una stringa
%un oggetto
%un array
%un numero
json_value(Value) -->
                               json_string(Value),
                               !.

json_value(Value) -->
                               json_obj(Value),
                               !.

json_value(Value) -->
                               json_array(Value)
                               ,!.

json_value(Value) -->
                               json_numbers(Value),
                               !.

%--verifica per i numeri positivi.
json_numbers(Numbers) -->
                               s,
                               "+",
                               json_numbers(N),
                               s,
                               {
                                   number_codes(N, C),
                                   append([43], C, Codes),
                                   number_codes(Numbers,Codes)
                               }.

%--verifica per i numeri con la virgola
json_numbers(Numbers) -->
                               s,
                               numbers(Integer),
                               ".",
                               numbers(Decimal),
                               s,
                               {
                                   append(Integer, [46], U),
                                   append(U, Decimal, Codes),
                                   number_codes(Numbers, Codes)
                               }.
%--verifica per i numeri negativi.
json_numbers(Numbers) -->
                               s,
                               "-",
                               json_numbers(N),
                               s,
                               {
                                   number_codes(N, C),
                                   append([45], C, Codes),
                                   number_codes(Numbers,Codes)
                               }.

json_numbers(Numbers) -->
                               s,

                               numbers(Codes),

                               s,

                               {
                                   Codes \= [],
                                   number_codes(Numbers, Codes)
                               }.

%--il predicato "numbers" verifica che "x" rappresenti un numero
numbers([X| Xs]) -->
                               [X],
                               {
                                   char_type(X, digit)
                               },
                               numbers(Xs).

numbers([]) -->
                               [],
                               !.


json_members([Pair| Members]) -->
                               s,
                               json_pair(Pair),
                               s,
                               ",",
                               s,
                               json_members(Members),
                               s.

json_members([Pair]) -->
                               s,
                               json_pair(Pair),
                               s.

json_pair((String, Value)) -->
                               s,
                               json_string(String),
                               s,
                               ":",
                               s,
                               json_value(Value),
                               s.

%--verifica della "String" nel caso '"' AnyCharSansDQ* '"'.
json_string(String) -->
                               ("\"",
                               (correct_string_double_quotes(Codes),
                               {
                                    string_codes(String, Codes)
                               }),
                               "\"").

%--verifica della "string" nel caso '’' AnyCharSansSQ* '’'.
json_string(String) -->
                               ("'",
                               (correct_string_single_quotes(Codes),
                               {
                                    string_codes(String, Codes)
                               }),
                               "'").

correct_string_double_quotes([]) -->
                               [].

correct_string_double_quotes([X| Xs]) -->
                               [X],
                               {
                                   X \= 34
                               },
                               correct_string_double_quotes(Xs).

correct_string_single_quotes([]) -->
                               [].

correct_string_single_quotes([X| Xs]) -->
                               [X],
                               {
                                   X \= 39
                               },
                               correct_string_single_quotes(Xs).


% --"json_write" mi permette di scrivere il risultato del predicato
% --json, nel percorso contenuto da FileName.
json_write(JSON, FileName) :-
                               open(FileName, write, Out),
                               json(JSON, J),
                               write(Out, J),
                               close(Out).


% --"json" permette di stabilire se il parametro che riceve si tratta
% di un object o un array json e lo costruisce tramite concatenazioni
json(json_obj([]), '{}') :-
                               !.

json(json_obj(Members), Result) :-
                               members(Members, R),
                               atom_concat("{", R, U),
                               atom_concat(U, "}", Result),
                               !.

json(json_array([]), '[]') :-
                               !.

json(json_array(Elements), Result) :-
                               elements(Elements, E),
                               atom_concat("[", E, U),
                               atom_concat(U, "]", Result),
                               !.

members([Pair], Result) :-
                               pair(Pair, Result).

members([Pair| Members], Result) :-
                               pair(Pair, P),
                               members(Members, M),
                               atom_concat(P, ',', U),
                               atom_concat(U, M, Result).

pair((String, Value), Result) :-
                               strings(String, S),
                               atom_concat(S, ':', U),
                               value(Value, V),
                               atom_concat(U, V, Result).

elements([Value], Result) :-
                               value(Value, Result).

elements([Value| Elements], Result) :-
                               value(Value, V),
                               atom_concat(V, ',', U),
                               elements(Elements, E),
                               atom_concat(U, E, Result).

value(Value, Result) :-
                               strings(Value, Result),
                               !.

value(Value, Result) :-
                               json(Value, Result),
                               !.

value(Value, Result) :-
                               number(Value, Result),
                               !.

%--"number" verifica il tipo di numero : int o float.
number(Value, Value) :-
                               integer(Value).

number(Value, Value) :-
                               float(Value).

% --"strings" per prima cosa verifica se il parametro
% "String" è effettivamente una stringa, dopodichè con il predicato
% "control" ci consente di concatenare i rispettivi "doppi apici"(N = 0)
% alla stringa oppure i 'singoli apici'(N = 1).
strings(String, Result) :-
                               string(String),
                               control(String, N),
                               N = 0,
                               atom_concat('"', String, S),
                               atom_concat(S, '"', Result).

strings(String, Result) :-
                               string(String),
                               control(String, N),
                               N = 1,
                               atom_concat('\'', String, S),
                               atom_concat(S, '\'', Result).

strings(String, Result) :-
                               string(String),
                               atom_concat('"', String, S),
                               atom_concat(S, '"', Result).

control(String, N) :-
                               atom_codes(String, L),
                               control_codes(L, N).

control_codes([X| _Xs], 0) :-
                               X = 39. %39 codice ascii '

control_codes([X| _Xs], 1) :-
                               X = 34. %34 codice ascii "

control_codes([_| Xs], N) :-
                               control_codes(Xs, N).


% --"json_load(...)" permette di leggere il contenuto di un
% file, dando come parametro il percorso del file dal quale si vuole
% leggere.
json_load(FileName, Json) :-
                               read_file_to_codes(FileName, Codes, []),
                               decomposition(Codes, Json),
                               !.

% "json_get" analizza la lista fields fino a raggiungere la
% porzione desiderata.

json_get(Result, [], Result) :-
                               !.

json_get(JSON_obj, Fields, Result) :-
                               search(JSON_obj, Fields, Result),
                               !.

json_get(JSON_obj, Fields, Result) :-
                               search(JSON_obj, [Fields], Result),
                               !.

search(Json, Fields, Result) :-
                               search_obj(Json, Fields, Result),
                               !.

search(Json, Fields, Result) :- search_array(Json, Fields, Result),
                               !.

search_obj(json_obj(Members), Fields, Result) :-
                               search_members(Members, Fields, Result).

search_members(Result, [], Result).

search_members([(String, Value)| _Members], [String| Xs], Result) :-
                               search_obj(Value, Xs, Result).

search_members([(String, Value)| _], [String| Xs], Result) :-
                               search_array(Value, Xs, Result).

search_members([(String, Value)| _Members], [String| Xs], Result) :-
                               search_members(Value, Xs, Result).

search_members([_X| Xs], Fields, Result) :-
                               search_members(Xs, Fields, Result).

search_array(json_array(Elements), Fields, Result) :-
                               search_elements(Elements, Fields, Result).

search_elements([X| _], [0| Ys], Result) :-
                               search_members(X, Ys, Result).

search_elements([X| _], [0| Ys], Result) :-
                               search_obj(X, Ys, Result).

search_elements([X| _], [0| Ys], Result) :-
                               search_array(X, Ys, Result).

search_elements([_X| Xs], [N| Ys], Result) :-
                               N \= 0,
                               Y is N - 1,
                               search_elements(Xs, [Y| Ys], Result).















