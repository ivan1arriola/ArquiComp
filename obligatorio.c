#include <stdio.h>
// string
typedef char *string;

/**
 * Descripción de la tarea
 * En este laboratorio se desarrollará un programa Manejador y Ordenador de Árboles de Búsqueda
 * (MOAB). El programa permitirá administrar un Árbol Binario de Búsqueda (ABB) y realizar
 * operaciones sobre él. Dentro de las funcionalidades ofrecidas se encuentra agregar nuevos
 * números al árbol, imprimir información sobre él y permitir varios formatos de almacenamiento
 * interno. Además, el sistema manejará una bitácora de ejecución, donde se indicará información
 * sobre parámetros leídos y acciones realizadas.
 * **/

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

// Variables globales
short MODO = 0;
short CONTINUAR_PROGRAMA = 1;

// Declaraciones de funciones
void cambiar_modo(short modo);
void agregar_nodo(short num);
void calcular_altura();
void calcular_suma();
void imprimir_arbol(short orden);
void imprimir_memoria(short n);
void detener_programa();

// Version estatica
void agregar_nodo_estatico(short num);
short calcular_altura_estatico(short indice);
void calcular_suma_estatico();
void imprimir_arbol_estatico_ascendente(short indice);
void imprimir_arbol_estatico_descendente(short indice);
void imprimir_memoria_estatico(short n);
void detener_programa_estatico();

// version dinamica
void agregar_nodo_dinamico(short num);
short calcular_altura_dinamico(short indice);
void calcular_suma_dinamico();
void imprimir_arbol_dinamico_ascendente(short indice);
void imprimir_arbol_dinamico_descendente(short indice);
void imprimir_memoria_dinamico(short n);
void detener_programa_dinamico();

/**
 * Bitácora de ejecución:
 * El programa MOAB debe mantener una bitácora de ejecución a medida que va procesando
 * cada comando. Se utilizará el puerto de salida PUERTO_LOG. La bitácora deberá funcionar de la
 * siguiente forma:
 *
 *
 * - Antes de procesar un comando se debe mandar el código 64 seguido del comando a
 * procesar (incluyendo los parámetros, una palabra por cada dato).
 *
 *
 * - Luego de procesar el comando se deberá mandar el codigo correspondiente
 *
 *
 */
#define CODIGO_BITACORA 64 // Código de la bitácora
// Definiciones de códigos de la bitácora
#define CODIGO_EXITO 0                  // Código 0 si la operación se pudo realizar con éxito.
#define CODIGO_COMANDO_INVALIDO 1       // Código 1 si no se reconoce el comando (comando inválido).
#define CODIGO_PARAMETRO_INVALIDO 2     // Código 2 si el valor de algún parámetro recibido es inválido.
#define CODIGO_ESCRIBIR_FUERA_DE_AREA 4 // Código 4 si al agregar un nodo se intenta escribir fuera del área de memoria.
#define CODIGO_NODO_YA_EXISTE 8         // Código 8 si el nodo a agregar ya se encuentra en el árbol.

// Entrada - Salida de datos

void escribir_puerto(short puerto, short dato)
{
    const char *nombre_puerto;

    if (puerto == PUERTO_ENTRADA)
    {
        nombre_puerto = "PUERTO_ENTRADA";
    }
    else if (puerto == PUERTO_SALIDA)
    {
        nombre_puerto = "PUERTO_SALIDA";
    }
    else if (puerto == PUERTO_LOG)
    {
        nombre_puerto = "PUERTO_LOG";
    }
    else
    {
        nombre_puerto = "Desconocido";
    }

    printf("[%s] - %hd\n", nombre_puerto, dato);
}

short leer_puerto_entrada(string mensaje)
{
    printf("%s  -  ", mensaje);
    printf("[Puerto Entrada] - ");
    short dato;
    scanf("%hd", &dato);
    return dato;
}

/*
 * Almacenamiento del árbol:
 * Para el almacenamiento del árbol se reserva una zona de memoria de tamaño
 * AREA_DE_MEMORIA palabras de 16 bits ubicada a partir de la posición 0 del segmento ES
 * según el formato indicado por el modo. Al cambiar el modo del árbol, se deberá
 * inicializar el área de memoria con el valor 0x8000 en cada una de las palabras del
 * área de memoria. Como consecuencia de esto, un cambio de modo elimina todos los
 * valores previos almacenados en el árbol.
 */

