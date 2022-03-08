.code

;PROCEDURA PENTRU VERFICAREA OPERATIEI INTRODUSE SI IDENTIFICAREA EI
verificare proc
	push ebp
	mov ebp,esp
	;calculam lungimea sirului daca e 2 =>poate sa fie doar inmultire cu scalar si inmultire, daca e 3 => scadere sau adunare
	xor ecx,ecx
	mov esi,[ebp+8]
	et_numarare:
	    xor eax,eax
		mov al,[esi]
		cmp al,0
		je iesire
		inc ecx
		inc esi
		jmp et_numarare                     
	iesire:
	cmp ecx,2
		jb op_invalida
		je op_2
	cmp ecx,3
	    ja op_invalida     ;in cazul in care lungimea e diferita de 2 si 3 => operatie e invalida si se realizeaza saltul
		
		
	;verificam daca op e de adunare cu ajutorul instructiunii repe cmpsb care compara elementele a doua siruri
	;daca la final esi va pointa catre caractrul null(0) si ultimele elemente coincid => operatia e valida
	cld 
	mov esi,[ebp+8]
	lea edi, adunare
    mov ecx,3
	repe cmpsb 
	xor ebx,ebx
	mov bl,[esi]
	cmp bl,0
		jne next1         ;trebuie verificat si ultimul element!
	dec esi
	dec edi
	xor eax,eax
	mov al,[esi]
	cmp al,[edi]
		je op_adunare
	
	
	next1:
	;asemnea pentru scadere
	cld 
	mov esi,[ebp+8]
	lea edi, scadere
	mov ecx,3
	repe cmpsb 
	xor ebx,ebx
	mov bl,[esi]
	cmp bl,0
		jne op_invalida         ;trebuie verificat si ultimul element!!!! nu stiu de ce
	dec esi
	dec edi
	xor eax,eax
	mov al,[esi]
	cmp al,[edi]
		je op_scadere
	jmp op_invalida
	
	op_2:
	;pentru inmultire
	cld 
	mov esi,[ebp+8]
	lea edi, inmultire
	mov ecx,2
	repe cmpsb 
	xor ebx,ebx
	mov bl,[esi]
	cmp bl,0
		jne next2         ;trebuie verificat si ultimul element!
	dec esi
	dec edi
	xor eax,eax
	mov al,[esi]
	cmp al,[edi]
		je op_inmultire
	
	next2:
	;pentru inmultire scalara
	cld 
	mov esi,[ebp+8]
	lea edi, scalar
	mov ecx,3
	repe cmpsb 
	xor ebx,ebx
	mov bl,[esi]
	cmp bl,0
		jne op_invalida         ;trebuie verificat si ultimul element!
	dec esi
	dec edi
	xor eax,eax
	mov al,[esi]
	cmp al,[edi]
		je op_scalar
	;in urma acestor verificari se realizeza salturi spre etichetele corespunzatoare
	;astfel ,in registru eax va fi astfel modificat: operatie_invalida=-1, adunare=1,  scadere=2,  inmultire=3, inmultire_scalar=4
	op_invalida:
	mov eax,-1
	 jmp sfarsit_proc              ;se face jmp catre finalul procedurii
	
	op_adunare:
	    mov eax,1
	    jmp sfarsit_proc
	op_scadere:
		mov eax,2
		jmp sfarsit_proc
	op_inmultire:
		mov eax,3
		jmp sfarsit_proc
	op_scalar:
		mov eax,4
		jmp sfarsit_proc
	
	sfarsit_proc: 
	mov esp,ebp      ;prin operatia asta e refacut varful de stiva initial
	pop ebp          ;recuperarea valorii lui ebp
	ret 4            ;un singur parametru 	 
