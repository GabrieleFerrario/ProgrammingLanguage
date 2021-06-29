Membri Gruppo:
Gabriele Ferrario 817518
Fernando Acuna Cama 817399

json-parse --> riceve in ingresso un parametro (stringa) che è un oggetto json da parsare e tramite la coerce viene convertito in una lista di caratteri, successivamente 
viene controllato il primo elemento per capire se si tratta di un json_array o di un json_obj e in caso affermativo viene eseguita la funzione appropriata, in caso contrario
 si segnala errore, questa funzione ritorna il json "parsato".

json-obj --> riceve in ingresso una lista di caratteri che viene passato come parametro alla json-members. Ritorna la lista contenente la concatenazione tra json-obj,
 il car del valore contenuto da result e con il secondo valore contenuto da result.

json-members --> inizialmente vine calcolato il campo pair che è assegnato a result1 (json-pair members), pair1 contiene il car di result1 mentre remainder contiene
il secondo valore contenuto da result1. Viene verificato se la virgola è seguita dalla }, e se è così viene segnalato un errore. Poi viene verificata la presenza del members e 
in caso affermativo viene calcolato e ritornato come lista, altrimenti si ritorna la lista formata dal pair1 e dal resto (remainder).

json-pair --> riceve in ingresso una lista di carratteri e verifica se inizia con doppio apice (valore passato 0) o con singolo apice (valore passato 1) e richiama la compose 
(passando gli argomenti appropriati in base a ' o "), altrimenti segnala errore. Restituisce il valore che ritorna la compose

compose --> riceve in ingresso una lista di caratteri e un numero, definisce string1 che è il risultato della chiamata alla funzione strings, rest che contiene il 
contenuto di string1 eliminando i vari spazi e i :, value contiene il valore ritornato da json-value. Viene verificata la presenza dei ':'. Questa funzione ritorna una lista.

json-value --> riceve in ingresso una lista di caratteri e verifica : se inizia con i doppi apici o con i singoli apici e richiama la funzione strings, se inizia con
{ (se è un obj) chiama la json-obj, se inizia con [ (se è un array) chiama la json-array; inoltre verifica se è presente un numero (in questo caso vengono effettuati alcuni controlli).

strings --> riceve in ingresso una lista di caratteri e un numero, in base al numero richiama la control-dq o la control-sq, se la chiamata a una di queste funzione da esito
positivo viene costruita la stringa tramite concatenazioni.

control-dq --> riceve in ingresso un carattere e verifica che sia diverso dai doppi apici.

cotrol-sq --> riceve in ingresso un carattere e verifica che sia diverso dai singoli apici. 

end-obj --> riceve in ingresso una lista di caratteri e verifica se il primo carattere è la parentesi graffa chiusa.

json-array --> riceve in ingresso una lista di caratteri, chiama la funzione json-elements e restituisce come valore una lista formata da 'json-array, il car di elements e il
secondo valore di elements (elements valore ritornato dalla chiamata di json-elements).

json-elements --> riceve in ingresso una lista di caratteri verifica la presenza della ] e se è preceduta dalla virgola segnala errore; negli altri casi richiama la 
json-value in caso ci sia solo value o, anche, la json-elements se ci sono altri elementi, ritornando una lista.

end-array --> riceve in ingresso una lista di caratteri e verifica se il primo carattere è uguale alla parentesi quadra chiusa.

json-number --> riceve in ingresso una lista di caratteri  che passa alla json-digits,il valore ritornato da questa chiamata viene analizzato per verificare la correttezza del
numero, riconvertendo il primo carattere della lista (che è una stringa) in una lista di caratteri che viene prima analizzata per verificare la presenza di eventuali '- o +' 
"fuori posto", dopodichè viene analizzata per verificare la correttezza dei '.' all'interno del numero. Se passa tutti i controlli viene eseguito il parse-integer o il parse-float 
(convertono da stringa in numero). Restituisce come valore una lista.

json-digits --> riceve in ingresso una lista di caratteri che analizza verificando che sia un carattere permesso all'interno di un numero. Ritorna una lista il cui primo 
carattere è una stringa che rappresenta un numero.

control-char --> riceve in ingresso un carattere e verifica se corrisponde a un numero, verifico anche la presenza del punto, del meno e del più(vengono gestiti i numeri 
decimali sia positivi che negativi, i numeri interi sia positivi che negativi, i numeri positivi vengono accettati anche con il segno +) ritorna il numero come stringa.

control-num-dot --> riceve in input una lista di caratteri e conta il numero di punti all'interno del numero; è usato per capire se in un numero sono presenti più punti 
esempio 123.23.123; inoltre verifica se ci sono numeri terminanti con il punto ad esempio: 20. 

control-space-number --> riceve in input un carattere ed è usato nel json-value per verificare se dopo il segno ci sono spazi/newline/tab ad esempio: -  23

control-number --> è usato nel json-number per verificare la presenza di + o - nel corpo del numero; riceve in ingresso una lista di caratteri e restituisce True se il numero
è corretto, altrimenti genera un errore.

control-num --> questa funzione è chiamata nel corpo di control-number e serve per contare i segni + e - (queste due funzioni sono usate per controllare numeri inseriti 
in questo modo scorretto : 23-2   o   -2+23); riceve in ingresso una lista di caratteri.

delete-spaces --> cancella eventuali spazi, newline e tab all'interno della lista di caratteri; riceve in ingresso una lista di caratteri e restituisce un lista senza gli spazi
, tab, newline indesiderati.

json-get --> riceve in ingresso json (oggetto json parsato) e una lista variabile di argomenti; se la lista è vuota ritorna l'oggetto parsato ricevuto, in caso contrario 
verifica se si tratta di un array o di un oggetto chiamando la funzione appropriata, altrimenti solleva un errore.

search-obj --> riceve in ingresso due liste members e fields; 1) se members è vuota ritorna false;2) se fields è vuoto ritorna la testa di members;3) mentre se la testa 
della testa di members equivale alla testa di fields, l'elemeto contenuto dal resto della testa di members non è un atomo, esso verifica se contiene json-obj se non contiene 
quest'ultimo  allora verifica se contiene json-array e in base al caso chiama la funzione appropriata; altrimenti se non contiene uno di questi due valori ritorna il contenuto;
4) se questa condizione non è verificata chiama la search-obj passandogli il resto del contenuto di members e fields.

