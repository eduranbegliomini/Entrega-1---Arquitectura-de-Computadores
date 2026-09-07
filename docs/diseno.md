# Notas de diseño - Calculadora de 4 bits

Esto son las tablas de verdad, Karnaugh y ecuaciones que se usaron para armar
cada bloque de la calculadora. Sirve de base para el informe.

## Arquitectura general

```
                +-----------------------------------------+
op2_ext ------->|                                          |
                |   mux 2:1    -->  B  -->  ALU (paralelo)  |
resultado ----->|  (sel_op2)        |         |             |
 anterior       |                   |         v             |
                |                 mux 8:1 (codigo) --> D --+---> reg4 --> resultado
op1 ----------->|-------------------^                       |     ^
                |                                            |     |
                +-----------------------------------------+  clk, ejecutar
```

1. Mux 2:1 (`mux2to1_4bit`) elige el operando B: `op2_ext` si `sel_op2=0`,
   o el resultado guardado si `sel_op2=1` (encadenamiento).
2. La ALU calcula **todas** las operaciones al mismo tiempo con bloques
   independientes (no hay nada secuencial acá, es puro combinacional):
   suma, resta, resta inversa, shift izquierda, shift derecha.
3. Mux 8:1 (`mux8to1_4bit`) elige cuál de esos resultados sale, según
   `codigo`.
4. Registro de 4 bits (`reg4`), guarda lo que sale del mux 8:1 en el
   flanco de subida de `clk`, pero solo si `ejecutar=1`.

No hay pin de reset físico: "Reinicio" es una operación más (código 000)
que hace que el mux 8:1 saque `0000`, y ese valor se guarda en el registro
como cualquier otro resultado, cuando se activa `ejecutar`.

## Full adder (`full_adder.v`)

Tabla de verdad de 1 bit:

| A | B | Cin | S | Cout |
|---|---|-----|---|------|
| 0 | 0 | 0   | 0 | 0 |
| 0 | 0 | 1   | 1 | 0 |
| 0 | 1 | 0   | 1 | 0 |
| 0 | 1 | 1   | 0 | 1 |
| 1 | 0 | 0   | 1 | 0 |
| 1 | 0 | 1   | 0 | 1 |
| 1 | 1 | 0   | 0 | 1 |
| 1 | 1 | 1   | 1 | 1 |

Del Karnaugh de S (3 variables, tablero de ajedrez clásico) sale que no se
puede simplificar más que XOR:

```
S = A xor B xor Cin
```

Karnaugh de Cout: los tres 1 se agrupan en pares (AB, A·Cin, B·Cin) y da:

```
Cout = A·B + Cin·(A xor B)
```

(se reusa el `A xor B` que ya se calculó para S, ahorra una compuerta).

Sumador de 4 bits (`adder4.v`): son 4 full adders en cascada, el carry de
salida de uno entra al carry de entrada del siguiente (ripple carry).

## Resta con complemento a 2

En vez de armar un restador aparte, se reusa el mismo sumador de 4 bits.
La idea es la de siempre: `A - B = A + (NOT B) + 1`.

Se agregó una entrada de control `sub` a `adder4`:

- `sub = 0`: suma normal, B no se toca, Cin = 0.
- `sub = 1`: se invierte B bit a bit (`xor` con 1) y Cin = 1.

```
B_real[i] = B[i] xor sub
Cin_primera_etapa = sub
```

Para la resta inversa (`B - A`) no hace falta lógica extra: se conecta el
mismo `adder4` con las entradas cambiadas de lugar (`a=B`, `b=A`, `sub=1`)
en `calculadora_4bits.v`. O sea la calculadora instancia `adder4` tres
veces: una para suma, una para A-B, una para B-A (con A y B invertidos de
posición).

## Shift left y shift right (`shifter4.v`)

`B[1:0]` dice cuánto desplazar (0 a 3 posiciones). Como el desplazamiento
posible es chico (4 casos), no hace falta armar el Karnaugh de 6 variables
completo: para cada valor de `B1B0` fijo, cada bit de salida depende de
un solo bit de A (o es 0), así que la tabla queda chica y se simplifica
sola.

**Shift left** (rellena con 0 por la derecha):

| B1 B0 | shift | R3 | R2 | R1 | R0 |
|-------|-------|----|----|----|----|
| 00 | 0 | A3 | A2 | A1 | A0 |
| 01 | 1 | A2 | A1 | A0 | 0 |
| 10 | 2 | A1 | A0 | 0 | 0 |
| 11 | 3 | A0 | 0 | 0 | 0 |

Ecuaciones (suma de productos, sacadas directo de la tabla de arriba):

```
R0 = B1'B0' A0
R1 = B1'B0' A1 + B1'B0 A0
R2 = B1'B0' A2 + B1'B0 A1 + B1B0' A0
R3 = B1'B0' A3 + B1'B0 A2 + B1B0' A1 + B1B0 A0
```

**Shift right** (rellena con 0 por la izquierda), es la imagen espejo:

| B1 B0 | shift | R3 | R2 | R1 | R0 |
|-------|-------|----|----|----|----|
| 00 | 0 | A3 | A2 | A1 | A0 |
| 01 | 1 | 0 | A3 | A2 | A1 |
| 10 | 2 | 0 | 0 | A3 | A2 |
| 11 | 3 | 0 | 0 | 0 | A3 |

```
R3 = B1'B0' A3
R2 = B1'B0' A2 + B1'B0 A3
R1 = B1'B0' A1 + B1'B0 A2 + B1B0' A3
R0 = B1'B0' A0 + B1'B0 A1 + B1B0' A2 + B1B0 A3
```

En `calculadora_4bits.v` se instancia `shifter4` dos veces (una fija en
shift izquierda, otra fija en shift derecha), y el mux 8:1 elige cuál de
las dos usar según `codigo`.

## Mux 8:1 de salida (`mux8to1_4bit.v`)

En vez de escribir la tabla de verdad completa de 4 bits x 8 entradas
(profesor confirmó en el foro que no es necesario, con que quede
explicado cómo se armó basta), se construyó como árbol de 3 niveles de
mux 2:1: primero se elige con el bit menos significativo del selector,
después con el del medio, y al final con el más significativo. Es
equivalente a la suma de productos de un mux 8:1 pero mucho más fácil de
armar y de revisar.

Asignación de entradas según `codigo`:

| codigo | operación | entrada |
|--------|-----------|---------|
| 000 | reinicio | `0000` fijo |
| 001 | suma | resultado del sumador |
| 010 | resta (A-B) | resultado del restador |
| 011 | resta inversa (B-A) | resultado del restador con A y B cambiados |
| 100 | shift left | resultado del shifter (fijo en izquierda) |
| 101 | shift right | resultado del shifter (fijo en derecha) |
| 110 | reservado | `0000` fijo (mismo comportamiento que reinicio) |
| 111 | reservado | `0000` fijo (mismo comportamiento que reinicio) |

Los códigos 110 y 111 no están definidos en el enunciado, así que se
decidió dejarlos con el mismo comportamiento que el reinicio (salida
`0000`), para que las 8 entradas del mux queden definidas y no se infiera
un latch al sintetizar.

## Registro de resultado (`reg4.v`)

Registro de 4 bits con flip-flops D. Para que solo cargue cuando
`ejecutar=1`, se puso un mux 2:1 antes del flip-flop: si `ejecutar=0` el
mux vuelve a meter el mismo valor que ya estaba guardado (`Q`), así el
flip-flop "no cambia" aunque el reloj siga andando; si `ejecutar=1` entra
el valor nuevo. Esto evita tener que usar un `if` dentro del
`always @(posedge clk)`.
