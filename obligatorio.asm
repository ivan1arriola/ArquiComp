; ---------- SEGMENTO DE DATOS ----------

.data  

modo db 0 ; modo inicial estatico = 0, dinamico = 1
raiz dw 0 ; raiz del arbol

; Uso el puerto AX para leer entradas de los puertos y mandar salidas
; Uso el puerto BX para almacenar el modo (0 o 1)



; Constantes
VACIO equ 0x8000

; En el segmento ES va a estar la raiz del arbol
#define ES 7000h
;SEGMENTO_ARBOL equ 7000h


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

; Inicializa la memoria del arbol
reiniciarMemoria:
    mov ax, VACIO         ; Valor a inicializar en la memoria
    mov di, 0             ; Inicializar el registro de �ndice DI a 0
	mov cx, AREA_MEMORIA

inicializar_bucle:
    mov ES:[di], ax       ; Almacena el valor de AX en la direcci�n de memoria apuntada por ES:DI
    add di, 2             ; Avanza al siguiente espacio de memoria (2 bytes por palabra)
    dec cx                ; Decrementa el contador
    jnz inicializar_bucle ; Salta de nuevo al bucle si CX no ha llegado a cero



comienzoWhile:
    mov ax, CODIGO_BITACORA; cargar en AX el codigo de bitacora
    out PUERTO_LOG, ax; imprime en LOG el codigo de bitacora

    in ax, PUERTO_ENTRADA ; almacena en AX el comando 
    out PUERTO_LOG, ax; escribe el comando por LOG

	; Busca si algun comando coincide y redirije hacia ahi, en otro casi imprime error
    cmp ax, CAMBIAR_MODO
    je cambiarModo

	cmp ax, AGREGAR_NODO
    je agregarNodo

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

agregarNodo:
    in ax, PUERTO_ENTRADA ; lee el valor del nodo de la entrada
	out PUERTO_LOG, AX; imprime el valor en el puerto log


    cmp BX, 0 ; Si BX es 0, se accede al modo estatico
    jmp agregarNodoModoEstatico

    cmp BX, 1 ; Si BX es 1, se accede al modo dinamico
    jmp agregarNodoModoDinamico


agregarNodoModoEstatico:
    mov si, 0  ; Inicializa el índice en 0
    whileAgregarNodoEstatico:
        cmp si, AREA_MEMORIA  ; Compara si hemos llegado al final del área de memoria
        jae errorEscribirFueraDeArea ; Si es así, salta al manejo de error (fuera de área)

        mov CX, ES:[si]  ; Carga el valor en la dirección de memoria apuntada por ES:SI en CX
        cmp CX, VACIO  ; Compara si el valor es VACIO
        je nodoVacioEncontrado ; Si es VACIO, se ha encontrado un lugar para el nodo

        cmp CX, AX  ; Compara el valor actual con el valor a agregar (CX y AX)
        je nodoDuplicado ; Si son iguales, el nodo ya existe
        jl moverIzquierda ; Si el valor actual es menor que el valor a agregar, muévete a la izquierda
        jge moverDerecha ; Si es mayor o igual, muévete a la derecha

        nodoVacioEncontrado:
            mov ES:[si], ax ; Almacena el valor en la dirección de memoria apuntada por ES:SI
            mov ax, CODIGO_EXITO ; Código de éxito
            out PUERTO_LOG, ax ; Imprime el código de éxito en el puerto log
            jmp comienzoWhile
        nodoDuplicado:
            jmp errorNodoYaExiste ; Salta al manejo de error (nodo duplicado)
        moverIzquierda:
            shl si, 1  ; Mueve a la izquierda (multiplica por 2)
            inc si  ; Agrega 1 para ir al hijo izquierdo
            jmp whileAgregarNodoEstatico ; Vuelve al bucle principal
        moverDerecha:
            shl si, 1  ; Mueve a la derecha (multiplica por 2)
            add si, 2  ; Agrega 2 para ir al hijo derecho
            jmp whileAgregarNodoEstatico ; Vuelve al bucle principal


agregarNodoModoDinamico:
; TODO
	jmp comienzoWhile ; Salta al main nuevamente






	



;    call inicializar_memoria


;










parametroIncorrecto:
    mov AX, CODIGO_PARAMETRO_INVALIDO
    out PUERTO_LOG, ax 
    jmp comienzoWhile
comandoIncorrecto:
    mov AX, CODIGO_COMANDO_INVALIDO
    out PUERTO_LOG, ax 
    jmp comienzoWhile
errorNodoYaExiste:
    mov ax, CODIGO_NODO_YA_EXISTE
    out PUERTO_LOG, ax
    jmp comienzoWhile
errorEscribirFueraDeArea:
    mov AX, CODIGO_ESCRIBIR_FUERA_DE_AREA
    out PUERTO_LOG, ax 
    jmp comienzoWhile



detenerPrograma:
    mov ax, CODIGO_EXITO ;                 ax = CODIGO_EXITO
    out PUERTO_LOG, ax ;        escribir_puerto(PUERTO_LOG, CODIGO_EXITO);
    ;FIN DEL PROGRAMA





; ---------- SEGMENTO DE PUERTOS ----------
.ports
20: 1,0,2,5,2,-1,2,5,2,7,2,8,2,9,2,10,2,11,2,12,2,13,2,14,2,15,2,16,2,17,2,18,255



; ---------- SEGMENTO DE INTERRUPCIONES ----------

.interrupts 