short arbol[AREA_MEMORIA];
#define VACIO 100

void inicializar_memoria()
{
    for (int indice = 0; indice < AREA_MEMORIA; indice++)
    {
        arbol[indice] = VACIO;
    }
}

/**
 * Comando: Cambiar Modo
 * Descripción: Indica el modo de almacenamiento del árbol. Si el parámetro es 0, el almacenamiento será
 * estático, mientras que si el parámetro es 1, será dinámico. Despliega error en caso de recibir un
 * parámetro inválido. Además, inicializa el área de memoria.
 */

#define MODO_ESTATICO 0
#define MODO_DINAMICO 1

void cambiar_modo(short nuevoModo)
{
    short comando = (CAMBIAR_MODO << 8) | (0 & 0xFF);
    escribir_puerto(PUERTO_LOG, comando);

    if (nuevoModo == MODO_ESTATICO)
    {
        inicializar_memoria();
        escribir_puerto(PUERTO_LOG, CODIGO_EXITO);
        MODO = nuevoModo;
        
    }
    else if (nuevoModo == MODO_DINAMICO)
    {
        inicializar_memoria();
        escribir_puerto(PUERTO_LOG, CODIGO_EXITO);
        MODO = nuevoModo;
        
    }
    else
    {
        escribir_puerto(PUERTO_LOG, CODIGO_PARAMETRO_INVALIDO);
        return;
    }
}

/**
 * Comando: Agregar Nodo
 * Descripción: Agrega el parámetro Num al árbol. Imprime error en el PUERTO_LOG en caso de intentar
 * escribir fuera del AREA_DE_MEMORIA. Imprime error en el PUERTO_LOG en caso de que el
 * nodo ya esté contenido en el árbol.
 */

typedef struct
{
    short num;
    short izq;
    short der;
} nodo; // nodo de 6 bytes para el arbol dinamico

void agregar_nodo(short num)
{
    printf("Comando: Agregar Nodo\n");

    short comando = (AGREGAR_NODO << 8) | (num & 0xFF);
    escribir_puerto(PUERTO_LOG, comando);

    if (MODO == MODO_ESTATICO)
    {
        // Llamar a la función agregar_nodo_estatico
        agregar_nodo_estatico(num);
    }
    else if (MODO == MODO_DINAMICO)
    {
        // Llamar a la función agregar_nodo_dinamico
        agregar_nodo_dinamico(num);
    }
}

void agregar_nodo_estatico(short num)
{
    short indice = 0;

    while (indice < AREA_MEMORIA)
    {
        if (arbol[indice] == VACIO)
        {
            arbol[indice] = num;
            escribir_puerto(PUERTO_LOG, CODIGO_EXITO);
            return;
        }
        else if (arbol[indice] == num)
        {
            escribir_puerto(PUERTO_LOG, CODIGO_NODO_YA_EXISTE);
            return;
        }
        else if (arbol[indice] > num)
        {
            indice = indice * 2 + 1;
        }
        else
        {
            indice = indice * 2 + 2;
        }
    }
    escribir_puerto(PUERTO_LOG, CODIGO_ESCRIBIR_FUERA_DE_AREA);
}

