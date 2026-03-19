# Microproyecto VHDL - DE0 Board

Este repositorio reúne tres desarrollos realizados en VHDL para la tarjeta **DE0 de Altera/Terasic** usando **Quartus II**, enfocados en temporizadores, control por botones y visualización en displays de 7 segmentos.

## 1. Temporizador básico con start, stop y reset

En el primer punto se desarrolló un temporizador capaz de contar desde **0:00 hasta 9:59**, mostrando el tiempo en **3 displays de 7 segmentos**.

### Características:
- Botón de **start**
- Botón de **stop**
- Botón de **reset**
- Conteo en formato **m:ss**
- Detención automática al llegar a **9:59**

### Componentes usados:
- Divisor de frecuencia para obtener una base de tiempo de **1 Hz**
- Contadores modulares para:
  - unidades de segundo
  - decenas de segundo
  - minutos
- Sumador de 4 bits (`adder_4bit`)
- Multiplexor 4 a 1 (`mux_4to1`)
- Decodificador `bcd_7seg` para los displays

---

## 2. Temporizador con un solo botón

En el segundo punto se reutilizó el temporizador anterior, pero cambiando la lógica de control para trabajar con **un único botón**.

### Comportamiento:
- **Pulsación corta**: alterna entre **start** y **stop**
- **Pulsación larga** (más de 2 segundos): hace **reset**

### Características:
- Se mantiene el conteo de **0:00 a 9:59**
- Se siguen usando los **3 displays de 7 segmentos**
- Se implementa una lógica de control para diferenciar pulsación corta y larga
- Se usa una base de tiempo rápida adicional para analizar correctamente el botón

### Componentes usados:
- Divisor de frecuencia para **1 Hz**
- Divisor adicional para muestreo del botón
- Control de botón único
- Contadores modulares
- Decodificador `bcd_7seg`

---

## 3. Microproyecto: Ocupación de Espacios

En el tercer punto se desarrolló el **microproyecto completo**, simulando la ocupación de un espacio físico.

### Funcionamiento:
- Cuando una persona **ingresa**, se inicia una cuenta regresiva de **35 segundos**
- Si la persona **sale antes** de terminar el tiempo:
  - el conteo se detiene
  - se activa una **felicitación**
- Si la persona **permanece después de 35 segundos**:
  - se activa una **alarma**
  - comienza a contarse el **tiempo extra** para facturación
- Cuando la persona sale, el sistema vuelve al estado de espera

### Entradas y salidas:
- `BUTTON[0]`: ingreso
- `BUTTON[1]`: salida
- `BUTTON[2]`: reset general
- `LEDG0`: espacio ocupado
- `LEDG1`: felicitación
- `LEDG2`: alarma
- `HEX2 HEX1 HEX0`: visualización del tiempo

### Implementación:
- Máquina de estados para controlar el comportamiento general
- Base de tiempo de **1 segundo**
- Visualización del tiempo en formato **m:ss**
- Integración de casos de uso:
  - salida antes de 35 s
  - permanencia con tiempo excedido

---

## Tecnologías utilizadas
- **VHDL**
- **Quartus II**
- **Tarjeta DE0**
- Diseño estructural, modular y por componentes

## Objetivo del repositorio
Documentar y organizar los ejercicios previos y el microproyecto final, dejando una base reutilizable para prácticas de diseño digital con FPGA.
