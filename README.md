# Calculadora de 4 bits - Proyecto 1 Arquitectura de Computadores

Calculadora de 4 bits en Verilog para la FPGA Lattice iCE40 HX1K (Nandland Go Board).
Toda la logica combinacional esta hecha solo con compuertas primitivas de Verilog
(`and`, `or`, `not`, `xor`), sin usar `+`, `-`, comparadores, shifts de alto nivel
ni `if`/`case` para la logica de la ALU.

## Estructura

* `src/`: modulos de Verilog (.v)
* `tb/`: testbenches (.v)
* `sim/`: salida de la simulacion (.vvp, .vcd) - no se sube al repo
* `docs/`: informe de arquitectura (arquip1_2.pdf)
* `fpga/`: archivo oficial de constraints (go-board.pcf) para la Go Board

## Modulos

* `full_adder.v`: sumador completo de 1 bit.
* `adder4.v`: sumador/restador de 4 bits (4 full adders encadenados + complemento a 2).
* `mux2to1_4bit.v`: mux 2:1 de 4 bits.
* `shifter4.v`: shifter de 4 bits, izquierda y derecha.
* `mux8to1_4bit.v`: mux 8:1 de 4 bits (armado como arbol de mux2to1).
* `reg4.v`: registro de 4 bits con flip-flops D, carga habilitada por `ejecutar`.
* `calculadora_4bits.v`: modulo top, junta todo lo anterior.

Interfaz del modulo top (la que espera el testbench del curso):

```verilog
module calculadora_4bits (
  input  wire       clk,
  input  wire       ejecutar,
  input  wire [2:0] codigo,
  input  wire       sel_op2,
  input  wire [3:0] op1,
  input  wire [3:0] op2_ext,
  output wire [3:0] resultado,
  output wire       overflow // Indicador visual de desbordamiento
);
```

### Parte FPGA (botones, displays, LEDs)

Ademas del datapath, `src/fpga_top.v` conecta `calculadora_4bits` con los 4 botones, los 2 displays de 7 segmentos y los 4 LEDs de la Go Board:

* `debounce.v`: filtra rebotes de un boton y devuelve un pulso por presionada.
* `contador_ud.v`: contador subir/bajar generico, para ir armando el codigo de operacion y los operandos con los botones.
* `bin_a_7seg.v`: decodifica un digito hex a los 7 segmentos (con compuertas).
* `magnitud4.v` + `signo_7seg.v`: convierten el numero en complemento a 2 a signo + magnitud para mostrarlo (reutiliza `adder4`).
* `fpga_top.v`: la maquina de estados que junta todo. Los primeros 3 LEDs muestran la operacion actual y el LED 4 muestra el desbordamiento (overflow).

*Nota: La documentacion detallada de diseno, mapas de Karnaugh y ecuaciones booleanas se encuentra en `docs/arquip1_2.pdf`.*

## Como sintetizar el hardware (OSS CAD Suite)

El diseno ha sido verificado con exito para la arquitectura iCE40.
Para generar el archivo binario a cargar en la FPGA, ejecuta estos comandos en la terminal de **OSS CAD Suite** desde la raiz del proyecto:

```bash
# 1. Sintetizar con Yosys
yosys -p "synth_ice40 -top fpga_top -json hardware.json" src/fpga_top.v src/calculadora_4bits.v src/adder4.v src/shifter4.v src/mux8to1_4bit.v src/mux2to1_4bit.v src/reg4.v src/full_adder.v src/debounce.v src/contador_ud.v src/magnitud4.v src/signo_7seg.v src/bin_a_7seg.v

# 2. Place & Route con NextPNR
nextpnr-ice40 --hx1k --package vq100 --json hardware.json --pcf fpga/go-board.pcf --asc hardware.asc

# 3. Empaquetar el binario
icepack hardware.asc hardware.bin

# 4. Programar la placa (requiere Go Board conectada + driver WinUSB)
iceprog hardware.bin
```

## Como correr las simulaciones

Requisito: [Icarus Verilog](http://iverilog.icarus.com/) instalado (`iverilog` y `vvp` en el PATH).

Desde la raiz del proyecto, en la terminal:

```bash
# Ejemplo de simulacion de la calculadora completa
iverilog -g2012 -o sim/calculadora_4bits_tb.vvp src/full_adder.v src/adder4.v src/mux2to1_4bit.v src/shifter4.v src/mux8to1_4bit.v src/reg4.v src/calculadora_4bits.v tb/calculadora_4bits_tb.v
vvp sim/calculadora_4bits_tb.vvp
```

Para ver las formas de onda generadas:
```bash
gtkwave sim/calculadora_4bits_tb.vcd
```

## Estado
Todos los testbenches (datapath + FPGA) pasan sin fallos. La sintesis logica con Yosys compila a 0 errores.
