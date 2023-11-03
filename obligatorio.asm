; ---------- SEGMENTO DE DATOS ----------

.data  

modo db 0 ; modo inicial estatico = 0, dinamico = 1
num dw 0 ; numero a agregar al arbol
lugarLibre dw 0 ; indice del lugar libre en memoria para AgregarNodoModoDinamico

; Constantes
VACIO equ 0x8000

; En el segmento ES va a estar la raiz del arbol
#define ES 7000h

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
AREA_MEMORIA equ 4096; 4096 bytes de memoria (2048 palabras de 16 bits)


.code

jmp comienzoWhile; Salta al comienzo del bucle principal

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

    cmp ax, IMPRIMIR_ARBOL
    je imprimirArbol

    cmp ax, IMPRIMIR_MEMORIA
    je imprimirMemoria

    cmp ax, DETENER_PROGRAMA
    je detenerPrograma

    jmp comandoIncorrecto; si llega aca es porque no era un comando valido



cambiarModo:
    in ax, PUERTO_ENTRADA ; lee el valor del modo de la entrada
	out PUERTO_LOG, AX; imprime el parametro en el puerto log

    cmp ax, 0
    je cambiarModoParametroCorrecto ; Salta a "cambiarModoParametroCorrecto" si ax es igual a 0

    cmp ax, 1
    je cambiarModoParametroCorrecto ; Salta a "cambiarModoParametroCorrecto" si ax es igual a 1

    
	jmp parametroIncorrecto; Si no se cumple ninguna de las anteriores, el parametro es incorrecto

	cambiarModoParametroCorrecto:
		mov [modo], ax ; Guarda el valor del modo en la variable modo
		mov AX, CODIGO_EXITO
		out PUERTO_LOG, ax 
	
    jmp reiniciarMemoria ; Salta a "reiniciarMemoria"

agregarNodo:
    in ax, PUERTO_ENTRADA ; lee el valor del nodo de la entrada
	out PUERTO_LOG, AX; imprime el valor en el puerto log

    mov word ptr [num], ax ; Guarda el valor del nodo en la variable num

    cmp byte ptr [modo], 0 ; Si modo es 0, se accede al modo estatico
    je agregarNodoModoEstatico

    cmp byte ptr [modo], 1 ; Si modo es 1, se accede al modo dinamico
    je agregarNodoModoDinamico

    jmp errorDesconocido ; Si no se cumple ninguna de las anterior, algo esta mal





agregarNodoModoEstatico: ; Nodo = [valor], hijos se calculan con el indice
    mov si, 0  ; Inicializa el índice en 0
    whileAgregarNodoEstatico:
        cmp si, AREA_MEMORIA  ; Compara si hemos llegado al final del área de memoria
        jae errorEscribirFueraDeArea ; Si es así, salta al manejo de error (fuera de área)

        mov CX, ES:[si]  ; Carga el valor en la dirección de memoria apuntada por ES:SI en CX
        cmp CX, VACIO  ; Compara si el valor es VACIO
        je nodoVacioEncontrado ; Si es VACIO, se ha encontrado un lugar para el nodo

        cmp AX, CX  ; Compara el valor actual con el valor a agregar (CX y AX)
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
            add si, 2  ; Agrega 2 para ir al hijo izquierdo
            jmp whileAgregarNodoEstatico ; Vuelve al bucle principal
        moverDerecha:
            shl si, 1  ; Mueve a la derecha (multiplica por 2)
            add si, 4  ; Agrega 4 para ir al hijo derecho
            jmp whileAgregarNodoEstatico ; Vuelve al bucle principal




agregarNodoModoDinamico:; Nodo = [valor, Indice de hijoIzquierdo, Indice de hijoDerecho]

    mov cx, es:[0]; Carga el valor del nodo 0 en CX
    cmp cx, VACIO;  Si el árbol está vacío, crea un nuevo nodo y hazlo raíz.
    jne buscarLugarLibre; Si no está vacío, busca un lugar libre para agregar el nuevo nodo

    ; Arbol vacío, crea nuevo nodo raíz
    mov es:[0], ax
    jmp agregarNodoModoDinamicoFin


buscarLugarLibre:

    xor di, di; di es el índice en memoria, inicializado en 0
    xor ax, ax; ax es la ubicación dentro del arreglo de nodos, inicializado en 0
    mov bx, word ptr [num]; bx es el valor del nodo nuevo a insertar

    loopBuscarLugarEnArreglo:
        inc ax; Incrementa en 1 la ubicación dentro del arreglo de nodos
        add di, 6; Suma 6 para avanzar al siguiente nodo (6 bytes por nodo)

        mov cx, es:[di]; Carga el valor del nodo actual en CX
        cmp cx, bx; Compara el valor actual con el valor a agregar (CX y BX)
        je errorNodoYaExiste ; si son iguales, el nodo ya existe; por construccion tiene que pasar por todos los nodos antes de llegar a un nodo vacio

        cmp cx, VACIO; Compara si el valor actual es VACIO, si no es vacio repite el loop
        jne loopBuscarLugarEnArreglo

    mov si, di; cargo si para usarlo para chequear si hay lugar suficiente para agregar el nuevo nodo
    add si, 5; Sumo 5 para saber si hay lugar suficiente para agregar el nuevo nodo
    cmp si, AREA_MEMORIA; Compara si el índice en memoria está fuera del área de memoria
    jae errorEscribirFueraDeArea; Si es así, salta al manejo de error (fuera de área)

