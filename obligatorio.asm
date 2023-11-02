; ---------- SEGMENTO DE DATOS ----------

.data  

modo db 0 ; modo inicial estatico = 0, dinamico = 1

num dw 0 ; numero a agregar al arbol

lugarLibre dw 0 ; indice del lugar libre en memoria para AgregarNodoModoDinamico

; Uso el puerto AX para leer entradas de los puertos y mandar salidas

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
; BX: Registro base 
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

    cmp ax, CALCULAR_ALTURA
    je calcularAltura

    cmp ax, CALCULAR_SUMA
    je calcularSuma

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
	jmp parametroIncorrecto; Si no se cumple ninguna de las anteriores, el parametro es incorrecto


	cambiarModoParametroCorrecto:
		mov word ptr [modo], AX
		mov AX, CODIGO_EXITO
		out PUERTO_LOG, ax 
	
    jmp reiniciarMemoria ; Salta a "reiniciarMemoria"

agregarNodo:
    in ax, PUERTO_ENTRADA ; lee el valor del nodo de la entrada
	out PUERTO_LOG, AX; imprime el valor en el puerto log


    cmp word ptr [modo], 0 ; Si modo es 0, se accede al modo estatico
    jmp agregarNodoModoEstatico

    cmp word ptr [modo], 1 ; Si modo es 1, se accede al modo dinamico
    jmp agregarNodoModoDinamico


agregarNodoModoEstatico: ; Nodo = [valor], hijos se calculan con el indice

    mov word ptr [num], ax ; Guarda el valor del nodo en la variable num
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
            shl si, 1  ; Mueve a la izquierda (multiplica por 2)
            add si, 2  ; Agrega 2 para ir al hijo izquierdo
            jmp whileAgregarNodoEstatico ; Vuelve al bucle principal
        moverDerecha:
            shl si, 1  ; Mueve a la derecha (multiplica por 2)
            shl si, 1  ; Mueve a la derecha (multiplica por 2)
            add si, 4  ; Agrega 4 para ir al hijo derecho
            jmp whileAgregarNodoEstatico ; Vuelve al bucle principal

agregarNodoModoDinamico:; Nodo = [valor, Indice de hijoIzquierdo, Indice de hijoDerecho]
    ; Si el árbol está vacío, crea un nuevo nodo y hazlo raíz.
    mov si, 0
    mov cx, es:[si]
    cmp cx, VACIO
    jne buscarLugarLibre

    ; �?rbol vacío, crea nuevo nodo raíz
    mov es:[si], ax
    mov ax, CODIGO_EXITO
    out PUERTO_LOG, ax
    ret

buscarLugarLibre:
    ; Encuentra el primer lugar desocupado de la memoria
    mov word ptr [num], ax ; Guarda el valor del nodo en la variable num
    xor si, si; si será el índice de la memoria
    xor bx, bx  ; bx será el indice en el arreglo de nodos
buscarLugarLibreLoop:
    mov cx, es:[si]; Carga el valor del nodo actual en CX
    cmp cx, VACIO; Compara si el valor es VACIO
    jne lugarNoVacio ; Si no es vacío, salta al lugarNoVacio
lugarVacio:
    mov bx, si ; Almacena el índice del lugar libre en BX (indice en memoria)
    jmp lugarLibreEncontrado
lugarNoVacio:
    inc bx ; Incrementa el índice en el arreglo de nodos
    add si, 3 ; Incrementa el indice en memoria
    cmp si, AREA_MEMORIA ; Compara si el indice en memoria está fuera del área de memoria
    jl buscarLugarLibreLoop

