/**
 * Descripción de la tarea
 * En este laboratorio se desarrollará un programa Manejador y Ordenador de Árboles de Búsqueda
 * (MOAB). El programa permitirá administrar un Árbol Binario de Búsqueda (ABB) y realizar
 * operaciones sobre él. Dentro de las funcionalidades ofrecidas se encuentra agregar nuevos
 * números al árbol, imprimir información sobre él y permitir varios formatos de almacenamiento
 * interno. Además, el sistema manejará una bitácora de ejecución, donde se indicará información
 * sobre parámetros leídos y acciones realizadas. 
 * **/

/***
 * Formato de entrada
 * La entrada al sistema se realizará leyendo el puerto de entrada/salida de 16 bits de solo lectura
 * PUERTO_ENTRADA con el formato Comando [Parámetro]. Cada comando tiene predefinidos si
 * requiere cero o un parámetro. Tanto los comandos como los parámetros son de 16 bits.
 * La siguiente tabla muestra la codificación requerida para cada comando: 
*/

/*-----------------------------------------------------------------------------------------
|     Comando     |   Parámetro   | Código |               Descripción                  |
-----------------------------------------------------------------------------------------
| Cambiar Modo     |     Modo      |    1   | Cambia el modo de almacenamiento del árbol |
|                  |               |        | e inicializa el área de memoria.            |
-----------------------------------------------------------------------------------------
| Agregar Nodo     |    Número     |    2   | Agrega el número al árbol. El número es un  |
|                  |               |        | número de 16 bits en complemento a 2.       |
-----------------------------------------------------------------------------------------
| Calcular Altura  |               |    3   | Imprime la altura del árbol.               |
-----------------------------------------------------------------------------------------
| Calcular Suma    |               |    4   | Imprime la suma de todos los números del   |
|                  |               |        | árbol.                                      |
-----------------------------------------------------------------------------------------
| Imprimir Árbol   |    Orden      |    5   | Imprime todos los números del árbol: el   |
|                  |               |        | parámetro orden indica si se imprimen de   |
|                  |               |        | menor a mayor (0) o de mayor a menor (1).  |
-----------------------------------------------------------------------------------------
| Imprimir Memoria |      N        |    6   | Imprime los primeros N nodos del área de  |
|                  |               |        | memoria del árbol.                        |
-----------------------------------------------------------------------------------------
| Detener programa |               |  255   | Detiene la ejecución.                      |
-----------------------------------------------------------------------------------------*/

#define CAMBIAR_MODO 1
#define AGREGAR_NODO 2
#define CALCULAR_ALTURA 3
#define CALCULAR_SUMA 4
#define IMPRIMIR_ARBOL 5
#define IMPRIMIR_MEMORIA 6
#define DETENER_PROGRAMA 255

/*
 * Almacenamiento del árbol:
 * Para el almacenamiento del árbol se reserva una zona de memoria de tamaño
 * AREA_DE_MEMORIA palabras de 16 bits ubicada a partir de la posición 0 del segmento ES
 * según el formato indicado por el modo. Al cambiar el modo del árbol, se deberá
 * inicializar el área de memoria con el valor 0x8000 en cada una de las palabras del
 * área de memoria. Como consecuencia de esto, un cambio de modo elimina todos los
 * valores previos almacenados en el árbol.
 */
/**
 * Comando: Cambiar Modo
 * Descripción: Indica el modo de almacenamiento del árbol. Si el parámetro es 0, el almacenamiento será
 * estático, mientras que si el parámetro es 1, será dinámico. Despliega error en caso de recibir un
 * parámetro inválido. Además, inicializa el área de memoria.
 */

#define MODO_ESTATICO 0
#define MODO_DINAMICO 1

void cambiar_modo(short modo);

