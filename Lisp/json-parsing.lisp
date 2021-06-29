;;Membri Gruppo:
;;Gabriele Ferrario 817518
;;Fernando Acuna Cama 817399


;;la funzione parsa un oggetto json (stringa) in una lista
(defun json-parse (json)
  (let ((chars (delete-spaces (coerce json 'list))))
    ;;chars contiene la lista di caratteri ottenuta dall'input
    (cond
     ((eql (car chars) #\{)
      ;;viene verificato se si tratta di un array
      (car (json-obj (delete-spaces (cdr chars)))))
     ;;viene verificato se si tratta di un oggetto
     ((eql (car chars) #\[)
      (car (json-array (delete-spaces (cdr chars)))))
     (T(error "Syntax Error")))))

;;costruice l'oggetto json
(defun json-obj (object)
  (let ((result (json-members (delete-spaces object))))
    (list (cons 'json-obj (car result)) (car (cdr result)))))

;;costruisce il members dell'oggetto
(defun json-members (members)
  (if (eql (car members) #\})
      (list NIL (cdr members))
    (let* ((result1 (json-pair members))
           (pair1 (car result1)) ;;contiene il pair elaborato 
           (remainder (delete-spaces (car (cdr result1)))))
      ;;remainder contiene quello da parsare
      (if (and (eql (car remainder) #\,) (eql (car (cdr remainder)) #\}))
          (error "Syntax Error")  
        ;;controllo per far si che i casi di questo tipo 
        ;;{"a" : "b",} non funzionino
        (if (eql (car remainder) #\,) ;; verifica di un eventuale members
            (let* ((result2 (json-members (delete-spaces (cdr remainder))))
                   (pair2 (car result2))
                   (remains (car (cdr result2))))
              (list (cons pair1 pair2) remains))
          (list (list pair1) (end-obj (delete-spaces remainder))))))))

;;costruisce il pair 
(defun json-pair (pair)
  (cond 
   ((eql (car pair) #\")
    (compose (cdr pair) 0)) 
   ;;con 0 controlla stringa nel caso " AnyCharSansDQ* " 
   ((eql (car pair) #\')
    (compose (cdr pair) 1)) 
   ;;1 controlla stringa nel caso ' AnyCharSansSQ* '
   (T (error "Syntax Error"))))

(defun compose (chars n)
  (let* ((string1 (strings chars n)) ;;viene costruita la stringa
         (rest (delete-spaces (cdr (delete-spaces (car (cdr string1))))))
         ;;qui vengono cancellati i :
         (value (json-value rest))) ;;viene costruito il value
    (if (not (eql(car(delete-spaces (car (cdr string1)))) #\:))
        ;; verifico la presenza dei ":" 
        (error "Syntax Error")
      (list (list (car string1) (car value)) (car (cdr value))))))

(defun json-value (value)
  (cond 
   ((eql (car value) #\")
    (strings (cdr value) 0))
   ;;controllo se il value è una stringa sia nel caso di ' o "
   ((eql (car value) #\')
    (strings (cdr value) 1))
   ;;controllo se inizia un array
   ((eql (car value) #\{)
    (json-obj (delete-spaces (cdr value))))
   ;;controllo se inizia un oggetto
   ((eql (car value) #\[)
    (json-array (delete-spaces (cdr value))))
   ;;controllo nel caso di numeri 
   ((and (or (eql (car value) #\- ) (eql (car value) #\+)) 
         (control-space-number (car (cdr value))))
   ;; verifico se dopo il segno ci sono degli spazi esempio "- 80"
    (json-number value))
   ((and (not (null (control-char (car value)))) (not (eql (car value) #\.)))
   ;;controllo se è un valore corretto di un numero e se è diverso da "." in
   ;;quanto un numero che inizia per "." non deve essere accettato
    (json-number value))
   (T(error "Syntax Error" value))))

;costruisco la stringa verificando l'eventuale
;; presenza di singoli o doppi apici
(defun strings (chars n)
  (let ((c (if (eq n 0) 
              (control-dq (car chars)) 
            (control-sq (car chars)))))
    (if (not (null c))
        ;;se il carattere è valido costruisco passo passo la
        ;;stringa tramite concatenazioni
        (let ((string1  (strings (cdr chars) n)))
          (list (concatenate 'string (list c) (car string1))
                (car (cdr string1))))
      (list "" (cdr chars)))))

;;controlla la presenza di doppi apici
(defun control-dq (c) 
  (if (not (eql c #\"))
      c
    NIL))

;;controlla la presenza di singoli apici
(defun control-sq (c) 
  (if (not (eql c #\'))
      c
    NIL))

;;verifica la terminanzione di un oggetto json
(defun end-obj (end)
  (if (eql (car end) #\})
      (cdr end)
    (error "Syntax Error")))

;;costruisce l'array
(defun json-array(array)
  (let ((elements (json-elements (delete-spaces array))))
    (list (cons 'json-array (car elements)) (car (cdr elements)))))

;;costruisce gli elementi dell'array
(defun json-elements (elements)
  (if (eql (car elements) #\])
      (list NIL (cdr elements))
    (let* (( element1 (json-value elements))
           (value (car element1));;contiene il value 
           (rest (delete-spaces (car (cdr element1)))))
      ;;rest contiene il resto da parsare
      (if (and (eql (car (cdr rest)) #\]) (eql (car rest) #\,))
          (error "Syntax Error")
        ;;controllo fatto per lo stesso motivo del json-members
        ;;quindi per i casi "[1,2,]"
        (if (eql (car rest) #\,)
            (let ((element2 (json-elements (delete-spaces (cdr rest)))))
              (list (cons value (car element2)) (car (cdr element2))))
          (list (list value) (end-array (delete-spaces rest))))))))

;;verifica la terminazione di un array
(defun end-array (l)
  (if (eql (car l) #\])
      (cdr l)
    (error "Syntax Error")))

;;costruisce il numero
(defun json-number (chars)
  (let* ((num (json-digits chars))
         (chars-num (coerce (car num) 'list)))
    ;; il car di num è una stringa
    (if (and (or (eql (car chars-num) #\-) (eql (car chars-num) #\+))
             (control-number (cdr chars-num)))
        T
      (control-number chars-num))
    ;;verifica la presenza di eventuali "-" all'interno del numero
    ;;in posizioni scorrette esempio "1234-34" o "-123-23"
    (list
     (cond 
      ;;viene stabilito se il numero è un intero o un decimale e viene 
      ;;anche verificata la composizione del numero
      ((and (eq (control-num-dot chars-num) 0) ) (parse-integer (car num)))
      ((and (eq (control-num-dot chars-num) 1) ) (parse-float (car num)))
      (T (error "Syntax Error")))
     (car (cdr num)))))

;;costruisce una lista il cui primo elemento contiene il numero sotto forma 
;;di stringa mentre il cdr contiene la parte da parsare
(defun json-digits (chars)
  (let ((char (control-char (car chars))))
    ;;contiene il numero in formato di stringa
    (if (not (null char))
        (let ((parsed (json-digits (cdr chars))))
          ;;viene costruito il numero tramite concatenazioni di stringhe
          (list (concatenate 'string char (car parsed)) (car (cdr parsed))))
      (list "" chars))))

;;Se il carattere c rappresenta un carattere che può comporre un numero
;;(considero anche . - +) lo restituisce come stringa
(defun control-char (c)
  (if (or (eql c #\0) (eql c #\1) (eql c #\2) (eql c #\3) (eql c #\4) 
          (eql c #\5) (eql c #\6) (eql c #\7) (eql c #\8) (eql c #\9) 
          (eql c #\.) (eql c #\-) (eql c #\+))
      (string c)))

;;ritorna 1 se è un numero con virgola  corretto, 0 se è un intero e
;; un numero >1 se è un numero scorretto scorretto del tipo 23.23.4
(defun control-num-dot (chars)
  (cond
   ((and (null (cdr chars)) (eql (car chars)#\.)) (error "Syntax Error"))
   ;;serve per controllare eventuali numeri terminanti per . esempio 23.
   ((null (car chars)) 0)
   ((eql (car chars) #\.) (+ 1 (control-num-dot (cdr chars))))
   (T(+ 0 (control-num-dot (cdr chars))))))

(defun control-space-number (char)
  ;;controlla la presenza di spazi tra il numero e il segno esempio - 1
  (if (or (eql char #\Space)
          (eql char #\Tab)
          (eql char #\Newline))
      (error "Syntax Error")
    T ))

;;control-number e control-num servono per cotrollare la presenza di
;;eventuali + e - all'interno di un numero esempio +123-213
(defun control-number (chars)
  (if (> (control-num chars) 0)
      (error "Syntax Error")
    T ))

;;simile al control-num-dot ma controlla la presenza di - e + multipli
(defun control-num (chars)
  (cond
   ((and (null (cdr chars)) (or (eql (car chars) #\-)
                                (eql (car chars) #\+)))
    (error "Syntax Error"))
   ;;serve per controllare eventuali numeri terminanti per - esempio 23-
   ((null (car chars)) 0)
   ((or (eql (car chars) #\-) (eql (car chars) #\+)) 
    (+ 1 (control-num (cdr chars))))
   (T(+ 0 (control-num (cdr chars))))))

;;funzione che cancella spazi, tab e newline
(defun delete-spaces (chars)
  (if (or (eql (car chars) #\Space) (eql (car chars) #\Tab) 
          (eql (car chars) #\Newline))
      (delete-spaces (cdr chars))
    chars))

;;funzione che recupera una "porzione" dell'oggetto json 
;;seguendo la lista fields
(defun json-get (json &rest fields)
  (cond
   ((null fields) json) ;caso in cui fields è vuoto
   ((eq (car json) 'JSON-OBJ) (search-obj (cdr json) fields))
   ((eq (car json) 'JSON-ARRAY) (search-array (cdr json) fields))
   (T (error "Syntax Error" json))))

(defun search-obj (members fields)
  (cond
   ((null members) nil) ;;caso in cui members è vuoto
   ((null fields) (car members));;caso in cui fields è terminato
   ;;casi in cui ho trovato la testa di fields in members
   ((and (equal (car (car members)) (car fields)) 
         (not (atom (car (cdr (car members))))) 
         (eq (car (car (cdr (car members)))) 'json-obj) 
		 (not (null (cdr fields)))) 
    (search-obj (cdr (car (cdr (car members)))) (cdr fields)))
   ((and (equal (car (car members)) (car fields)) 
         (not (atom (car (cdr (car members)))))
         (eq (car (car (cdr (car members)))) 'json-array) 
         (not (null (cdr fields)))) 
    (search-array (cdr (car (cdr (car members)))) (cdr fields)))
   ((equal (car (car members)) (car fields))
    (car (cdr (car members))))
   ;;eseguo la ricerca con il resto della lista members
   (T (search-obj (cdr members) fields))))

(defun search-array (elements fields)
  (cond
   ;;caso in cui non ho un numero 
   ((not (numberp (car fields)))
    NIL)
   ;;caso in cui devo cercare una posizione che rappresenta 
   ;;un numero negativo
   ((< (car fields) 0)
    NIL)
   ;;caso in cui ho trovato l'elemento
   ((if (eq (car fields) 0)
        (cond
         ((null elements)
          (error "Index Out of Bound"))
         ((and (not (atom (car elements))) 
			   (eq (car (car elements)) 'json-obj) 
               (not (null (cdr fields))))
          (search-obj (cdr (car elements)) (cdr fields)))
         ((and (not (atom (car elements))) 
			   (eq (car (car elements)) 'json-array) 
               (not (null (cdr fields))))
          (search-array (cdr( car elements)) (cdr fields)))
         (T(search-obj  elements (cdr fields))))
      ;;decremento il contatore e passo all'elemento dopo
      (search-array (cdr elements) (cons (- (car fields) 1) (cdr fields)))))))

;;funzione che scrive nel file
(defun json-write (JSON file)
  (with-open-file (str file
                       :direction :output
                       :if-exists :supersede
                       :if-does-not-exist :create)
    (format str (json-out JSON)))
  file)

;;conpone l'oggetto json tramite concatenazioni di stringhe
(defun json-out (json)
  (cond
   ((and (eq (car json) 'json-obj) (null (cdr json))) 
    '"{}")
   ((and (eq (car json) 'json-array) (null (cdr json)))
    '"[]")
   ((eq (car json) 'json-obj)
    (concatenate 'string "{ "(members-json (cdr json)) " }"))
   ((eq (car json) 'json-array)
    (concatenate 'string "[ "(elements-json (cdr json)) " ]"))
   (T (error "Syntax Error"))))

(defun members-json (pair) 
  (if (null (cdr pair))
      (pair-json (car pair)) 
    (concatenate 'string (pair-json (car pair)) ", " 
                 (members-json (cdr pair)))))

(defun pair-json (pair)
  (concatenate 'string (string-json (car pair)) " : " 
               (value-json (car (cdr  pair)))))

(defun string-json (string)
  (if (stringp string)
      (control-string string)
    (error "ERROR")))

;;verifico la presenza dei " per capire se devo inserire i singoli o 
;;i doppi apici per delimitare la stringa
(defun control-string (string)
  (let ((chars (coerce string 'list))) 
    (if (control-double-quote chars)
        (concatenate 'string '"'" string  '"'")
      (concatenate 'string '"\"" string '"\""))))

(defun control-double-quote (l)
  (cond
   ((null l)
    nil)
   ((eql (car l) #\")
    T)
   (T (control-double-quote (cdr l)))))

(defun value-json (value)  
  (cond
   ((stringp value) (string-json value))
   ((numberp value) (write-to-string value))
   (T (json-out value))))

(defun elements-json (value)
  (if (null (cdr value))
      (value-json (car value)) 
    (concatenate 'string (value-json (car value)) " , " 
                 (elements-json (cdr value)))))

;;funzione che mi permette di leggere il contenuto di un file
(defun json-load (file)
  (with-open-file (in file
                      :direction :input
                      :if-does-not-exist :error)
    ((lambda (text)
       (read-sequence text in)
       (json-parse text))
     (make-string (file-length in)))))