crearNuevoNodo: ; Crea un nuevo nodo en el lugar libre (DI) encontrado

    mov es:[di], bx; Carga el valor del nodo en la dirección de memoria del nuevo nodo
    mov es:[di + 2], VACIO; Carga el valor VACIO en la dirección de memoria del hijo izquierdo
    mov es:[di + 4], VACIO; Carga el valor VACIO en la dirección de memoria del hijo derecho

conectarNodo: ; Conecta el nuevo nodo al árbol ; Se asume que el nuevo nodo no es la raíz

    xor di, di; di indica el índice en memoria, inicializado en 0
    mov bx, word ptr [num]; bx es el valor del nodo nuevo

conectarNodoLoop:
    mov cx, es:[di]; Carga el valor del nodo actual en CX

    cmp bx, cx; Compara el valor actual con el valor a agregar (CX y BX)
    jl buscarEnIzquierda ; Si el valor actual es menor que el valor a agregar, muévete a la izquierda
    jge buscarEnDerecha ; Si es mayor o igual, muévete a la derecha

buscarEnIzquierda:
    mov cx, es:[di + 2]; Carga el indice del hijo izquierdo en CX (cada indice ocupa 6 bytes)
    cmp cx, VACIO; Compara si el valor es VACIO
    je conectarNodoIzquierda ; Si es VACIO, se ha encontrado un lugar para el nodo

    ; Si no es VACIO, avanzar al nodo hijo izquierdo
    mov di, cx; Carga el indice del hijo izquierdo en DI
    add di, cx; Suma el indice del hijo izquierdo a DI
    add di, cx; Suma el indice del hijo izquierdo a DI
    add di, cx; Suma el indice del hijo izquierdo a DI
    add di, cx; Suma el indice del hijo izquierdo a DI
    add di, cx; Suma el indice del hijo izquierdo a DI (6 bytes por nodo)

    jmp conectarNodoLoop ; Vuelve al bucle principal

 buscarEnDerecha:
    mov cx, es:[di + 4]; Carga el indice del hijo derecho en CX (cada indice ocupa 6 bytes)
    cmp cx, VACIO; Compara si el valor es VACIO
    je conectarNodoDerecha ; Si es VACIO, se ha encontrado un lugar para el nodo

    ; Si no es VACIO, avanzar al nodo hijo derecho
    mov di, cx; Carga el indice del hijo derecho en DI
    add di, cx; Suma el indice del hijo derecho a DI
    add di, cx; Suma el indice del hijo derecho a DI
    add di, cx; Suma el indice del hijo derecho a DI
    add di, cx; Suma el indice del hijo derecho a DI
    add di, cx; Suma el indice del hijo derecho a DI (6 bytes por nodo)

    jmp conectarNodoLoop ; Vuelve al bucle principal

conectarNodoIzquierda:
    mov es:[di + 2], ax; Carga el valor del nodo en la dirección de memoria del hijo izquierdo
    jmp agregarNodoModoDinamicoFin

conectarNodoDerecha:
    mov es:[di + 4], ax; Carga el valor del nodo en la dirección de memoria del hijo derecho
    jmp agregarNodoModoDinamicoFin

agregarNodoModoDinamicoFin:
    mov ax, CODIGO_EXITO; Carga el código de éxito en AX
    out PUERTO_LOG, ax; Imprime el código de éxito en el puerto log
    jmp comienzoWhile


calcularAltura:
    cmp byte ptr [modo], 0 ; Si modo es 0, se accede al modo estatico
    je calcularAlturaEstatico

    cmp byte ptr [modo], 1 ; Si modo es 1, se accede al modo dinamico
    je calcularAlturaDinamico

    jmp errorDesconocido ; Si no se cumple ninguna de las anterior, algo esta mal


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
    push dx; pusheo direccion de retorno (lo pusheo de nuevo porque lo necesito para el final)

    cmp si, AREA_MEMORIA; Compara si el índice en memoria está fuera del área de memoria
    jge sePasoDeMemoriaEstatico; Si es así, salta al final

    mov cx, es:[si]; Carga el valor en la dirección de memoria apuntada por ES:SI en CX
    cmp cx, VACIO; Compara si el valor es VACIO
    je sePasoDeMemoriaEstatico; Si es así, la altura es 0