/**
 * Comando: Agregar Nodo
 * Descripción: Agrega el parámetro Num al árbol. Imprime error en el PUERTO_LOG en caso de intentar
 * escribir fuera del AREA_DE_MEMORIA. Imprime error en el PUERTO_LOG en caso de que el
 * nodo ya esté contenido en el árbol.
 */

void agregar_nodo(short num);

/**
 * Comando: Calcular Altura
 * Descripción: Imprime la altura del árbol en el puerto de entrada/salida PUERTO_SALIDA.
 */

void calcular_altura();

/**
 * Comando: Calcular Suma
 * Descripción: Imprime la suma de todos los valores del árbol en el puerto de entrada/salida PUERTO_SALIDA.
 */

void calcular_suma();

/**
 * Comando: Imprimir Árbol
 * Descripción: Imprime todos los números del árbol en el PUERTO_SALIDA: el parámetro orden indica si se
 * imprimen de menor a mayor (0) o de mayor a menor (1).
 */

#define ORDEN_MENOR_A_MAYOR 0
#define ORDEN_MAYOR_A_MENOR 1
void imprimir_arbol(short orden);

/**
 * Comando: Imprimir Memoria
 * Descripción: Imprime el contenido de memoria de los primeros N nodos (N es parámetro) en el
 * PUERTO_SALIDA. Tener en cuenta que la cantidad de bytes impresos difiere según el modo de
 * almacenamiento utilizado. En el modo estático se imprimirán 2 * N bytes (ya que cada nodo
 * simplemente guarda los 16 bits del número), mientras que en el modo dinámico se imprimirán
 * 6 * N bytes.
 */
void imprimir_memoria_estatico(short n);
void imprimir_memoria_dinamico(short n);


/**
 * Comando: Detener programa
 * Descripción: Detiene la ejecución del programa.
 */
void detener_programa();

/**
 * Observaciones:
 * - En caso de recibir un comando "modo" que vuelva a setear el mismo modo previamente
 * almacenado, el comando se deberá procesar normalmente, eliminando los contenidos
 * previos del árbol.
 * - Se pueden utilizar variables adicionales para el mantenimiento y almacenamiento del
 * árbol, pero los nodos se deben almacenar según lo indicado en la letra.
 * - Los números agregados al árbol se encuentran representados en complemento a 2. El
 * número 0x8000 no es válido ya que este código se utiliza para representar la ausencia
 * de nodo.
 */

/**
 * Bitácora de ejecución:
 * El programa MOAB debe mantener una bitácora de ejecución a medida que va procesando
 * cada comando. Se utilizará el puerto de salida PUERTO_LOG. La bitácora deberá funcionar de la
 * siguiente forma:
 * - Antes de procesar un comando se debe mandar el código 64 seguido del comando a
 * procesar (incluyendo los parámetros, una palabra por cada dato).
 * - Luego de procesar el comando se deberá mandar:
 *   - El código 0 si la operación se pudo realizar con éxito.
 *   - El código 1 si no se reconoce el comando (comando inválido).
 *   - El código 2 si el valor de algún parámetro recibido es inválido.
 *   - El código 4 si al agregar un nodo se intenta escribir fuera del área de memoria.
 *   - El código 8 si el nodo a agregar ya se encuentra en el árbol.
 */
#define CODIGO_BITACORA 64

#define CODIGO_EXITO 0
#define CODIGO_COMANDO_INVALIDO 1
#define CODIGO_PARAMETRO_INVALIDO 2
#define CODIGO_ESCRIBIR_FUERA_DE_AREA 4
#define CODIGO_NODO_YA_EXISTE 8

/**
 * Puertos de entrada y salida y constantes:
 * - PUERTO_ENTRADA: 20
 * - PUERTO_SALIDA: 21
 * - PUERTO_LOG: 22
 * - AREA_MEMORIA: 2048 (palabras de 16 bits)
 */


#define PUERTO_ENTRADA 20
#define PUERTO_SALIDA 21
#define PUERTO_LOG 22
#define AREA_MEMORIA 2048



// funciones auxiliares

