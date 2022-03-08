;MACRO OPERATIE
citire_operatie macro op
    push eax
	push offset operatie_
	push offset mode_string
	call printf
	add esp,8
	
	push op
	push offset mode_string
	call scanf
	add esp,8
	pop eax	
endm




;MACRO deschidere fisiere
open_fisiere macro fisier, mesaj, adresa, mode_open
	local reciteste,succes_fis
     	push ebx
		push ecx
		
		reciteste:
		push  offset mesaj
		push offset mode_string
		call printf
		add esp,8
		
		push offset fisier
		push offset mode_string
		call scanf
		add esp,8
		
		push offset mode_open
		push offset fisier
		call fopen
		add esp,8
		
		cmp eax,0
		jne succes_fis
			
			push offset eroare_fisier
			push offset mode_string
			call printf
			add esp,8
			
			jmp reciteste
			
		succes_fis:
		
		mov adresa,eax
		
		pop ecx
		pop ebx
		
endm


; mesaj fisiere citire matrici

mesaj_deschidere1 macro 
		push eax
		
		push offset mesaj_fisiere
		push offset mode_string
		call printf
		add esp,8
		
		pop eax
endm

;mesaj creare fisier pentru rezulatat
mesaj_deschidere2 macro 
		push eax
		
		push offset mesaj_rezulat
		push offset mode_string
		call printf
		add esp,8
		
		pop eax
endm

; eroare operatie
  eroare_operatie macro
		push eax
		
		push offset error_op
		push offset mode_string
		call printf
		add esp,8
		
		pop eax
endm

; matrici incorecte
 matrici_invalide macro
		push eax
		
		push offset error_matrici
		push offset mode_string
		call printf
		add esp,8
		
		pop eax
endm

;citeste scalar
citeste_scalar macro n
	push eax 
	
	push offset mesaj_scalar
	push offset mode_string 
	call printf
	add esp,8
	
	push offset n
	push offset intreg
	call scanf 
	add esp,8
	
	pop eax
endm

;alta operatie macro
alta_operatie macro 
   push eax
   push ebx
   push ecx
   
	push offset other_op
	push offset mode_string
	call printf 
    add esp,8

	
	pop ecx
	pop ebx
	pop eax
	
endm
	
	
