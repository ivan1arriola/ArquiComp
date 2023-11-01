; ---------- SEGMENTO DE DATOS ----------

.data  
; En el segmento ES va a estar el arbol
#define ES 7000h
modo db 0 ; modo inicial estatico = 0, dinamico = 1
raiz dw 0 ; raiz del arbol

; Uso el puerto AX para leer entradas de los puertos y mandar salidas
; Uso el puerto BX para almacenar el modo (0 o 1)



; Constantes
VACIO equ 0x8000


; Puertos
PUERTO_ENTRADA equ 20
PUERTO_SALIDA equ 21
PUERTO_LOG equ 22


; Comandos del programa
CAMBIAR_MODO equ 1
AGREGAR_NODO equ 2
CALCULAR_ALTURA equ 3
CALCULAR_SUMA equ 4
IMPRIMIR_ARBOL equ 5
IMPRIMIR_MEMORIA equ 6
DETENER_PROGRAMA equ 255

; Codigos de bitacora
CODIGO_BITACORA EQU 64    ; Código de la bitácora
CODIGO_EXITO EQU 0        ; Código 0 si la operación se pudo realizar con éxito.
CODIGO_COMANDO_INVALIDO EQU 1  ; Código 1 si no se reconoce el comando (comando inválido).
CODIGO_PARAMETRO_INVALIDO EQU 2 ; Código 2 si el valor de algún parámetro recibido es inválido.
CODIGO_ESCRIBIR_FUERA_DE_AREA EQU 4 ; Código 4 si al agregar un nodo se intenta escribir fuera del área de memoria.
CODIGO_NODO_YA_EXISTE EQU 8     ; Código 8 si el nodo a agregar ya se encuentra en el árbol.


; Posibles modos del arbol
MODO_ESTATICO equ 0
MODO_DINAMICO equ 1

; Parametros para imprimir arbol
ORDEN_ASCENDENTE equ 0
ORDEN_DESCENDENTE equ 1


; Area de Memoria
AREA_MEMORIA equ 2048



; ---------- SEGMENTO DE CODIGO ----------
; Registros de uso general
; AX, BX, CX, DX, SI, DI, BP, SP

; AX: Registro acumulador
; BX: Registro base // Registro aqui el indice 0 del arbol
; CX: Registro contador
; DX: Registro de datos
; SI: Registro de fuente
; DI: Registro de destino
; BP: Registro de base
; SP: Registro de pila


; Registros de segmento
; CS, DS, ES, SS

; ES destinado a la memoria del arbol

; Registros de apuntadores
; IP, FLAGS




.code

reiniciarMemoria:
; Aqui se tiene que iniciarlizar la memoria //TODO: Aun no hace nada realmente
mov ax, ES
mov es, ax
mov cx, AREA_MEMORIA
mov ax, VACIO
mov di, 0
ciclo_inicializacion:
    mov es:[di], ax
    add di, 2
    

comienzoWhile:
mov ax, CODIGO_BITACORA; cargar en AX el codigo de bitacora
out PUERTO_LOG, ax; escribir_puerto(PUERTO_LOG, CODIGO_BITACORA);

in ax, PUERTO_ENTRADA ; comando = leer_puerto_entrada("Ingrese un comando:");
out PUERTO_LOG, ax; escribir_puerto(PUERTO_LOG, comando);


cmp ax, CAMBIAR_MODO
je cambiarModo

cmp ax, DETENER_PROGRAMA
je detenerPrograma

jmp comandoIncorrecto; si llega aca es porque no era un comando valido



cambiarModo:
    in ax, PUERTO_ENTRADA ; nuevoModo = leer_puerto_entrada("Ingrese parametro (0 o 1):")
	out PUERTO_LOG, AX; imprime el parametro en el puerto log


    cmp ax, 0
    je cambiarModoParametroCorrecto ; Salta a "cambiarModoParametroCorrecto" si ax es igual a 0

    cmp ax, 1
    je cambiarModoParametroCorrecto ; Salta a "cambiarModoParametroCorrecto" si ax es igual a 1
	call parametroIncorrecto; Si no se cumple ninguna de las anteriores, el parametro es incorrecto


	cambiarModoParametroCorrecto:
		mov BX, AX
		mov AX, CODIGO_EXITO
		out PUERTO_LOG, ax 
	
    jmp reiniciarMemoria ; Salta a "reiniciarMemoria"





;    call inicializar_memoria


;


; Inicializa la memoria del arbol
inicializar_memoria:
; el arbol tiene 2048 bytes de memoria
; todos los espacio de memoria estan inicializados en 0x8000
; el primer espacio de memoria es la raiz del arbol independientemente del modo



;ret




parametroIncorrecto:
mov AX, CODIGO_PARAMETRO_INVALIDO
out PUERTO_LOG, ax 
jmp comienzoWhile

comandoIncorrecto:
mov AX, CODIGO_COMANDO_INVALIDO
out PUERTO_LOG, ax 
jmp comienzoWhile



detenerPrograma:
    mov ax, CODIGO_EXITO ;                 ax = CODIGO_EXITO
    out PUERTO_LOG, ax ;        escribir_puerto(PUERTO_LOG, CODIGO_EXITO);
    ;FIN DEL PROGRAMA





; ---------- SEGMENTO DE PUERTOS ----------
.ports
20: 1, 0, 1, 1, 255



; ---------- SEGMENTO DE INTERRUPCIONES ----------

.interrupts 
