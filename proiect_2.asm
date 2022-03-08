; NUME SI PRENUME: BÎRLUȚIU CLAUDIU-ANDREI
; NIVERSITATEA TEHNICA CLUJ-NAPOCA
;  AC, CTI-ro,SERIA B, AN 1, GRUPA 6

.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib

extern exit: proc
extern printf: proc
extern scanf: proc
extern fopen: proc
extern fclose: proc
extern fscanf: proc
extern fprintf: proc


include macrouri.asm
include proceduri.asm



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod


.data
;aici declaram date

;MESAJE PRIVIND DESCHIDEREA FISIERELOR SI CITIREA OPERATIE DE EFECTUAT
operatie_ db " Ce operatie sa se execute?",10,"		ADUNARE: A+B",10,"		SCADERE: A-B",10,"		INMULTIRE: AB",10,"		INMULTIRE CU SCALAR: aA",10,"                  ",0
mesaj_fisiere db "Scrieti fisierele unde se gasesc matricele (maxim 10 caractere)",10,0
mesaj_rezulat db "Scrieti fisierul pentru scrierea rezultatului (maxim 20 caractere)",10,0

;MESAJE PENTRU NUMELE FISIERELOR
mat_a   db "              A=",0
mat_b   db "              B=",0
mat_rez db "              REZULTAT=",0

;MODUL DE DESCHIDERE A FISIERELOR 
mode_read db "r",0
mode_write db "w",0

operatie db 10 dup(0)           ; maxim 10 caratere de 1 octet fiecare pentru operatie


;numele fisierelor cu care se lucreaza
fisier_a db 10 dup(0)
fisier_b db 10 dup(0)
fisier_rez db 20 dup (0) 

;adresele fisierelor pe care le deschidem
adresa_a   dd ?          
adresa_b   dd ?
adresa_rez dd ?

;tipuri de date 
intreg db "%d",0
mode_string db "%s",0           ; declarearea modului pt tipul string

;MESAJE PT ERORI
eroare_fisier db "Fisierul nu poate fi deschis!",10,"Incercati un alt fisier",10,0
error_op      db "Operatia introdusa nu e valida!",10,"	Incercati din nou!",10,0 
error_matrici db "Matricile sunt de ordine diferite!",10,0      

;stringuri pentru identificarea operatiei de executat
adunare db "A+B",0
scadere db "A-B",0
inmultire db "AB",0
scalar db "aA",0

;MESAJE PENTRU ASPECT CONTINUT FISIER IN FUNCTIE DE OPERATIE
adunare_out db "  ------ A + B ------",10,0
scadere_out db "  ------ A - B ------  ",10,0
scalar_out  db "  ------ %d *A ------  ",10,0
inmultire_out db "  ----- AB -------  ",10,0
intreg_sp     db "%d ",0     ;pentru a pune spatiu intre elemente
new_line db 10,0

;pentru inmultire cu scalar
mesaj_scalar db "Citeste scalarul!",10,"             a=",0
a   dd ?

;auxuliare prntru calcule
mat1 dd 100 dup (0)
mat2 dd 100 dup(0)
aux dd ?            ;pentru a citi elementele din fisier in cadrul procedurilor


;mesaja pt finalul programului + modul character
other_op db "Vrei sa faci o noua operatie?",10,"            Da=y/Y NU=alta_tasta",10,"          Decizie=",0
mode_char db "%*c%c",0                 ;%*c -pentru a ignora spatiul generat de enter (bufferul de tastatura)
decizie dd ?
 

.code



    	
start:
   noua_op:
   citire_operatie offset operatie
    
    ;verificare operatie	
	push offset operatie
	call verificare                  ;se modifica eax in functie de ce operatie este
	
	cmp eax,-1
		jne next_operation1         ;DACA NU E OK OPERATIA SE VA CITI DIN NOU
		eroare_operatie
		jmp noua_op
		
		
	next_operation1:
	
	cmp eax,1
	   je et_adunare
	cmp eax,2
		je et_scadere
	cmp eax,3
		je et_inmultire
	cmp eax,4
		je et_scalar
	
	
	
	et_adunare:
	    mesaj_deschidere1
		open_fisiere fisier_a,   mat_a,   adresa_a,   mode_read
		open_fisiere fisier_b,   mat_b,   adresa_b,   mode_read
		mesaj_deschidere2
		open_fisiere fisier_rez, mat_rez, adresa_rez, mode_write
		push adresa_a
		push adresa_b
		push adresa_rez
		call adunare_op
        jmp  next_operation
	
	et_scadere:
		mesaj_deschidere1
		open_fisiere fisier_a,   mat_a,   adresa_a,   mode_read
		open_fisiere fisier_b,   mat_b,   adresa_b,   mode_read
		mesaj_deschidere2
		open_fisiere fisier_rez, mat_rez, adresa_rez, mode_write
	    push adresa_a
		push adresa_b
		push adresa_rez
		call scadere_op
		jmp next_operation
	
	et_inmultire:
	    mesaj_deschidere1
		open_fisiere fisier_a,   mat_a,   adresa_a,   mode_read
		open_fisiere fisier_b,   mat_b,   adresa_b,   mode_read
		mesaj_deschidere2
		open_fisiere fisier_rez, mat_rez, adresa_rez, mode_write
		push adresa_a
		push adresa_b
		push adresa_rez
		call inmultire_op
		
		jmp next_operation
	
	et_scalar:
	    mesaj_deschidere1
		open_fisiere fisier_a,   mat_a,   adresa_a,   mode_read
		mesaj_deschidere2
		open_fisiere fisier_rez, mat_rez, adresa_rez, mode_write
		
		citeste_scalar a
	    
		push adresa_a
		push adresa_rez
		push a
		call scalar_op
		
		jmp next_operation_scalar
	
	 
	next_operation:
	
	
	push adresa_b
	call fclose
	add esp,4
	
	next_operation_scalar:
	push adresa_a
	call fclose
	add esp,4
	
	push adresa_rez
	call fclose
	add esp,4
	
	alta_operatie
	
	push offset decizie
	push offset mode_char
	call scanf
	add esp,8 
	
	
	cmp decizie,'y'
	je noua_op
	cmp decizie,'Y'
	je noua_op
	
	
	
	
	
	
	
	;terminarea programului
	push 0
	call exit
end start