void agregar_nodo_dinamico(short num)
{
    // Un nodo son 3 lugares consecutivos en memoria
    // indice es el valor del nodo actual
    // indice + 1 es el indice del hijo izquierdo
    // indice + 2 es el indice del hijo derecho

    if (arbol[0] == VACIO)
    {
        // Si el árbol está vacío, crea un nuevo nodo y hazlo raíz.
        arbol[0] = num;
    }
    else
    {
        // encuentra el primer lugar desocupado de la memoria
        short lugarLibre = 0;
        for (int i = 0; i < AREA_MEMORIA; i += 3)
        {
            if (arbol[i] == VACIO)
            {
                lugarLibre = i;
                break;
            }
        }

        if (lugarLibre + 2 > AREA_MEMORIA )
        {
            escribir_puerto(PUERTO_LOG, CODIGO_ESCRIBIR_FUERA_DE_AREA);
            return;
        }

        if (arbol[lugarLibre] != VACIO)
        {
            escribir_puerto(PUERTO_LOG, CODIGO_ESCRIBIR_FUERA_DE_AREA);
            return;
        }

        // encuentra el nodo padre del nuevo nodo
        short indice = 0;
        while (indice < AREA_MEMORIA)
        {
            if (arbol[indice] == num)
            {
                escribir_puerto(PUERTO_LOG, CODIGO_NODO_YA_EXISTE);
                return;
            }
            else if (arbol[indice] > num)
            {
                if (arbol[indice + 1] == VACIO)
                {
                    arbol[indice + 1] = lugarLibre;
                    break;
                }
                else
                {
                    indice = arbol[indice + 1];
                }
            }
            else
            {
                if (arbol[indice + 2] == VACIO)
                {
                    arbol[indice + 2] = lugarLibre;
                    break;
                }
                else
                {
                    indice = arbol[indice + 2];
                }
            }
        }

        // crea el nuevo nodo
        arbol[lugarLibre] = num;
        escribir_puerto(PUERTO_LOG, CODIGO_EXITO);
    }
}

/**
 * Comando: Calcular Altura
 * Descripción: Imprime la altura del árbol en el puerto de entrada/salida PUERTO_SALIDA.
 */

void calcular_altura()
{
    printf("Comando: Calcular Altura\n");

    short comando = (CALCULAR_ALTURA << 8) | (0 & 0xFF);
    escribir_puerto(PUERTO_LOG, comando);
    short altura = 0;

    if (MODO == MODO_ESTATICO)
    {
        // Llamar a la función calcular_altura_estatico
        altura = calcular_altura_estatico(0);
    }
    else if (MODO == MODO_DINAMICO)
    {
        // Llamar a la función calcular_altura_dinamico
        altura = calcular_altura_dinamico(0);
    }

    escribir_puerto(PUERTO_SALIDA, altura);
    escribir_puerto(PUERTO_LOG, CODIGO_EXITO);
}

// recursivo
short calcular_altura_estatico(short indice)
{
    if (arbol[indice] == VACIO)
    {
        return 0;
    }
    else
    {
        short alturaIzq = calcular_altura_estatico(indice * 2 + 1);
        short alturaDer = calcular_altura_estatico(indice * 2 + 2);
        if (alturaIzq > alturaDer)
        {
            return alturaIzq + 1;
        }
        else
        {
            return alturaDer + 1;
        }
    }
}

// recursivo
short calcular_altura_dinamico(short indice)
{
    if (arbol[indice] == VACIO)
    {
        return 0;
    }
    else
    {
        if (arbol[indice + 1] == VACIO && arbol[indice + 2] == VACIO)
        {
            return 1;
        }
        if (arbol[indice + 1] == VACIO && arbol[indice + 2] != VACIO)
        {
            return calcular_altura_dinamico(arbol[indice + 2]) + 1;
        }

        if (arbol[indice + 1] != VACIO && arbol[indice + 2] == VACIO)
        {
            return calcular_altura_dinamico(arbol[indice + 1]) + 1;
        }

        short alturaIzq = calcular_altura_dinamico(arbol[indice + 1]);
        short alturaDer = calcular_altura_dinamico(arbol[indice + 2]);
        if (alturaIzq > alturaDer)
        {
            return alturaIzq + 1;
        }
        else
        {
            return alturaDer + 1;
        }
    }
}

/**
 * Comando: Calcular Suma
 * Descripción: Imprime la suma de todos los valores del árbol en el puerto de entrada/salida PUERTO_SALIDA.
 */

void calcular_suma()
{
    printf("Comando: Calcular Suma\n");

    short comando = (CALCULAR_SUMA << 8) | (0 & 0xFF);
    escribir_puerto(PUERTO_LOG, comando);

    if (MODO == MODO_ESTATICO)
    {
        // Llamar a la función calcular_suma_estatico
        calcular_suma_estatico();
    }
    else if (MODO == MODO_DINAMICO)
    {
        // Llamar a la función calcular_suma_dinamico
        calcular_suma_dinamico();
    }
}