lugarLibreEncontrado:
    ; Verifica que haya lugar para el nodo completo
    mov ax , si ; Carga el índice en memoria del lugar libre en AX
    add ax , 2 ; Suma 2 para obtener el índice del ultimo elemento del nodo
    cmp ax, AREA_MEMORIA ; Compara para ver si el índice del último elemento del nodo está fuera del área de memoria
    jg errorEscribirFueraDeArea ; Si es así, salta al manejo de error (fuera de área)

    ; Falta Verificar que efectivamente esta vacío el lugar

    mov cx, es:[si]; Carga el valor en la dirección de memoria apuntada por ES:SI en CX
    cmp cx, VACIO ; Compara si el valor es VACIO
    jne errorEscribirFueraDeArea
; Encuentra el nodo padre del nuevo nodo
    xor si, si; si será el índice de la memoria
    mov ax, word ptr [num]; Carga el valor del nodo en AX
    mov word ptr [lugarLibre], bx; Carga el índice del lugar libre en lugarLibre
encontrarPadre:
    mov cx, es:[si]; Carga el valor del nodo actual en CX
    cmp cx, ax; Compara el valor actual con el valor a agregar (CX y AX)
    je errorNodoYaExiste ; Si son iguales, el nodo ya existe
    jl hijoIzquierdo; Si el valor actual es menor, intenta enchufarlo en el hijo izquierdo
    ; Si el valor actual es mayor, intenta enchufarlo en el hijo derecho
hijoDerecho:    ; 
    cmp es:[si + 2], VACIO ; Compara si el hijo derecho está vacío
    jne hijoDerechoNoVacio; Si no está vacío, salta al hijoDerechoNoVacio
    add si, 2; Si está vacío, agrega 2 para ir al hijo derecho
    jmp nuevoNodoCreado
hijoDerechoNoVacio:
    mov bx, si; Como no está vacío, carga el índice del hijo derecho en BX
    add bx, si; Sumo para simular una multiplicación por 3
    add bx, si; Sumo para simular una multiplicación por 3
    mov si, bx; Cargo el índice en memoria en SI
    jmp encontrarPadre; Vuelve a buscar el padre del nuevo nodo

hijoIzquierdo:
    cmp es:[si + 1], VACIO; Compara si el hijo izquierdo está vacío
    jne hijoIzquierdoNoVacio; Si no está vacío, salta al hijoIzquierdoNoVacio
    inc si; Si está vacío, agrega 1 para ir al hijo izquierdo
    jmp nuevoNodoCreado
hijoIzquierdoNoVacio:
    mov bx, si; Como no está vacío, carga el índice del hijo derecho en BX
    add bx, si; Sumo para simular una multiplicación por 3
    add bx, si; Porque el indice en memoria es 3 veces el indice en el arreglo de nodos
    mov si, bx; Cargo el índice en memoria en SI
    jmp encontrarPadre; Vuelve a buscar el padre del nuevo nodo

nuevoNodoCreado: ; SI queda apuntando al la direccion de uno de los hijos del padre del nuevo nodo

    mov cx, word ptr [lugarLibre]; Carga el índice del lugar libre en CX
    mov es:[si], cx; Carga el índice del lugar libre en la dirección de memoria del hijo del padre del nuevo nodo

    ; Carga el nuevo nodo en el lugar libre
    mov si, cx; Carga el índice del lugar libre en SI, pero hay que multiplicarlo por 3
    add si, cx; Sumo para simular una multiplicación por 2
    add si, cx; Sumo para simular una multiplicación por 2

    mov es:[si], ax; Carga el valor del nodo en la dirección de memoria apuntada por ES:SI

    mov ax, CODIGO_EXITO
    out PUERTO_LOG, ax
    jmp comienzoWhile


calcularAltura:
    cmp word ptr [modo], 0 ; Si modo es 0, se accede al modo estatico
    jmp calcularAlturaEstatico

    cmp word ptr [modo], 1 ; Si modo es 1, se accede al modo dinamico
    jmp calcularAlturaDinamico

; Modo estatico

