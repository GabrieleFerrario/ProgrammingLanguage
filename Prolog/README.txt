Membri Gruppo:
Gabriele Ferrario 817518
Fernando Acuna Cama 817399

json_parse(JSONString, JSON) --> riceve in input un atomo che converte in una lista di codici ascii tramite il predicato name, la lista di codici viene passata come parametro 
in ingresso al predicato decomposition. json_parse restituisce il parse del contenuto di JSONString.

decomposition(Codes, JSON) --> consente di verificare tramite il phrase se la lista di codici ascii rappresenta un oggetto/array json corretto.

s --> elimina gli eventuali spazi, newline e tab.

json_obj(json_obj(...)) --> verifica se si tratta di un oggetto vuoto e in caso affermativo ritorna json_obj([]); o di un oggetto al cui interno c'è members e in questo caso 
richiama json_members del contenuto tra le graffe, ritornando json_obj(...) al cui interno è presente il risultato di json_members.

json_array(json_array(...)) --> verifica se si tratta di un array vuoto e in questo caso ritorna json_array([]) o di un array con degli elementi ritornando json_array(...) il 
cui contenuto è formato dal risultato della json_elements. Qui controlliamo anche il caso [} ritornando false.

json_elements([...]) --> ritorna una lista il cui contenuto è composto dal risultato della chiamata di json_value se è presente un solo elemento, altrimenti il risultato è 
formato dal valore ritornato dalla json_value e dalla json_elements.
con il predicat
json_value(Value) --> richiama e ritorna il risultato della chiamata di uno dei seguenti predicati json_string, json_obj, json_array, json_numbers.

json_numbers(Numbers) --> verifica se si tratta di un numero decimale, intero positivo o negativo e in questo caso richiama la json_numbers. Il controllo della correttezza del numero
 viene verificata tramite il predicato numbers e se è corretto viene composto il numero tramite number_codes e viene effettuata l'append di eventuali - o . (vengono accettati
numeri interi sia negativi che positivi e numeri decimali sia negativi che positivi)

numbers( ... ) --> verifica tramite il char_type se il carattere ascii è digit (rappresenta un numero).

json_members([...]) --> verifica se l'oggetto json è corretto, restituisce una lista composta dal risultato del json_pair e del json_members o solo dal json_pair.

json_pair((String,Value)) --> verifica la correttezza del pair richiamando json_string e json_value, ritornando i valori restituiti da questi due predicati.
''
json_string(String) --> verifica la correttezza della stringa json che può essere nella forma  '"' AnyCharSansDQ* '"' o '’' AnyCharSansSQ* '’' . In base al caso viene effettuato
 il controllo della presenza di eventuali ' o " all'interno della stringa e tramite la string_codes (converte lista di codici ascii in stringa e viceversa) viene ritornata la 
stringa.

correct_string_single_quotes([...]) e correct_string_double_quotes([...])--> verificano la correttezza della stringa rispettando AnyCharSansDQ ::= <qualunque carattere (ASCII)
 diverso da '"'> e AnyCharSansSQ ::= <qualunque carattere (ASCII) diverso da '’'>, richiamandosi ricorsivamente.


json_write(JSON,FileName) --> permette di scrivere il risultato del predicato json nel percorso specificato da FileName, inoltre riceve tramite il parametro JSON l'oggetto 
json parsato.(in caso di percorso non specificato viene salvato nella cartella di lavoro)

json(...) --> consente di capire se l'oggetto json parsato ricevuto dalla json_write rappresenta un json object o json array corretto , costruendo passo passo (tramite
 concatenazioni) l'atomo che rappresenta l'oggetto json parsato ricevuto. In caso di json_array non vuoto viene richiamato il predicato elements il cui risultato è concatenato 
con le parentesi quadre mentre in caso di json_obj il risultato di members è concatenato con le parentesi graffe.

members(...) --> concatena il risultato del predicato pair con una virgola e con il risultato della chiamata al predicato members, mentre se non è presente il campo members 
(caso [Pair]) ritorna il risultato del predicato pair.

pair((String,Value),Result) --> riceve in input String (stringa json) e Value, chiama strings passandogli String e value passandogli Value. I valori che gli ritornano da queste
 chiamate li concatena ponendo ':' in mezzo tra il valore ritornato da string e il valore ritornato da value. 

elements(...) --> riceve un array con un elemento (Value) o con due elementi (Value e Elements), richiama solo value in caso di solo value ritornando il risultato della chiamata
 di value, invece nell'altro caso richiama value passando Value che concatena con una virgola e questo risultato viene concatenato con il valore ritornato dalla chiamata a 
elements passando Elements.

value(Value,Result) --> riceve un parametro che passa a uno dei seguenti predicati: strings, json, number. Ritornando il valore restituito da una di queste chiamate.

number(Value,Value) --> verifica se Value è un numero intero o un numero di tipo float.

strings(String,Value) -->verifica se String è una stringa e grazie al predicato control concatena all'inizio e alla fine di String un singolo apice (N=1) o un doppio apice (N=0).

control(String,N) --> converte String in una lista di codici ascii che passa come parametro a control_codes.

control_codes(...) --> verifica la presenza di eventuali singoli apici o doppi apici all'interno della lista di codici ascii che rappresentano la stringa. In caso di singolo
 apice ritorna uno 0 come secondo parametro mentre in caso di doppi apici un 1.Questo predicato serve per capire se la stringa json è tra  '' o "".


json_load(FileName,Json) --> permette di leggere il contenuto di un file/percorso specificato da FileName, il file viene letto tramite read_file_to_codes che converte il 
contenuto in una lista di codici ascii. Questa lista è passata in input al predicato decomposition che effettua il parse del contenuto del file.


json_get(...) --> riceve in ingresso un oggetto json parsato, una lista e resituisce il valore recuperato seguendo il contenuto della lista (fields). Se la lista è vuota 
restituisce l'oggetto json parsato, altrimenti chiama il predicato search.

search(...) --> riceve in ingresso un oggetto json parsato e una lista. Verifica se si tratta di un array e in questo caso chiama search_array altrimenti verifica se è un 
oggetto e chiama search_obj, restituisce il risultato di uno di questi due predicati.

search_obj(json_obj(Members),Fields,Result) --> riceve in ingresso un json_obj(Members) e esegue la search_members sul parametro Members, restituendo il risultato di questa 
chiamata.

search_members(...) --> riceve in ingresso una stringa, un valore e una lista (fields). Se la lista è vuota ritorna il contenuto del parametro in ingresso; se string equivale
 al primo elemento della lista esegue search_obj, search_array e search_members passandogli Value e il resto della lista; ritorna il valore ritornato da uno di questi predicati.

search_array(...) -->riceve in ingresso un json_array(Elements), una lista (fields) ed esegue search_elements passandogli Elements e la lista Fields. Ritorna il risultato 
restituito dalla chiamata di questo predicato.

search_elements(..) --> riceve in ingresso due liste. Se il primo elemento della seconda lista è 0 chiama i seguenti predicati : search_members, search_obj e search_array;
 passandogli il primo valore della prima lista (X) e il resto della seconda lista (Ys). Restituisce il valore ritornato da uno di questi predicati. Mentre nel caso il primo 
elemento della seconda lista non è zero lo decrementa di uno e richiama la search_elements passandogli il resto della prima lista, mentre la seconda lista la passa con il
 primo valore decrementato di 1. 
  


 