void calcular_suma_estatico()
{
    short suma = 0;
    for (int i = 0; i < AREA_MEMORIA; i++)
    {
        if (arbol[i] != VACIO)
        {
            suma += arbol[i];
        }
    }
    escribir_puerto(PUERTO_SALIDA, suma);
    escribir_puerto(PUERTO_LOG, CODIGO_EXITO);
}

void calcular_suma_dinamico()
{
    short suma = 0;
    for (int i = 0; i < AREA_MEMORIA; i += 3)
    {
        if (arbol[i] != VACIO)
        {
            suma += arbol[i];
        }
    }
    escribir_puerto(PUERTO_SALIDA, suma);
    escribir_puerto(PUERTO_LOG, CODIGO_EXITO);
}

/**
 * Comando: Imprimir Árbol
 * Descripción: Imprime todos los números del árbol en el PUERTO_SALIDA: el parámetro orden indica si se
 * imprimen de menor a mayor (0) o de mayor a menor (1).
 */

#define ORDEN_MENOR_A_MAYOR 0
#define ORDEN_MAYOR_A_MENOR 1

void imprimir_arbol(short orden)
{
    printf("Comando: Imprimir Árbol\n");

    short comando = (IMPRIMIR_ARBOL << 8) | (orden & 0xFF);
    escribir_puerto(PUERTO_LOG, comando);

    if (MODO == MODO_ESTATICO)
    {
        if (orden == ORDEN_MENOR_A_MAYOR)
        {
            imprimir_arbol_estatico_ascendente(0);
            escribir_puerto(PUERTO_LOG, CODIGO_EXITO);
        }
        else if (orden == ORDEN_MAYOR_A_MENOR)
        {
            imprimir_arbol_estatico_descendente(0);
            escribir_puerto(PUERTO_LOG, CODIGO_EXITO);
        }
        else
        {
            escribir_puerto(PUERTO_LOG, CODIGO_PARAMETRO_INVALIDO);
        }
    }
    else if (MODO == MODO_DINAMICO)
    {
        if (orden == ORDEN_MENOR_A_MAYOR)
        {
            imprimir_arbol_dinamico_ascendente(0);
            escribir_puerto(PUERTO_LOG, CODIGO_EXITO);
        }
        else if (orden == ORDEN_MAYOR_A_MENOR)
        {
            imprimir_arbol_dinamico_descendente(0);
            escribir_puerto(PUERTO_LOG, CODIGO_EXITO);
        }
        else
        {
            escribir_puerto(PUERTO_LOG, CODIGO_PARAMETRO_INVALIDO);
        }
    }
}

// recursivo

void imprimir_arbol_estatico_ascendente(short indice)
{
    if (arbol[indice] != VACIO)
    {
        imprimir_arbol_estatico_ascendente(indice * 2 + 1);
        escribir_puerto(PUERTO_SALIDA, arbol[indice]);
        imprimir_arbol_estatico_ascendente(indice * 2 + 2);
    }
}

void imprimir_arbol_estatico_descendente(short indice)
{
    if (arbol[indice] != VACIO)
    {
        imprimir_arbol_estatico_descendente(indice * 2 + 2);
        escribir_puerto(PUERTO_SALIDA, arbol[indice]);
        imprimir_arbol_estatico_descendente(indice * 2 + 1);
    }
}

void imprimir_arbol_dinamico_ascendente(short indice)
{
    if (arbol[indice] != VACIO)
    {
        imprimir_arbol_dinamico_ascendente(arbol[indice + 1]);
        escribir_puerto(PUERTO_SALIDA, arbol[indice]);
        imprimir_arbol_dinamico_ascendente(arbol[indice + 2]);
    }
}

void imprimir_arbol_dinamico_descendente(short indice)
{
    if (arbol[indice] != VACIO)
    {
        imprimir_arbol_dinamico_descendente(arbol[indice + 2]);
        escribir_puerto(PUERTO_SALIDA, arbol[indice]);
        imprimir_arbol_dinamico_descendente(arbol[indice + 1]);
    }
}

/**
 * Comando: Imprimir Memoria
 * Descripción: Imprime el contenido de memoria de los primeros N nodos (N es parámetro) en el
 * PUERTO_SALIDA. Tener en cuenta que la cantidad de bytes impresos difiere según el modo de
 * almacenamiento utilizado. En el modo estático se imprimirán 2 * N bytes (ya que cada nodo
 * simplemente guarda los 16 bits del número), mientras que en el modo dinámico se imprimirán
 * 6 * N bytes.
 */