verificare endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;PROCEDURA PENTRU OPERATIA DE ADUNARE
;se vor incarca ca si paramatrii adresele fisierelor cu care se lucreaza
adunare_op proc
		push ebp                   
		mov ebp,esp                ;nu trebuie salvate registrele(eax,ebx,..) nu influenteaza continuarea programului
		sub esp,12                 ;vom avea nevoie de 3 variabile locale
		
		;punem in fisier tipul de operatie pe care il efectuam
		push offset adunare_out
		push offset mode_string
		push [ebp+8]
		call fprintf
		add esp,12        
		
		;citim primul  element din cele doua fisiere pentru a verifica daca avem matrici valide din punct de vedere al ordinului
		push offset aux
		push offset intreg
		push [ebp+16]
		call fscanf
		add esp,12       
		mov eax,aux
		mov [ebp-4],eax           ;ordinul matricei A
		
		push offset aux
		push offset intreg
		push [ebp+12]
		call fscanf
		add esp,12       
		mov eax,aux
		mov [ebp-8],eax          ;ordinul matricei B
		
		cmp eax,[ebp-4]
		;verificarea ordinului si luarea deciziei corespunzatoare -mesaj de eroare si sf procedurii SAU continuarea operatiei de adunare
		je continue
		    matrici_invalide               ;macro pentru mesaj
			push offset error_matrici 
			push offset mode_string
			push [ebp+8]
			call fprintf
			add esp,12
			jmp sfarsit
		
		continue:
		
		
		mov ecx,[ebp-4]            ; mutam ordinul matricilor in ecx
	    
		;se foloseste loop in loop astfel incat sa se parcurga matricele direct din fisier- se extrag cele doua elemente de la poz corespunzatoare, se aduna si se adauga in 
		;fisierul rezultat
		;de fiecare data cand se termina loop-ul interior(terminarea unei linii) se adauga in fisier new_line pentru aspect
		et_loop_ext:                 ;loop-ul exterior ce merge pe linii
			;se salveaza valoarea lui ecx pentru loop-ul exterior pe stiva
			push ecx  
			
			mov ecx,[ebp-4]               ;ia de fiecare data nr_de coloane	  		
			et_loop_int:                  ;parcurgere pe coloane
				push ecx                  ;salvam pe stiva pe ecx
				
				push offset aux           ;citim un element din matricea A
				push offset intreg
				push [ebp+16]
				call fscanf
				add esp,12            
				mov eax,aux
				mov [ebp-12],eax   
				
				push offset aux           ;citim un element din matricea B
				push offset intreg
				push [ebp+12]
				call fscanf
				add esp,12
				mov eax,aux               
				
				add eax,[ebp-12]          ;suma celor doua elemente e salvata in eax
		        
				push eax                  ;adaugam elementul in fisierul rezultat
				push offset intreg_sp
				push [ebp+8]
				call fprintf
				add esp,12
				
				pop ecx                    ;se recupereaza valoarea
				loop et_loop_int
		
		push offset new_line               ;se adauga linie noua-terminarea unei linii in matricea rezultat
		push offset mode_string
		push [ebp+8]
		call fprintf
		add esp,12
		pop ecx
		
		loop et_loop_ext
		; in [ebp-4]-ordin matrice A, [ebp-8]-ordin matrice B, [ebp-12]-un element din matricea A
				
    sfarsit:
    mov esp,ebp
	pop ebp
	ret 12