obtenerAlturaIzqEstatico:

    mov di, si
    shl di, 1; Multiplica por 2
    add di, 2; Suma 2 para tener el indice al hijo izquierdo (que es menor)

    mov ax, di; Carga el indice del hijo izquierdo en AX (cada indice ocupa 2 bytes)

    mov cx, es:[di]; Carga el indice del hijo izquierdo en CX (cada indice ocupa 2 bytes)
    cmp cx, VACIO; Compara si el valor es VACIO
    je alturaIzqCeroEstatico; Si es así, asigna 0 a la altura del hijo izquierdo
    
    
    push si; Pushea la direccion actual del nodo en la pila 
    push bx; Pushea la altura en la pila (Variable de salida)
    push ax; Pushea el indice en memoria en la pila (Variable de entrada)

    call calcularAlturaEstaticoRecursivo

    pop ax; Recupera el indice en memoria del hijo izquierdo (Lo voy a descartar realmente)
    pop bx; Recupera la altura del hijo izquierdo y lo almaceno en BX
    pop si; Recupera la direccion actual del nodo

    jmp obtenerAlturaDerEstatico

alturaIzqCeroEstatico: 
    xor bx, bx; bx = 0 (altura)
    jmp obtenerAlturaDerEstatico
    
obtenerAlturaDerEstatico:
    mov di, si
    shl di, 1; Multiplica por 2
    add di, 4; Suma 4 para tener el indice al hijo derecho (que es mayor)

    mov ax, di; Carga el indice del hijo izquierdo en AX (cada indice ocupa 2 bytes)

    mov cx, es:[di]; Carga el indice del hijo izquierdo en CX (cada indice ocupa 2 bytes)
    cmp cx, VACIO; Compara si el valor es VACIO
    je alturaDerCeroEstatico; asigna 0 a la altura del hijo derecho
    

    push bx; que es la altura del hijo izquierdo
    push si; Pushea la direccion actual del nodo en la pila
    push ax; Pushea para hacer lugar en la pila (Variable de salida)
    push ax; Pushea el indice en memoria en la pila (Variable de entrada)

    call calcularAlturaEstaticoRecursivo

    pop ax; Recupera el indice en memoria del hijo derecho (Lo voy a descartar realmente)
    pop ax; Recupera la altura del hijo derecho y lo almaceno en AX
    pop si; Recupera la direccion actual del nodo
    pop bx; Recupera la altura del hijo izquierdo y lo almaceno en BX

    jmp compararAlturaEstatico

alturaDerCeroEstatico:
    xor ax, ax; ax = 0 (altura)
    jmp compararAlturaEstatico
    
compararAlturaEstatico:
    cmp bx, ax; Compara la altura del hijo izquierdo con la altura del hijo derecho
    jge alturaMaxEnHijoIzquierdoEstatico; Si la altura del hijo izquierdo es mayor o igual, salta a alturaMaxEnHijoIzquierdoEstatico

alturaMaxEnHijoDerechoEstatico:
    mov bx, ax; Almacena la altura del hijo derecho en bx
    inc bx; Incrementa en 1 la altura del hijo derecho
    jmp calcularAlturaEstaticoRecursivoFin; Salta al final

alturaMaxEnHijoIzquierdoEstatico:
    inc bx; Incrementa en 1 la altura del hijo izquierdo
    jmp calcularAlturaEstaticoRecursivoFin; Salta al final

sePasoDeMemoriaEstatico:
    xor bx, bx; bx = 0 (altura)
    jmp calcularAlturaEstaticoRecursivoFin; Salta al final

calcularAlturaEstaticoRecursivoFin:
    pop dx; Recupero direccion de retorno (Para poner ponerlo arriba de todo)


    push bx; Pushea la altura en la pila (Variable de salida)
    push si; Pushea el índice en memoria en la pila (Parametro de entrada)
    push dx; pusheo direccion de retorno (lo pusheo de nuevo porque lo necesito arriba de todo)
    ret; Retorna

 
    
calcularAlturaEstaticoRecursivo ENDP



calcularAlturaDinamico:
    xor ax, ax; ax = 0 (altura)
    xor si, si; si = 0 (indice en memoria)

    push ax; Guarda el valor de ax en la pila (Variable de salida)
    push si; Guarda el valor de si en la pila (Variable de entrada)

    call calcularAlturaDinamicoRecursivo

    pop si; Recupera el valor de si de la pila (Variable de entrada)
    pop ax; Recupera el valor de ax de la pila (Variable de salida)

    out PUERTO_SALIDA, ax; Imprime la altura en el puerto de salida
    mov ax, CODIGO_EXITO; Carga el código de éxito en AX
    out PUERTO_LOG, ax; Imprime el código de éxito en el puerto log

    jmp comienzoWhile


calcularAlturaDinamicoRecursivo PROC

    pop dx; salvo direccion de retorno
    pop si; indice en memoria (Parametro de entrada)
    pop ax; variable de salida (altura)
    push dx; pusheo direccion de retorno (lo pusheo de nuevo porque lo necesito para el final)

    cmp si, AREA_MEMORIA; Compara si el índice en memoria está fuera del área de memoria
    jge sePasoDeMemoriaDinamico; Si es así, salta al final

    mov cx, es:[si]; Carga el valor en la dirección de memoria apuntada por ES:SI en CX
    cmp cx, VACIO; Compara si el valor es VACIO
    je sePasoDeMemoriaDinamico; Si es así, la altura es 0