search-array --> riceve in ingresso due liste; 1) verifica se il primo elemento della lista fields è un numero, in caso contrario ritorna false; 2)verifica se il primo valore di 
fields contiene un numero minore di 0 e in caso affermativo ritorna false; 3)se il primo elemento di fields è 0 e qui si aggiungono altre condizione cioè: viene verificato
se la lista elements è vuota e in questo caso ritorna errore; viene verificato se la testa della testa della lista contiene json-obj o json-array e se il resto della lista 
(fields) è diverso dalla lista vuota, in caso affermativo esegue la funzione appropriata altrimenti esegue il search-obj passando come argomenti la lista elements e il resto 
della lista fields. 4) Se il primo valore di fields non è zero viene decrementato e viene richiamata la funzione search-array con il valore della testa di fields decrementata di
uno e il resto della lista elements.

json-write --> riceve in ingresso l'oggetto json parsato e un percorso; questa funzione scrive l'oggetto json (ottenuto dalla json-out) nel percorso specificato (se il 
percorso non è specificato viene scritto nel percorso di default); l'oggetto json è costruito passo passo tramite concatenazioni di stringhe.

json-out --> riceve in ingresso una lista e verifica se si tratta di un oggetto o di un array e in base al caso esegue la funzione apppropriata e ritorna il valore ottenuto.

members-json --> riceve una lista, ritorna il valore di pair-json se il cdr della lista in ingresso è vuota o la concatenazione tra pair e members se è presente quest'ultimo.

pair-json --> riceve una lista e concatena il valore ritornato da string-json con la stringa " : "   e questa l'ultima viene concatenata con il risultato di value-json.

string-json --> riceve un argomento e verifica se si tratta di una stringa e in caso affermativo la passa a control-string, altrimenti genera errore.

control-string --> riceve una stringa che converte in lista e verifica la presenza di eventuali doppi apici all'interno della stringa per decidere se aggiungere i doppi o i 
singoli apici.

control-double-quote --> riceve una lista e verifica la presenza di eventuali doppi apici e in questo caso restituisce true.

value-json --> riceve in ingresso una stringa, un numero, un array o oggetto, in base al caso applica una funzione diversa.

elements-json --> riceve una lista; se è composta da un solo valore chiama e ritorna il valore restituito da value-json, altrimenti chiama value-json sul car e poi sul cdr e 
concatena i risultati mettendo una stringa contenente una virgola in mezzo.

json-load -->riceve in ingresso un percorso di un file di cui legge il contenuto e su cui applica la json-parse; ritorna il valore restituito dalla json-parse.  