calcularAlturaEstatico:
    xor ax, ax; ax = 0 (altura)
    xor si, si; si = 0 (indice en memoria)

    push ax; Guarda el valor de ax en la pila (Variable de salida)
    push si; Guarda el valor de si en la pila (Variable de entrada)

    call calcularAlturaEstaticoRecursivo

    pop si; Recupera el valor de si de la pila (Variable de entrada)
    pop ax; Recupera el valor de ax de la pila (Variable de salida)

    out PUERTO_SALIDA, ax; Imprime la altura en el puerto de salida
    mov ax, CODIGO_EXITO; Carga el código de éxito en AX
    out PUERTO_LOG, ax; Imprime el código de éxito en el puerto log

    jmp comienzoWhile


calcularAlturaEstaticoRecursivo PROC
    pop dx; salvo direccion de retorno

    pop si; indice en memoria (Parametro de entrada)
    pop ax; variable de salida (altura)

    cmp si, AREA_MEMORIA; Compara si el índice en memoria está fuera del área de memoria
    jge alturaCeroEstatico; Si es así, salta al final

    mov cx, word ptr es:[si]; Carga el valor en la dirección de memoria apuntada por ES:SI en CX
    cmp cx, VACIO; Compara si el valor es VACIO
    je alturaCeroEstatico; Si es así, salta al final

    ; Calcula la altura del hijo izquierdo
    mov bx , si; en bx guardo el indice en memoria del hijo izquierdo
    shl bx, 1; multiplico por 2
    shl bx, 1; multiplico por 2
    add bx, 2; y le sumo 2 para obtener el indice en memoria del hijo izquierdo

    push dx; pusheo direccion de retorno
    push ax; Pusheo AX para almacenar la altura del hijo izquierdo
    push bx; Pusheo el indice en memoria del hijo izquierdo

    call calcularAlturaEstaticoRecursivo

    pop bx; Recupero el indice en memoria del hijo izquierdo (Lo voy a descartar realmente)
    pop bx; Recupero la altura del hijo izquierdo y lo almaceno en BX
    pop dx ; recupero direccion de retorno

    ; Calcula la altura del hijo derecho
    mov cx , si; en cx guardo el indice en memoria del hijo derecho
    shl cx, 1; multiplico por 2
    shl cx, 1; multiplico por 2
    add cx, 4; y le sumo 4 para obtener el indice en memoria del hijo derecho

    push dx; pusheo direccion de retorno
    push ax; Pusheo AX para almacenar la altura del hijo derecho
    push cx; Pusheo el indice en memoria del hijo derecho

    call calcularAlturaEstaticoRecursivo

    pop cx; Recupero el indice en memoria del hijo derecho (Lo voy a descartar realmente)
    pop cx; Recupero la altura del hijo derecho y lo almaceno en CX
    pop dx ; recupero direccion de retorno

    cmp bx, cx; Compara la altura del hijo izquierdo con la altura del hijo derecho
    jge alturaMaxEnHijoIzquierdo; Si la altura del hijo izquierdo es mayor o igual, salta a alturaMaxEnHijoIzquierdo

    alturaMaxEnHijoDerecho:
        mov ax, cx; Almacena la altura del hijo derecho en AX
        inc ax; Incrementa en 1 la altura del hijo derecho
        jmp calcularAlturaEstaticoRecursivoFin; Salta al final

    alturaMaxEnHijoIzquierdo:
        mov ax, bx; Almacena la altura del hijo izquierdo en AX
        inc ax; Incrementa en 1 la altura del hijo izquierdo
        jmp calcularAlturaEstaticoRecursivoFin; Salta al final

    alturaCeroEstatico:
        xor ax, ax; ax = 0 (altura)

    calcularAlturaEstaticoRecursivoFin:
        push ax; Pushea la altura en la pila (Variable de salida)
        push si; Pushea el índice en memoria en la pila (Variable de entrada)
        push dx; pusheo direccion de retorno
        ret; Retorna

calcularAlturaEstaticoRecursivo ENDP