adunare_op endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;PROCEDURA PENTRU OPERATIA DE SCADERE- SIMILARA CELEI DE ADUNARE
scadere_op proc
push ebp                   
		mov ebp,esp                ;nu trebuie salvate registrele(eax,ebx,..) nu influenteaza continuarea programului
		sub esp,12                 ;vom avea nevoie de 4 variabile locale
		
		push offset scadere_out
		push offset mode_string
		push [ebp+8]
		call fprintf
		add esp,12         ; punem in fisier tipul de operatie pe care il efectuam
		
		push offset aux
		push offset intreg
		push [ebp+16]
		call fscanf
		add esp,12       
		mov eax,aux
		mov [ebp-4],eax           ;ordinul matricei A
		
		push offset aux
		push offset intreg
		push [ebp+12]
		call fscanf
		add esp,12       
		mov eax,aux
		mov [ebp-8],eax          ;ordinul matricei B
		
		cmp eax,[ebp-4]
		
		je continue
		    matrici_invalide
			push offset error_matrici 
			push offset mode_string
			push [ebp+8]
			call fprintf
			add esp,12
			jmp sfarsit
		
		continue:
		
		
		mov ecx,[ebp-4]            ; mutam ordinul matricilor in ecx
	    
		
		et_loop_ext:  
			push ecx
			mov ecx,[ebp-4] 			;loop-ul exterior ce merge pe linii
			et_loop_int:
				push ecx                     ;salvam pe stiva pe ecx
				
				push offset aux           ;citim un element din matricea B
				push offset intreg
				push [ebp+12]
				call fscanf
				add esp,12
				mov eax,aux     
				mov [ebp-12],eax
				
				push offset aux         ;citim un element din matricea A
				push offset intreg
				push [ebp+16]
				call fscanf
				add esp,12            
				mov eax,aux  
				
				sub eax,[ebp-12]      ;diferneta celor doua elemente e salvata in eax
		        
				push eax                ;adaugam elementul in fisierul rezultat
				push offset intreg_sp
				push [ebp+8]
				call fprintf
				add esp,12
				
				pop ecx
				loop et_loop_int
				
		push offset new_line
		push offset mode_string
		push [ebp+8]
		call fprintf
		add esp,12
		
		pop ecx
		loop et_loop_ext
		
				
    sfarsit:
    mov esp,ebp
	pop ebp
	ret 12
scadere_op endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;PROCEDURA PENTRU OPERATIA DE INMULTIRE CU SCALAR
;3 PARAMETRI - [EBP+16]-adresa fiserului cu matricea, [EBP+12]-fisierul rezultat  [EBP+8]-scalarul
scalar_op proc
		push ebp
		mov ebp,esp
		sub esp,8
		
		;se pune mesajul corespunzator operatiei in fisierul rezulatat
		push [ebp+8]
		push offset scalar_out
		push [ebp+12]
		call fprintf
		add esp,12
		
		;se determina ordinul matricei pe care se face calculele
		push offset aux
		push offset intreg
		push [ebp+16]
		call fscanf
		add esp,12       
		mov eax,aux
		mov [ebp-4],eax           
		
		;mutam ordinul matricilor in ec
		xor ecx,ecx
		mov ecx,[ebp-4]           
	    jecxz sfarsit
		
		;aceeasi abordare de loop in loop pentru citirea elementelor pe linii si ientificarea sfarsitul de linie cand se adauga new_line in fisier rezultat
		et_loop_ext:  
			  push ecx                  ;se salveaza valoarea pentru loop- ul exterior deoarece ecx sufera modificari
			  
			  mov ecx,[ebp-4] 			
			et_loop_int:
				push ecx                ;salvam pe stiva pe ecx
				
				;citim un element din matricea A
				push offset aux         
				push offset intreg
				push [ebp+16]
				call fscanf
				add esp,12            
				mov eax,aux  
				
				xor edx,edx
				mov ebx,[ebp+8]
				imul ebx                ;in eax regasim produsul scalar*element 
		        
				push eax                ;adaugam elementul in fisierul rezultat
				push offset intreg_sp
				push [ebp+12]
				call fprintf
				add esp,12
				
				pop ecx
				loop et_loop_int
				
		push offset new_line
		push offset mode_string
		push [ebp+12]
		call fprintf
		add esp,12
		
		pop ecx
		loop et_loop_ext
		
				
    sfarsit:
    mov esp,ebp
	pop ebp
	ret 12            ;3 paramatri