void escribir_puerto_salida(short dato);
short leer_puerto_entrada();
void escribir_puerto_log(short codigo);

// MODO ESTATICO

// define el arbol estatico
short arbol[AREA_MEMORIA]; 
// cada nodo ocupa 2 bytes / 16 bits
// el arbol tiene capacidad para 2048 nodos
// la raiz esta en la posicion 0
// la altura maxima del arbol es 11
// el arbol esta ordenado de menor a mayor
// el arbol esta representado en complemento a 2
// el arbol tiene 0x8000 en los nodos vacios


// inicializa el area de memoria con 0x8000
void inicializar_area_memoria_estatico(){
    for(int i = 0; i < AREA_MEMORIA; i++){
        arbol[i] = 0x8000;
    }
}

// agrega un nodo al arbol estatico
void agregar_nodo_estatico(short num){
    int i = 0;
    while(arbol[i] != 0x8000){
        if(arbol[i] == num){
            escribir_puerto_log(CODIGO_NODO_YA_EXISTE);
            return;
        }
        if(arbol[i] > num){
            i = 2 * i + 1;
        }else{
            i = 2 * i + 2;
        }
    }
    if(i >= AREA_MEMORIA){
        escribir_puerto_log(CODIGO_ESCRIBIR_FUERA_DE_AREA);
        return;
    }
    arbol[i] = num;
}

// calcula la altura del arbol estatico
void calcular_altura_estatico(){
    int altura = 0;
    int i = 0;
    while(arbol[i] != 0x8000){
        altura = altura + 1;
        if(arbol[i] > 0){
            i = 2 * i + 2;
        }else{
            i = 2 * i + 1;
        }
    }
    escribir_puerto_salida(altura);
}

// calcula la suma de los nodos del arbol estatico
void calcular_suma_estatico(){
    int suma = 0;
    for(int i = 0; i < AREA_MEMORIA; i++){
        if (arbol[i] != 0x8000){
            suma = suma + arbol[i];
        }
    }
    escribir_puerto_salida(suma);
}

// imprime el arbol estatico
void imprimir_arbol_estatico(short orden){
    if(orden == ORDEN_MENOR_A_MAYOR){
        for(int i = 0; i < AREA_MEMORIA; i++){
            if(arbol[i] != 0x8000){
                escribir_puerto_salida(arbol[i]);
            }
        }
    }else{
        for(int i = AREA_MEMORIA - 1; i >= 0; i--){
            if(arbol[i] != 0x8000){
                escribir_puerto_salida(arbol[i]);
            }
        }
    }
}

// imprime los primeros N nodos del arbol estatico
void imprimir_memoria_estatico(short n){
    for(int i = 0; i < n; i++){
        if(arbol[i] != 0x8000){
            escribir_puerto_salida(arbol[i]);
        }
    }
}

// detiene la ejecucion del programa
void detener_programa_estatico(){
    return;
}

// MAIN con solo el modo estatico

void main(){
    short comando;
    short parametro;
    short modo = MODO_ESTATICO;
    inicializar_area_memoria_estatico();
    while(1){
        comando = leer_puerto_entrada();
        if(comando == CAMBIAR_MODO){
            parametro = leer_puerto_entrada();
            cambiar_modo(parametro);
        }else if(comando == AGREGAR_NODO){
            parametro = leer_puerto_entrada();
            agregar_nodo(parametro);
        }else if(comando == CALCULAR_ALTURA){
            calcular_altura();
        }else if(comando == CALCULAR_SUMA){
            calcular_suma();
        }else if(comando == IMPRIMIR_ARBOL){
            parametro = leer_puerto_entrada();
            imprimir_arbol(parametro);
        }else if(comando == IMPRIMIR_MEMORIA){
            parametro = leer_puerto_entrada();
            imprimir_memoria(parametro);
        }else if(comando == DETENER_PROGRAMA){
            detener_programa();
        }
    }
}