calcularAlturaDinamico:
    xor ax, ax; ax = 0 (altura)
    xor si, si; si = 0 (indice en memoria)

    push ax; Guarda el valor de ax en la pila (Variable de salida)
    push si; Guarda el valor de si en la pila (Variable de entrada)

    ;call calcularAlturaDinamicoRecursivo

    pop si; Recupera el valor de si de la pila (Variable de entrada)
    pop ax; Recupera el valor de ax de la pila (Variable de salida)

    out PUERTO_SALIDA, ax; Imprime la altura en el puerto de salida
    mov ax, CODIGO_EXITO; Carga el código de éxito en AX
    out PUERTO_LOG, ax; Imprime el código de éxito en el puerto log

    jmp comienzoWhile


calcularAlturaDinamicoRecursivo PROC
    pop si; indice en memoria (Parametro de entrada)
    pop ax; variable de salida (altura)

    cmp si, AREA_MEMORIA; Compara si el índice en memoria está fuera del área de memoria
    jge alturaCeroDinamico; Si es así, salta al final

    mov cx, es:[si]; Carga el valor en la dirección de memoria apuntada por ES:SI en CX
    cmp cx, VACIO; Compara si el valor es VACIO
    je alturaCeroDinamico; Si es así, salta al final

calcularAlturaHijoIzquierdoDinamico:
    mov bx , si; en bx guardo el indice en memoria del hijo izquierdo
    add bx, 1; le sumo 1 para obtener el indice en memoria del hijo izquierdo

    push ax; Pusheo AX para almacenar la altura del hijo izquierdo
    push bx; Pusheo el indice en memoria del hijo izquierdo

    call calcularAlturaDinamicoRecursivo

    pop bx; Recupero el indice en memoria del hijo izquierdo (Lo voy a descartar realmente)
    pop bx; Recupero la altura del hijo izquierdo y lo almaceno en BX

calcularAlturaHijoDerechoDinamico:
    mov cx , si; en cx guardo el indice en memoria del hijo derecho
    add cx, 2; le sumo 2 para obtener el indice en memoria del hijo derecho

    push ax; Pusheo AX para almacenar la altura del hijo derecho
    push cx; Pusheo el indice en memoria del hijo derecho

    call calcularAlturaDinamicoRecursivo

    pop cx; Recupero el indice en memoria del hijo derecho (Lo voy a descartar realmente)
    pop cx; Recupero la

alturaCeroDinamico:
    xor ax, ax; ax = 0 (altura)
    jmp calcularAlturaDinamicoRecursivoFin; Salta al final

alturaMaxEnHijoDerechoDinamico:
    mov ax, cx; Almacena la altura del hijo derecho en AX
    inc ax; Incrementa en 1 la altura del hijo derecho
    jmp calcularAlturaDinamicoRecursivoFin; Salta al final

alturaMaxEnHijoIzquierdoDinamico:
    mov ax, bx; Almacena la altura del hijo izquierdo en AX
    inc ax; Incrementa en 1 la altura del hijo izquierdo
    jmp calcularAlturaDinamicoRecursivoFin; Salta al final

calcularAlturaDinamicoRecursivoFin:
    push ax; Pushea la altura en la pila (Variable de salida)
    push si; Pushea el índice en memoria en la pila (Variable de entrada)
    ret; Retorna

    
calcularAlturaDinamicoRecursivo ENDP



calcularSuma:
    cmp word ptr [modo], 0 ; Si modo es 0, se accede al modo estatico
    jmp calcularSumaEstatico

    cmp word ptr [modo], 1 ; Si modo es 1, se accede al modo dinamico
    jmp calcularSumaDinamico


