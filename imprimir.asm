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
    
        call imprimirArbolDescendenteEstatico

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
    
        call imprimirArbolDescendenteEstatico

        pop di; Recupera la direccion actual del nodo


    imprimirArbolAscendenteEstaticoFin:
        pop dx; Recupero direccion de retorno (Para poner ponerlo arriba de todo)
        push si; Pushea el índice en memoria en la pila (Parametro de entrada)
        push dx; pusheo direccion de retorno (lo pusheo de nuevo porque lo necesito arriba de todo)
        ret; Retorna
imprimirArbolAscendenteEstaticoR ENDP