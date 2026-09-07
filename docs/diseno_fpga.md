# Notas de diseño - Parte FPGA (botones, displays, LEDs)

Esta parte conecta `calculadora_4bits.v` con los botones y displays
físicos de la Go Board. **No se probó en una placa real** (no había una
disponible al armar esto), así que queda simulada y documentada, pero
falta la validación física — timing de botones, orientación de los
displays, etc.

## Supuestos que hay que confirmar antes de la demo

Estos son los puntos donde tuve que asumir algo porque el enunciado no
lo dice explícito. Ojalá revisarlos con el profe/ayudante o contra el
`combinational.zip` que compartió el profesor antes del miércoles:

1. **Polaridad de los botones**: asumí activos en bajo (`0` = presionado,
   `1` = suelto), que es lo más común en estas placas. Si en la Go Board
   son al revés, hay que invertir la entrada `boton_crudo` de cada
   `debounce` en `fpga_top.v`.
2. **Cuál switch es cuál botón físico**: el `.pcf` numera los botones
   `Switch_1` a `Switch_4` pero no dice si `Switch_1` es el de arriba a
   la izquierda o cuál. Asumí el orden 1=sup. izq. (incrementar),
   2=inf. izq. (disminuir), 3=sup. der. (confirmar), 4=inf. der. (usar
   resultado anterior), como los describe el enunciado en ese orden. Si
   no calza en la placa real, se cambia con solo reordenar las 4 líneas
   de `set_io i_Switch_x` en el `.pcf`.
3. **El .pcf en sí**: es el pinout público de la Go Board estándar de
   Nandland (bajado de un repo de ejemplos de sus tutoriales), no uno
   oficial del curso. Si el ramo entrega uno propio, hay que usar ese.
4. **Persistencia de los valores entre operaciones**: el profe contestó
   en el foro que da lo mismo si el valor se mantiene o vuelve a 0 al
   confirmar. Se dejó que se mantenga (no se resetea el contador de
   código/operando al empezar una entrada nueva), para no tener que
   inventar más lógica de reset.
5. **Qué se muestra en los displays mientras se elige la operación**
   (estado inicial): el enunciado no lo dice, se dejó apagado (los 14
   segmentos en 0) porque en ese momento lo relevante son los LEDs.
6. **Signo cuando el valor es 0 o positivo**: se deja el digito de signo
   apagado (sin "+"), solo se prende la rayita cuando es negativo. El
   único ejemplo que dio el profe fue de un negativo.

## Sobre las restricciones de "solo compuertas"

El enunciado dice que **la lógica combinacional de la calculadora**
tiene que ser con compuertas primitivas. Esa parte (todo lo que ya
armamos en `calculadora_4bits.v` y sus submódulos) no se tocó. Los
archivos nuevos de esta etapa son:

- `bin_a_7seg.v`, `signo_7seg.v`, `magnitud4.v`: son combinacionales
  parecidos a los de la ALU, así que se hicieron igual, con puras
  compuertas (`bin_a_7seg` con un NOR de minterminos por segmento,
  `magnitud4` reutilizando `adder4`).
- `debounce.v`, `contador_ud.v`, `fpga_top.v` (la máquina de estados):
  esto es lógica de **control de interfaz** (máquinas de estado con
  botones, contadores de UI), no es "la calculadora" ni implementa
  ninguna de sus 6 operaciones. Se hizo con `always @(posedge clk)` +
  `case`/`if`/`+`/`-`, como se ve normalmente una FSM de curso (el ramo
  vio Moore/Mealy justo para esto). Si se prefiere una lectura más
  estricta de la restricción, avisen y se puede rehacer esta capa
  también a compuertas puras (es bastante más trabajo, sobre todo los
  contadores arriba/abajo).

## Máquina de estados

4 estados (Moore), controlados por el botón de confirmar (switch 3):

```
S_OP (eligiendo operacion, LEDs muestran el codigo)
  --confirmar--> S_OP1 (ingresando primer operando)
                   --confirmar--> S_OP2 (ingresando segundo operando)
                                    --confirmar--> S_RES (mostrando resultado, aca se ejecuta la operacion)
                                                     --confirmar--> vuelve a S_OP
```