obtenerAlturaIzq:

    

    mov ax, es:[si + 2]; Carga el indice del hijo izquierdo en AX (cada indice ocupa 6 bytes)
    cmp ax, VACIO; Compara si el valor es VACIO
    je alturaIzqCero; Si es así, asigna 0 a la altura del hijo izquierdo
    add ax, es:[si + 2]; 
    add ax, es:[si + 2]; 
    add ax, es:[si + 2]; 
    add ax, es:[si + 2]; 
    add ax, es:[si + 2]; (6 bytes por nodo) Ahora ax tiene el indice del hijo izquierdo
    

    
    push si; Pushea la direccion actual del nodo en la pila 
    push bx; Pushea la altura en la pila (Variable de salida)
    push ax; Pushea el indice en memoria en la pila (Variable de entrada)

    call calcularAlturaDinamicoRecursivo

    pop ax; Recupera el indice en memoria del hijo izquierdo (Lo voy a descartar realmente)
    pop bx; Recupera la altura del hijo izquierdo y lo almaceno en BX
    pop si; Recupera la direccion actual del nodo

    jmp obtenerAlturaDer

alturaIzqCero: 
    xor bx, bx; bx = 0 (altura)
    jmp obtenerAlturaDer
    
obtenerAlturaDer:
    
    mov ax, es:[si + 4]; Carga el indice del hijo izquierdo en AX (cada indice ocupa 6 bytes)
    cmp ax, VACIO; Compara si el valor es VACIO
    je alturaDerCero; asigna 0 a la altura del hijo derecho
    add ax, es:[si + 4]; 
    add ax, es:[si + 4]; 
    add ax, es:[si + 4]; 
    add ax, es:[si + 4]; 
    add ax, es:[si + 4]; (6 bytes por nodo) Ahora ax tiene el indice del hijo izquierdo

   
    push bx; que es la altura del hijo izquierdo
    push si; Pushea la direccion actual del nodo en la pila
    push ax; Pushea para hacer lugar en la pila (Variable de salida)
    push ax; Pushea el indice en memoria en la pila (Variable de entrada)

    call calcularAlturaDinamicoRecursivo

    pop ax; Recupera el indice en memoria del hijo derecho (Lo voy a descartar realmente)
    pop ax; Recupera la altura del hijo derecho y lo almaceno en AX
    pop si; Recupera la direccion actual del nodo
    pop bx; Recupera la altura del hijo izquierdo y lo almaceno en BX

    jmp comparar

alturaDerCero:
    xor ax, ax; ax = 0 (altura)
    jmp comparar
    
comparar:
    cmp bx, ax; Compara la altura del hijo izquierdo con la altura del hijo derecho
    jge alturaMaxEnHijoIzquierdoDinamico; Si la altura del hijo izquierdo es mayor o igual, salta a alturaMaxEnHijoIzquierdoDinamico

alturaMaxEnHijoDerechoDinamico:
    mov bx, ax; Almacena la altura del hijo derecho en bx
    inc bx; Incrementa en 1 la altura del hijo derecho
    jmp calcularAlturaDinamicoRecursivoFin; Salta al final

alturaMaxEnHijoIzquierdoDinamico:
    inc bx; Incrementa en 1 la altura del hijo izquierdo
    jmp calcularAlturaDinamicoRecursivoFin; Salta al final

sePasoDeMemoriaDinamico:
    xor bx, bx; bx = 0 (altura)
    jmp calcularAlturaDinamicoRecursivoFin; Salta al final

calcularAlturaDinamicoRecursivoFin:
    pop dx; Recupero direccion de retorno (Para poner ponerlo arriba de todo)


    push bx; Pushea la altura en la pila (Variable de salida)
    push si; Pushea el índice en memoria en la pila (Parametro de entrada)
    push dx; pusheo direccion de retorno (lo pusheo de nuevo porque lo necesito arriba de todo)
    ret; Retorna

 
    
calcularAlturaDinamicoRecursivo ENDP



calcularSuma:
    cmp byte ptr [modo], 0 ; Si modo es 0, se accede al modo estatico
    je calcularSumaEstatico

    cmp byte ptr [modo], 1 ; Si modo es 1, se accede al modo dinamico
    je calcularSumaDinamico

    jmp errorDesconocido ; Si no se cumple ninguna de las anterior, algo esta mal



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


imprimirMemoria:
    mov AL, byte ptr [modo]; Carga el modo en AX

    cmp AL, 0 ; Si modo es 0, se accede al modo estatico
    je imprimirMemoriaEstatico

    cmp AL, 1 ; Si modo es 1, se accede al modo dinamico
    je imprimirMemoriaDinamico

    jmp errorDesconocido ; Si no se cumple ninguna de las anterior, algo esta mal