scalar_op endp 



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;PROCEDURA PENTRU OPERATIA DE INMULTIRE
;in prima faza se salveaza continutul fisierelor cu 2 matrici in vectorii auxiliari mat1 si mat2 si se foloseste adresarea indexata a alementelor
;celor doua matrici pentru calcule
inmultire_op proc
		push ebp
		mov ebp,esp
		sub esp,12                 ;vom avea nevoie de 4 variabile locale
		
		;mesaj in fisierul rezultat pentru 
		push offset inmultire_out
		push offset mode_string
		push [ebp+8]
		call fprintf
		add esp,12         ; punem in fisier tipul de operatie pe care il efectuam
		
		;verificare ordin
		push offset aux
		push offset intreg
		push [ebp+16]
		call fscanf
		add esp,12       
		mov eax,aux
		mov [ebp-4],eax           ;ordinul matricei A
		
		push offset aux
		push offset intreg
		push [ebp+12]
		call fscanf
		add esp,12       
		mov eax,aux
		mov [ebp-8],eax          ;ordinul matricei B
		
		cmp eax,[ebp-4]
		
		je continue
		    matrici_invalide
			push offset error_matrici 
			push offset mode_string
			push [ebp+8]
			call fprintf
			add esp,12
			jmp sfarsit
		
		continue:
		
		;se salveaza continutul fisierelor cu matrici in cele doua variabile 
		xor ebx,ebx
		mov eax,[ebp-4]
		mul eax
		mov ecx,eax            ;numarul total de elemente este ordin* ordin 
	    
		mov esi,0
		et_loop1:
			push ecx
			push offset aux
			push offset intreg
			push [ebp+16]
			call fscanf
			add esp,12
			mov eax,aux
			
			mov mat1[esi],eax
			add esi,4
			pop ecx
			loop et_loop1
		
		mov esi,0
		xor ebx,ebx
		mov eax,[ebp-4]
		mul eax
		mov ecx,eax
		et_loop2:
			push ecx
			push offset aux
			push offset intreg
			push [ebp+12]
			call fscanf
			add esp,12
			mov eax,aux
			
			mov mat2[esi],eax
			add esi,4
			pop ecx
		loop et_loop2
		
		; in [ebp-4] si [ebp-8] avem ordinul matricilor 
		; in [ebp-12] salvam suma de produse
		mov ecx,[ebp-4]
		xor edi,edi
		xor esi,esi
		mov eax,[ebp-4]
		mov aux,eax               ;in auxiliar salvam ordinul matricelor pentru a nu depasi numarul de bytes al instructiunii de jmp
        
		;edi- ajuta la determinarea liniei pt mat1 
		;edx- se foloseste pentru a det coloana in cadrul matricei mat1 si se foloseste pentru a det linia pentru matricea mat2 
		;esi- ajuta la det coloanei in cadrul mat2
		;voi folosi trei loop-uri -primul loop parcurge liniile din mat1 
								; -al doilea loop parcurge coloanele din mat1
								; -al treilea loop realizeaza suma produselor dintre o linie din mat1 si o coloana din mat2  
	
		et_big:
			push ecx
			mov ecx,[ebp-4]                   ;in ecx punem valoarea lui [ebp-4]
			    
				et_ext:
				 push ecx
				 xor edx,edx                    ;edx se initialzeza de fiecare data cand se termina o coloana din mat2
				 mov [ebp-12],edx               ;pentru suma
				 mov ecx,[ebp-4]
				 et_int:
					push edx
					
					shl edx,2                     ;deoarece avem tipul dword, astfel elementele ssunt pe 4 octeti
					mov ebx,mat1[edi+edx]         ;in ebx salvam elementul din matricea A -aflat la linia data de edi si coloana data de edx
					
					imul edx, aux    
					
					imul ebx,mat2[esi+ edx]       ;de fapt avem mat2[ esi +edx*(ordin))]- edx determina linia de la care se ia elementul, esi-coloana
					                              ;edx se inmulteste cu ordinul
												  ;in cazul acesta edx=edx*4 pt ca e tipu dd 
					add [ebp-12],ebx             ;se aduna la suma locala
					
					pop edx
					inc edx
					
					loop et_int
				
				push [ebp-12]             ;se adauga elementul in fisier
				push offset intreg_sp
				push [ebp+8]
				call fprintf
				add esp,12
				
				add esi,4	              ;se incrementeaza esi cu 4 octeti, astfel se trece la o noua coloana
				pop ecx
			
			loop et_ext
			
		push offset new_line
		push offset mode_string
		push [ebp+8]
		call fprintf
		add esp,12
		
		xor esi,esi
		mov ebx,[ebp-4]
		shl ebx,2
		add edi,ebx             ;se mai adauga octetii unei linii dupa terminarea acesteia 
		pop ecx
		
		loop et_big	
				
    sfarsit:
    mov esp,ebp
	pop ebp
	ret 12
inmultire_op endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
		