void imprimir_memoria(short n)
{
    printf("Comando: Imprimir Memoria\n");
    short comando = (IMPRIMIR_MEMORIA << 8) | (n & 0xFF);
    escribir_puerto(PUERTO_LOG, comando);

    if (MODO == MODO_ESTATICO)
    {
        imprimir_memoria_estatico(n);
        escribir_puerto(PUERTO_LOG, CODIGO_EXITO);
    }
    else if (MODO == MODO_DINAMICO)
    {
        imprimir_memoria_dinamico(n);
        escribir_puerto(PUERTO_LOG, CODIGO_EXITO);
    }
    else
    {
        escribir_puerto(PUERTO_LOG, CODIGO_PARAMETRO_INVALIDO);
    }
}

void imprimir_memoria_estatico(short n)
{
    for (int i = 0; i < n; i++)
    {
        escribir_puerto(PUERTO_SALIDA, arbol[i]);
    }
}

void imprimir_memoria_dinamico(short n)
{
    for (int i = 0; i < n; i += 3)
    {
        escribir_puerto(PUERTO_SALIDA, arbol[i]);
        escribir_puerto(PUERTO_SALIDA, arbol[i + 1]);
        escribir_puerto(PUERTO_SALIDA, arbol[i + 2]);
    }
}

/**
 * Comando: Detener programa
 * Descripción: Detiene la ejecución del programa.
 */
void detener_programa()
{
    printf("Comando: Detener programa\n");
    CONTINUAR_PROGRAMA = 0;
};

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

// MODO ESTATICO ----------------------------------------------------------------------

/*
 * Cada nodo ocupa 2 bytes / 16 bits.
 * El árbol tiene capacidad para 2048 nodos.
 * La raíz está en la posición 0.
 * La altura máxima del árbol es 11.
 * El árbol está ordenado de menor a mayor.
 * El árbol está representado en complemento a 2.
 * El entero mas grande que se puede representar es 0x7FFF.
 * El entero mas chico que se puede representar es 0x8000.
 * Los nodos vacíos se representan con 0x8000.
 */

// Modo Dinamico ----------------------------------------------------------------------

/*
 * Cada nodo ocupa 6 bytes / 48 bits.
 * El árbol tiene capacidad para 341 nodos.
 * La raíz está en la posición 0.
 * La altura máxima del árbol es 5.
 * El árbol está ordenado de menor a mayor.
 * El árbol está representado en complemento a 2.
 * El entero mas grande que se puede representar es 0x7FFF.
 * El entero mas chico que se puede representar es 0x8000.
 * Los nodos vacíos se representan con 0x8000.
 */

// Programa principal -----------------------------------------------------------------

int main()
{
    short comando;
    short parametro;

    inicializar_memoria();

    while (CONTINUAR_PROGRAMA)
    {
        comando = leer_puerto_entrada("Ingrese un comando:");

        if (comando == CAMBIAR_MODO)
        {
            parametro = leer_puerto_entrada("Ingrese un modo:");
            cambiar_modo(parametro);
        }
        else if (comando == AGREGAR_NODO)
        {
            parametro = leer_puerto_entrada("Ingrese un valor:");
            agregar_nodo(parametro);
        }
        else if (comando == CALCULAR_ALTURA)
        {
            calcular_altura();
        }
        else if (comando == CALCULAR_SUMA)
        {
            calcular_suma();
        }
        else if (comando == IMPRIMIR_ARBOL)
        {
            parametro = leer_puerto_entrada("Ingrese un orden (0 o 1):");
            imprimir_arbol(parametro);
        }
        else if (comando == IMPRIMIR_MEMORIA)
        {
            parametro = leer_puerto_entrada("Ingrese un N cantidad de nodos:");
            imprimir_memoria(parametro);
        }
        else if (comando == DETENER_PROGRAMA)
        {
            detener_programa();
        }
        else
        {
            escribir_puerto(PUERTO_LOG, CODIGO_COMANDO_INVALIDO);
        }
    }

    return 0;
}