imprimirMemoriaEstatico:
    in ax, PUERTO_ENTRADA ; lee el n cantidad de espacios de memoria a imprimir
    out PUERTO_LOG, AX; imprime el valor en el puerto log

    ;Si el valor es menor a 0, imprime error
    cmp ax, 0
    jl parametroIncorrecto


    mov bx , ax ; Guarda el valor de ax en bx
    add bx, ax ; Multiplica por 2 para tener la cantidad de bytes a imprimir

    xor di, di; di = 0 
    mov cx, ax; cx = ax (cantidad de espacios de memoria a imprimir)

    imprimirMemoriaEstaticoLoop:
        cmp di, AREA_MEMORIA  ; Compara si hemos llegado al final del área de memoria
        jae imprimirMemoriaEstaticoFin ; Si es así, salta al final

        cmp di, bx; Compara si se llego a la cantidad de espacios de memoria a imprimir
        jae imprimirMemoriaEstaticoFin ; Si es así, salta al final

        mov AX, word ptr ES:[di]  ; Carga el valor en la dirección de memoria apuntada por ES:DI en AX

        out PUERTO_SALIDA, AX; Imprime el valor del nodo actual en el puerto de salida

        add di, 2 ; Avanza al siguiente espacio de memoria (2 bytes por palabra)
        jmp imprimirMemoriaEstaticoLoop ; Vuelve al bucle principal
    
    imprimirMemoriaEstaticoFin:
        mov ax, CODIGO_EXITO; Carga el código de éxito en AX
        out PUERTO_LOG, ax; Imprime el código de éxito en el puerto log
        jmp comienzoWhile

imprimirMemoriaDinamico:
    in ax, PUERTO_ENTRADA ; lee el n cantidad de espacios de memoria a imprimir
    out PUERTO_LOG, AX; imprime el valor en el puerto log

    ;Si el valor es menor a 0, imprime error
    cmp ax, 0
    jl parametroIncorrecto

    mov bx , ax ; Guarda el valor de ax en bx
    add bx, ax ; 
    add bx, ax ;
    add bx, ax ; Multiplica por 6 para tener la cantidad de bytes a imprimir
    add bx, ax ;
    add bx, ax ;

    xor di, di; di = 0
    mov cx, ax; cx = ax (cantidad de espacios de memoria a imprimir)

    imprimirMemoriaDinamicoLoop:
        cmp di, AREA_MEMORIA  ; Compara si hemos llegado al final del área de memoria
        jae imprimirMemoriaDinamicoFin ; Si es así, salta al final

        cmp di, bx; Compara si se llego a la cantidad de espacios de memoria a imprimir
        jae imprimirMemoriaDinamicoFin ; Si es así, salta al final

        mov AX, word ptr ES:[di]  ; Carga el valor en la dirección de memoria apuntada por ES:DI en AX
        out PUERTO_SALIDA, AX; Imprime el valor del nodo actual en el puerto de salida

        mov AX, word ptr ES:[di + 2]  ; Carga el valor en la dirección de memoria apuntada por ES:DI en AX
        out PUERTO_SALIDA, AX; Imprime el valor del nodo actual en el puerto de salida

        mov AX, word ptr ES:[di + 4]  ; Carga el valor en la dirección de memoria apuntada por ES:DI en AX
        out PUERTO_SALIDA, AX; Imprime el valor del nodo actual en el puerto de salida

        add di, 6 ; Avanza al siguiente espacio de memoria (6 bytes por palabra)
        jmp imprimirMemoriaDinamicoLoop ; Vuelve al bucle principal
    imprimirMemoriaDinamicoFin:
        mov ax, CODIGO_EXITO; Carga el código de éxito en AX
        out PUERTO_LOG, ax; Imprime el código de éxito en el puerto log
        jmp comienzoWhile





imprimirArbol:
    in ax, PUERTO_ENTRADA ; lee el valor del nodo de la entrada
    out PUERTO_LOG, AX; imprime el valor en el puerto log

    cmp ax, ORDEN_ASCENDENTE
    je imprimirArbolAscendente

    cmp ax, ORDEN_DESCENDENTE
    je imprimirArbolDescendente

    jmp parametroIncorrecto


imprimirArbolAscendente:    

    cmp byte ptr [modo], 0 ; Si modo es 0, se accede al modo estatico
    je imprimirArbolAscendenteEstatico

    cmp byte ptr [modo], 1 ; Si modo es 1, se accede al modo dinamico
    je imprimirArbolAscendenteDinamico

imprimirArbolDescendente:

    cmp byte ptr [modo], 0 ; Si modo es 0, se accede al modo estatico
    je imprimirArbolDescendenteEstatico

    cmp byte ptr [modo], 1 ; Si modo es 1, se accede al modo dinamico
    je imprimirArbolDescendenteDinamico


imprimirArbolAscendenteEstatico:
    xor di, di; di = 0 
    push di;
    call imprimirArbolAscendenteEstaticoR
    pop di;
    mov ax, CODIGO_EXITO; Carga el código de éxito en AX
    out PUERTO_LOG, ax; Imprime el código de éxito en el puerto log
    jmp comienzoWhile
    
    