calcularSumaEstatico:
    xor di, di; di = 0 (indice en memoria)
	mov cx, AREA_MEMORIA
    xor ax, ax; ax = 0 (suma)

    loopSumarEstatico:
        cmp di, AREA_MEMORIA  ; Compara si hemos llegado al final del área de memoria
        jae sumaEstaticoFin ; Si es así, salta al final

        mov CX, word ptr ES:[di]  ; Carga el valor en la dirección de memoria apuntada por ES:DI en CX
        cmp CX, VACIO  ; Compara si el valor es VACIO
        je nodoVacioSumaEstatico ; Si es VACIO, se ha encontrado un lugar para el nodo

        add ax, CX  ; Suma el valor actual al acumulador (AX)
        jmp nodoVacioSumaEstatico ; Salta al final

        nodoVacioSumaEstatico:
            add di, 2 ; Avanza al siguiente espacio de memoria (2 bytes por palabra)
            jmp loopSumarEstatico ; Vuelve al bucle principal

    sumaEstaticoFin:
        out PUERTO_SALIDA, ax; Imprime la suma en el puerto de salida
        mov ax, CODIGO_EXITO; Carga el código de éxito en AX
        out PUERTO_LOG, ax; Imprime el código de éxito en el puerto log

    jmp comienzoWhile
    

calcularSumaDinamico:
    xor di, di; di = 0 (indice en memoria)
    mov cx, AREA_MEMORIA
    xor ax, ax; ax = 0 (suma)

    loopSumarDinamico:
        cmp di, AREA_MEMORIA  ; Compara si hemos llegado al final del área de memoria
        jae sumaDinamicoFin ; Si es así, salta al final

        mov CX, word ptr ES:[di]  ; Carga el valor en la dirección de memoria apuntada por ES:DI en CX
        cmp CX, VACIO  ; Compara si el valor es VACIO
        je nodoVacioSumaDinamico ; Si es VACIO, se ha encontrado un lugar para el nodo

        add ax, CX  ; Suma el valor actual al acumulador (AX)
        jmp nodoVacioSumaDinamico ; Salta al final

        nodoVacioSumaDinamico:
            add di, 6 ; Avanza al siguiente espacio de memoria (6 bytes por palabra)
            jmp loopSumarDinamico ; Vuelve al bucle principal

    sumaDinamicoFin:
        out PUERTO_SALIDA, ax; Imprime la suma en el puerto de salida
        mov ax, CODIGO_EXITO; Carga el código de éxito en AX
        out PUERTO_LOG, ax; Imprime el código de éxito en el puerto log
    
    jmp comienzoWhile



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





; Tuve que hacer los procedimientos porque no me daban los registros para hacerlo con saltos
parametroIncorrectoProc PROC
    push AX
    mov AX, CODIGO_PARAMETRO_INVALIDO
    out PUERTO_LOG, ax 
    jmp comienzoWhile
    pop AX
    ret
parametroIncorrectoProc ENDP
comandoIncorrectoProc PROC
    push AX
    mov AX, CODIGO_COMANDO_INVALIDO
    out PUERTO_LOG, ax 
    jmp comienzoWhile
    pop AX
    ret
comandoIncorrectoProc ENDP
errorNodoYaExisteProc PROC
    push AX
    mov ax, CODIGO_NODO_YA_EXISTE
    out PUERTO_LOG, ax
    jmp comienzoWhile
    pop AX
    ret
errorNodoYaExisteProc ENDP
errorEscribirFueraDeAreaProc PROC
    push AX
    mov AX, CODIGO_ESCRIBIR_FUERA_DE_AREA
    out PUERTO_LOG, ax 
    jmp comienzoWhile
    pop AX
    ret
errorEscribirFueraDeAreaProc ENDP





detenerPrograma:
    mov ax, CODIGO_EXITO ;                 ax = CODIGO_EXITO
    out PUERTO_LOG, ax ;        escribir_puerto(PUERTO_LOG, CODIGO_EXITO);
    ;FIN DEL PROGRAMA








; ---------- SEGMENTO DE PUERTOS ----------
.ports
20: 1,0,2,100,2,200,2,50,2,30,2,150,4,1,1,2,102,2,202,2,52,2,32,2,152,4,255



; ---------- SEGMENTO DE INTERRUPCIONES ----------

.interrupts 