En `S_OP2`, el botón 4 (inferior derecho) alterna `sel_op2`: si queda en
1, el segundo operando pasa a ser el resultado guardado de la operación
anterior en vez del valor que se estaba subiendo/bajando con los
botones 1/2.

La señal `ejecutar` que recibe `calculadora_4bits` se genera
combinacionalmente (`pulso_confirmar AND estado==S_OP2`), así que el
registro de resultado se carga justo en el mismo flanco de reloj en que
la máquina de estados pasa de `S_OP2` a `S_RES`.

## Display: signo + magnitud

Se sacó del enunciado y de la respuesta del profesor en el foro (ej:
`1110` = -2 debe mostrarse como "-2", no como "-E"). Como el rango es
chico (-8 a 7), no hace falta un conversor a BCD de verdad: la magnitud
de un numero en complemento a 2 de 4 bits siempre entra en 4 bits sin
signo (el peor caso es -8, cuya magnitud 8 = `1000` todavía cabe). Por
eso `magnitud4.v` reutiliza el mismo `adder4` que ya teníamos: si el
número es negativo se le aplica el mismo truco de complemento a 2 que
usa la resta (invertir bits + sumar 1), si es positivo se deja igual.

## Cómo se prueba (simulación, no hardware)

```bash
iverilog -g2012 -o sim/bin_a_7seg_tb.vvp src/bin_a_7seg.v tb/bin_a_7seg_tb.v
vvp sim/bin_a_7seg_tb.vvp

iverilog -g2012 -o sim/magnitud4_tb.vvp src/full_adder.v src/adder4.v src/magnitud4.v tb/magnitud4_tb.v
vvp sim/magnitud4_tb.vvp

iverilog -g2012 -o sim/contador_ud_tb.vvp src/contador_ud.v tb/contador_ud_tb.v
vvp sim/contador_ud_tb.vvp

iverilog -g2012 -o sim/debounce_tb.vvp src/debounce.v tb/debounce_tb.v
vvp sim/debounce_tb.vvp

iverilog -g2012 -o sim/fpga_top_tb.vvp src/full_adder.v src/adder4.v src/mux2to1_4bit.v src/shifter4.v src/mux8to1_4bit.v src/reg4.v src/calculadora_4bits.v src/debounce.v src/contador_ud.v src/bin_a_7seg.v src/magnitud4.v src/signo_7seg.v src/fpga_top.v tb/fpga_top_tb.v
vvp sim/fpga_top_tb.vvp
```

`fpga_top_tb.v` simula botones presionados con un `DEBOUNCE_LIMIT`
chico (parametrizado) para que la simulación no demore los ~20ms reales
de debounce por cada click. En la placa real se usa el valor por
defecto (500000 ciclos, ~20ms a 25MHz).

## Cómo sintetizar para la FPGA (falta probar)

No se corrió esto todavía (no hay toolchain de síntesis para iCE40
instalado en este entorno). El flujo típico con las herramientas
open source que usa el curso (yosys + nextpnr-ice40 + icepack + iceprog,
o el iceCube2/apio equivalente) sería:

```bash
yosys -p "synth_ice40 -top fpga_top -json fpga/fpga_top.json" src/full_adder.v src/adder4.v src/mux2to1_4bit.v src/shifter4.v src/mux8to1_4bit.v src/reg4.v src/calculadora_4bits.v src/debounce.v src/contador_ud.v src/bin_a_7seg.v src/magnitud4.v src/signo_7seg.v src/fpga_top.v

nextpnr-ice40 --hx1k --package vq100 --json fpga/fpga_top.json --pcf fpga/Go_Board_Constraints.pcf --asc fpga/fpga_top.asc

icepack fpga/fpga_top.asc fpga/fpga_top.bin

iceprog fpga/fpga_top.bin
```

Falta instalar ese toolchain (o usar el que ya tengan configurado del
curso) y probar en la placa real.