imprimirArbolAscendenteEstaticoR PROC

   pop dx; salvo direccion de retorno
    pop si; indice en memoria (Parametro de entrada)
    push dx; pusheo direccion de retorno (lo pusheo de nuevo porque lo necesito para el final)

    cmp si, AREA_MEMORIA; Compara si el índice en memoria está fuera del área de memoria
    jge imprimirArbolDescendenteEstaticoFin; Si es así, salta al final

    mov cx, es:[si]; Carga el valor en la dirección de memoria apuntada por ES:SI en CX
    cmp cx, VACIO; Compara si el valor es VACIO
    je imprimirArbolDescendenteEstaticoFin; Si es así, no se imprime el nodo

    imprimirHijoIzquierdoAscendenteEstatico:

        mov di, si
        shl di, 1; Multiplica por 2
        add di, 2; Suma 2 para tener el indice al hijo izquierdo (que es menor)

        mov cx, es:[di]; Carga el indice del hijo izquierdo en CX (cada indice ocupa 2 bytes)
        cmp cx, VACIO; Compara si el valor es VACIO
        je imprimirNodoAscendenteEstatico

        push di; Pushea la direccion del hijo derecho en la pila
    
        call imprimirArbolAscendenteEstaticoR

        pop di; Recupera la direccion actual del nodo


    imprimirNodoAscendenteEstatico:
        mov ax , word ptr es:[si]; Carga el valor en la dirección de memoria apuntada por ES:SI en AX
        out PUERTO_SALIDA, ax; Imprime el valor de AX en el puerto de salida    
        
        jmp imprimirHijoDerechoAscendenteEstatico; Salta al final    

    imprimirHijoDerechoAscendenteEstatico:
        mov di, si
        shl di, 1; Multiplica por 2
        add di, 4; Suma 4 para tener el indice al hijo derecho (que es mayor)

        mov cx, es:[di]; Carga el indice del hijo izquierdo en CX (cada indice ocupa 2 bytes)
        cmp cx, VACIO; Compara si el valor es VACIO
        je imprimirArbolAscendenteEstaticoFin
        

        push di; Pushea la direccion del hijo derecho en la pila
    
        call imprimirArbolAscendenteEstaticoR

        pop di; Recupera la direccion actual del nodo


    imprimirArbolAscendenteEstaticoFin:
        pop dx; Recupero direccion de retorno (Para poner ponerlo arriba de todo)
        push si; Pushea el índice en memoria en la pila (Parametro de entrada)
        push dx; pusheo direccion de retorno (lo pusheo de nuevo porque lo necesito arriba de todo)
        ret; Retorna
imprimirArbolAscendenteEstaticoR ENDP



imprimirArbolDescendenteEstatico:
    xor di, di; di = 0 
    push di;
    call imprimirArbolDescendenteEstaticoR
    pop di;
    mov ax, CODIGO_EXITO; Carga el código de éxito en AX
    out PUERTO_LOG, ax; Imprime el código de éxito en el puerto log
    jmp comienzoWhile

imprimirArbolDescendenteEstaticoR PROC

    pop dx; salvo direccion de retorno
    pop si; indice en memoria (Parametro de entrada)
    push dx; pusheo direccion de retorno (lo pusheo de nuevo porque lo necesito para el final)

    cmp si, AREA_MEMORIA; Compara si el índice en memoria está fuera del área de memoria
    jge imprimirArbolDescendenteEstaticoFin; Si es así, salta al final

    mov cx, es:[si]; Carga el valor en la dirección de memoria apuntada por ES:SI en CX
    cmp cx, VACIO; Compara si el valor es VACIO
    je imprimirArbolDescendenteEstaticoFin; Si es así, no se imprime el nodo

    imprimirHijoDerechoDescendenteEstatico:
        mov di, si
        shl di, 1; Multiplica por 2
        add di, 4; Suma 4 para tener el indice al hijo derecho (que es mayor)

        mov cx, es:[di]; Carga el indice del hijo izquierdo en CX (cada indice ocupa 2 bytes)
        cmp cx, VACIO; Compara si el valor es VACIO
        je imprimirNodoDescendenteEstatico
        

        push di; Pushea la direccion del hijo derecho en la pila
    
        call imprimirArbolDescendenteEstaticoR

        pop di; Recupera la direccion actual del nodo


    imprimirNodoDescendenteEstatico:
        mov ax , word ptr es:[si]; Carga el valor en la dirección de memoria apuntada por ES:SI en AX
        out PUERTO_SALIDA, ax; Imprime el valor de AX en el puerto de salida    


    imprimirHijoIzquierdoDescendenteEstatico:

        mov di, si
        shl di, 1; Multiplica por 2
        add di, 2; Suma 2 para tener el indice al hijo izquierdo (que es menor)

        mov cx, es:[di]; Carga el indice del hijo izquierdo en CX (cada indice ocupa 2 bytes)
        cmp cx, VACIO; Compara si el valor es VACIO
        je imprimirArbolDescendenteEstaticoFin

        push di; Pushea la direccion del hijo derecho en la pila
    
        call imprimirArbolDescendenteEstaticoR

        pop di; Recupera la direccion actual del nodo

    imprimirArbolDescendenteEstaticoFin:
        pop dx; Recupero direccion de retorno (Para poner ponerlo arriba de todo)
        push si; Pushea el índice en memoria en la pila (Parametro de entrada)
        push dx; pusheo direccion de retorno (lo pusheo de nuevo porque lo necesito arriba de todo)
        ret; Retorna
