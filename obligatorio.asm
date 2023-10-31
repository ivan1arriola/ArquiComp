; ---------- SEGMENTO DE DATOS ----------

.data  
; En el segmento ES va a estar el arbol
#define ES 7000h

; Variables
modo_arbol dw 0

punto_inicial_arbol dw 0

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

.code

; Inicio del programa
inicializacion PROC 
; inicializa un espacio de memoria para el arbol
; arbol[AREA_MEMORIA] = [VACIO, VACIO, ..., VACIO]

    mov cx, AREA_MEMORIA
    mov di, VACIO
    xor ax, ax ; ax = 0
    
    for:
        mov ES:ax, di
        inc ax
    loop for
    ret
inicializacion ENDP






main:


in ax, PUERTO_ENTRADA
mov comando, ax

do
;     while (CONTINUAR_PROGRAMA)
;     {
;         comando = leer_puerto_entrada("Ingrese un comando:");
;         escribir_puerto(PUERTO_LOG, CODIGO_BITACORA);
; 
;         if (comando == CAMBIAR_MODO)
;         {
;             parametro = leer_puerto_entrada("Ingrese un modo:");
;             cambiar_modo(parametro);
;         }
;         else if (comando == AGREGAR_NODO)
;         {
;             parametro = leer_puerto_entrada("Ingrese un valor:");
;             agregar_nodo(parametro);
;         }
;         else if (comando == CALCULAR_ALTURA)
;         {
;             calcular_altura();
;         }
;         else if (comando == CALCULAR_SUMA)
;         {
;             calcular_suma();
;         }
;         else if (comando == IMPRIMIR_ARBOL)
;         {
;             parametro = leer_puerto_entrada("Ingrese un orden (0 o 1):");
;             imprimir_arbol(parametro);
;         }
;         else if (comando == IMPRIMIR_MEMORIA)
;         {
;             parametro = leer_puerto_entrada("Ingrese un N cantidad de nodos:");
;             imprimir_memoria(parametro);
;         }
;         else if (comando == DETENER_PROGRAMA)
;         {
;             detener_programa();
;         }
;         else
;         {
;             escribir_puerto(PUERTO_LOG, CODIGO_COMANDO_INVALIDO);
;         }
;     }
; 
;     return 0;
; }

    call inicializar_memoria


;


; Declaraciones de funciones
; void cambiar_modo(short modo);
cambiar_modo:

; void agregar_nodo(short num);
agregar_nodo:

; void calcular_altura();
calcular_altura:

; void calcular_suma();
calcular_suma:

; void imprimir_arbol(short orden);
imprimir_arbol:

; void imprimir_memoria(short n);
imprimir_memoria:

; void detener_programa();
detener_programa:

; Versión estática
; void agregar_nodo_estatico(short num);
agregar_nodo_estatico:

; short calcular_altura_estatico(short indice);
calcular_altura_estatico:

; void calcular_suma_estatico();
calcular_suma_estatico:

; void imprimir_arbol_estatico_ascendente(short indice);
imprimir_arbol_estatico_ascendente:

; void imprimir_arbol_estatico_descendente(short indice);
imprimir_arbol_estatico_descendente:

; void imprimir_memoria_estatico(short n);
imprimir_memoria_estatico:

; void detener_programa_estatico();
detener_programa_estatico:

; Versión dinámica
; void agregar_nodo_dinamico(short num);
agregar_nodo_dinamico:

; short calcular_altura_dinamico(short indice);
calcular_altura_dinamico:

; void calcular_suma_dinamico();
calcular_suma_dinamico:

; void imprimir_arbol_dinamico_ascendente(short indice);
imprimir_arbol_dinamico_ascendente:

; void imprimir_arbol_dinamico_descendente(short indice);
imprimir_arbol_dinamico_descendente:

; void imprimir_memoria_dinamico(short n);
imprimir_memoria_dinamico:

; void detener_programa_dinamico();
detener_programa_dinamico:







; ---------- SEGMENTO DE PUERTOS ----------
.ports
; Puerto ENTRADA
20

; PUERTO SALIDA
21

; PUERTO LOG
22

; ---------- SEGMENTO DE INTERRUPCIONES ----------

.interrupts 