imprimirArbolDescendenteEstaticoR ENDP





imprimirArbolAscendenteDinamico:
    xor di, di; di = 0 
    push di;
    call imprimirArbolAscendenteDinamicoR
    pop di;
    mov ax, CODIGO_EXITO; Carga el código de éxito en AX
    out PUERTO_LOG, ax; Imprime el código de éxito en el puerto log
    jmp comienzoWhile

imprimirArbolAscendenteDinamicoR PROC

    pop dx; salvo direccion de retorno
    pop si; indice en memoria (Parametro de entrada)
    push dx; pusheo direccion de retorno (lo pusheo de nuevo porque lo necesito para el final)

    cmp si, AREA_MEMORIA; Compara si el índice en memoria está fuera del área de memoria
    jge imprimirArbolAscendenteDinamicoFin; Si es así, salta al final

    mov cx, es:[si]; Carga el valor en la dirección de memoria apuntada por ES:SI en CX
    cmp cx, VACIO; Compara si el valor es VACIO
    je imprimirArbolAscendenteDinamicoFin; Si es así, la altura es 0

    

    


    imprimirHijoIzquierdoAscendenteDinamico:

        mov ax, es:[si + 2]; Carga el indice del hijo izquierdo en AX (cada indice ocupa 6 bytes)
        cmp ax, VACIO; Compara si el valor es VACIO
        je imprimirNodoAscendenteDinamico; Si es así, asigna 0 a la altura del hijo izquierdo
        add ax, es:[si + 2]; 
        add ax, es:[si + 2]; 
        add ax, es:[si + 2]; 
        add ax, es:[si + 2]; 
        add ax, es:[si + 2]; (6 bytes por nodo) Ahora ax tiene el indice del hijo izquierdo

        mov di, ax; 

        mov cx, es:[di]; Carga el valor en la dirección de memoria apuntada por ES:SI en CX
        cmp cx, VACIO; Compara si el valor es VACIO
        je imprimirNodoAscendenteDinamico; Si es así, no imprime nada
        
        push si; Pushea la direccion actual del nodo en la pila 
        push ax; Pushea el indice en memoria en la pila (Variable de entrada)

        call imprimirArbolAscendenteDinamicoR

        pop ax; Recupera el indice en memoria del hijo izquierdo (Lo voy a descartar realmente)
        pop si; Recupera la direccion actual del nodo

    imprimirNodoAscendenteDinamico:
        mov ax , word ptr es:[si]; Carga el valor en la dirección de memoria apuntada por ES:SI en AX
        out PUERTO_SALIDA, ax; Imprime el valor de AX en el puerto de salida    


    imprimirHijoDerechoAscendenteDinamico:

       mov ax, es:[si +4]; Carga el indice del hijo derecho en AX (cada indice ocupa 6 bytes)
        cmp ax, VACIO; Compara si el valor es VACIO
        je imprimirArbolAscendenteDinamicoFin; Si es así, asigna 0 a la altura del hijo izquierdo
        add ax, es:[si +4]; 
        add ax, es:[si +4]; 
        add ax, es:[si +4]; 
        add ax, es:[si +4]; 
        add ax, es:[si +4]; (6 bytes por nodo) Ahora ax tiene el indice del hijo izquierdo

        mov di, ax; 

        mov cx, es:[di]; Carga el valor en la dirección de memoria apuntada por ES:SI en CX
        cmp cx, VACIO; Compara si el valor es VACIO
        je imprimirArbolAscendenteDinamicoFin; Si es así, no imprime nada

        push si; Pushea la direccion actual del nodo en la pila
        push ax; Pushea el indice en memoria en la pila (Variable de entrada)
    
        call imprimirArbolAscendenteDinamicoR

        pop ax; Recupera el indice en memoria del hijo derecho (Lo voy a descartar realmente)
        pop si; Recupera la direccion actual del nodo


    imprimirArbolAscendenteDinamicoFin:
        pop dx; Recupero direccion de retorno (Para poner ponerlo arriba de todo)
        push si; Pushea el índice en memoria en la pila (Parametro de entrada)
        push dx; pusheo direccion de retorno (lo pusheo de nuevo porque lo necesito arriba de todo)
        ret; Retorna
imprimirArbolAscendenteDinamicoR ENDP




imprimirArbolDescendenteDinamico:
    xor di, di; di = 0 
    push di;
    call imprimirArbolDescendenteDinamicoR
    pop di;
    mov ax, CODIGO_EXITO; Carga el código de éxito en AX
    out PUERTO_LOG, ax; Imprime el código de éxito en el puerto log
    jmp comienzoWhile

imprimirArbolDescendenteDinamicoR PROC

    pop dx; salvo direccion de retorno
    pop si; indice en memoria (Parametro de entrada)
    push dx; pusheo direccion de retorno (lo pusheo de nuevo porque lo necesito para el final)

    cmp si, AREA_MEMORIA; Compara si el índice en memoria está fuera del área de memoria
    jge imprimirArbolDescendenteDinamicoFin; Si es así, salta al final

    mov cx, es:[si]; Carga el valor en la dirección de memoria apuntada por ES:SI en CX
    cmp cx, VACIO; Compara si el valor es VACIO
    je imprimirArbolDescendenteDinamicoFin; Si es así, la altura es 0

    imprimirHijoDerechoDescendenteDinamico:

       mov ax, es:[si +4]; Carga el indice del hijo derecho en AX (cada indice ocupa 6 bytes)
        cmp ax, VACIO; Compara si el valor es VACIO
        je imprimirNodoDescendenteDinamico; Si es así, asigna 0 a la altura del hijo izquierdo
        add ax, es:[si +4]; 
        add ax, es:[si +4]; 
        add ax, es:[si +4]; 
        add ax, es:[si +4]; 
        add ax, es:[si +4]; (6 bytes por nodo) Ahora ax tiene el indice del hijo izquierdo

        mov di, ax; 

        mov cx, es:[di]; Carga el valor en la dirección de memoria apuntada por ES:SI en CX
        cmp cx, VACIO; Compara si el valor es VACIO
        je imprimirNodoDescendenteDinamico; Si es así, no imprime nada

        push si; Pushea la direccion actual del nodo en la pila
        push ax; Pushea el indice en memoria en la pila (Variable de entrada)
    
        call imprimirArbolDescendenteDinamicoR

        pop ax; Recupera el indice en memoria del hijo derecho (Lo voy a descartar realmente)
        pop si; Recupera la direccion actual del nodo


    imprimirNodoDescendenteDinamico:
        mov ax , word ptr es:[si]; Carga el valor en la dirección de memoria apuntada por ES:SI en AX
        out PUERTO_SALIDA, ax; Imprime el valor de AX en el puerto de salida    


    imprimirHijoIzquierdoDescendenteDinamico:

        mov ax, es:[si + 2]; Carga el indice del hijo izquierdo en AX (cada indice ocupa 6 bytes)
        cmp ax, VACIO; Compara si el valor es VACIO
        je imprimirArbolDescendenteDinamicoFin; Si es así, asigna 0 a la altura del hijo izquierdo
        add ax, es:[si + 2]; 
        add ax, es:[si + 2]; 
        add ax, es:[si + 2]; 
        add ax, es:[si + 2]; 
        add ax, es:[si + 2]; (6 bytes por nodo) Ahora ax tiene el indice del hijo izquierdo

        mov di, ax; 

        mov cx, es:[di]; Carga el valor en la dirección de memoria apuntada por ES:SI en CX
        cmp cx, VACIO; Compara si el valor es VACIO
        je imprimirArbolDescendenteDinamicoFin; Si es así, no imprime nada
        
        push si; Pushea la direccion actual del nodo en la pila 
        push ax; Pushea el indice en memoria en la pila (Variable de entrada)

        call imprimirArbolDescendenteDinamicoR

        pop ax; Recupera el indice en memoria del hijo izquierdo (Lo voy a descartar realmente)
        pop si; Recupera la direccion actual del nodo

    imprimirArbolDescendenteDinamicoFin:
        pop dx; Recupero direccion de retorno (Para poner ponerlo arriba de todo)
        push si; Pushea el índice en memoria en la pila (Parametro de entrada)
        push dx; pusheo direccion de retorno (lo pusheo de nuevo porque lo necesito arriba de todo)
        ret; Retorna
imprimirArbolDescendenteDinamicoR ENDP







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




errorDesconocido:
    mov AX, 1234
    out 30, ax 
    jmp comienzoWhile





detenerPrograma:
    mov ax, CODIGO_EXITO ;                 ax = CODIGO_EXITO
    out PUERTO_LOG, ax ;        escribir_puerto(PUERTO_LOG, CODIGO_EXITO);
    ;FIN DEL PROGRAMA



; ---------- SEGMENTO DE PUERTOS ----------
.ports
20: 1,0,5,1,1,1,5,1,1,0,2,4,5,1,1,1,2,5,5,1,1,0,2,100,2,128,2,60,2,40,2,20,2,22,5,1,5,0,1,1,2,50,2,40,2,30,2,45,2,46,2,47,2,48,5,0,5,1,255




; ---------- SEGMENTO DE INTERRUPCIONES ----------

.interrupts 
