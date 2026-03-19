library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity micro_ocupacion_top is
    port(
        CLOCK_50 : in  std_logic;
        BUTTON   : in  std_logic_vector(2 downto 0);

        HEX0_D   : out std_logic_vector(6 downto 0);
        HEX1_D   : out std_logic_vector(6 downto 0);
        HEX2_D   : out std_logic_vector(6 downto 0);

        HEX0_DP  : out std_logic;
        HEX1_DP  : out std_logic;
        HEX2_DP  : out std_logic;

        LEDG0    : out std_logic; -- ocupado
        LEDG1    : out std_logic; -- felicitacion
        LEDG2    : out std_logic  -- alarma
    );
end entity;

architecture behavioral of micro_ocupacion_top is

    component divisor_tick is
        generic(
            CLK_HZ : natural := 50000000;
            OUT_HZ : natural := 1
        );
        port(
            clk   : in  std_logic;
            reset : in  std_logic;
            tick  : out std_logic
        );
    end component;

    component bcd_7seg is
        port(
            bcd : in  std_logic_vector(3 downto 0);
            seg : out std_logic_vector(6 downto 0)
        );
    end component;

    type state_t is (ESPERA, CUENTA_35, FELICITACION, EXCESO);
    signal state : state_t := ESPERA;

    signal reset_i      : std_logic;
    signal btn_ingreso  : std_logic;
    signal btn_salida   : std_logic;

    signal tick_1hz     : std_logic;
    signal tick_100hz   : std_logic;

    signal ingreso_prev : std_logic := '0';
    signal salida_prev  : std_logic := '0';
    signal ingreso_evt  : std_logic := '0';
    signal salida_evt   : std_logic := '0';

    signal tiempo_restante : integer range 0 to 35  := 0;
    signal tiempo_extra    : integer range 0 to 599 := 0;
    signal felic_seg       : integer range 0 to 2   := 0;

    signal tiempo_mostrar  : integer range 0 to 599 := 0;

    signal bcd_hex0 : std_logic_vector(3 downto 0);
    signal bcd_hex1 : std_logic_vector(3 downto 0);
    signal bcd_hex2 : std_logic_vector(3 downto 0);

begin

    -- Botones activos en bajo
    btn_ingreso <= not BUTTON(0);
    btn_salida  <= not BUTTON(1);
    reset_i     <= not BUTTON(2);

    -- Base de tiempo de 1 segundo
    DIV_1HZ: divisor_tick
        generic map(
            CLK_HZ => 50000000,
            OUT_HZ => 1
        )
        port map(
            clk   => CLOCK_50,
            reset => reset_i,
            tick  => tick_1hz
        );

    -- Muestreo de botones a 100 Hz para evitar rebotes notorios
    DIV_100HZ: divisor_tick
        generic map(
            CLK_HZ => 50000000,
            OUT_HZ => 100
        )
        port map(
            clk   => CLOCK_50,
            reset => reset_i,
            tick  => tick_100hz
        );

    -- Detección de eventos de ingreso y salida
    process(CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            ingreso_evt <= '0';
            salida_evt  <= '0';

            if reset_i = '1' then
                ingreso_prev <= '0';
                salida_prev  <= '0';
            elsif tick_100hz = '1' then
                if btn_ingreso = '1' and ingreso_prev = '0' then
                    ingreso_evt <= '1';
                end if;

                if btn_salida = '1' and salida_prev = '0' then
                    salida_evt <= '1';
                end if;

                ingreso_prev <= btn_ingreso;
                salida_prev  <= btn_salida;
            end if;
        end if;
    end process;

    -- Máquina de estados principal del microproyecto
    process(CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            if reset_i = '1' then
                state           <= ESPERA;
                tiempo_restante <= 0;
                tiempo_extra    <= 0;
                felic_seg       <= 0;

            else
                case state is

                    when ESPERA =>
                        tiempo_restante <= 0;
                        tiempo_extra    <= 0;
                        felic_seg       <= 0;

                        if ingreso_evt = '1' then
                            state           <= CUENTA_35;
                            tiempo_restante <= 35;
                            tiempo_extra    <= 0;
                        end if;

                    when CUENTA_35 =>
                        if salida_evt = '1' then
                            state     <= FELICITACION;
                            felic_seg <= 2; -- muestra felicitación 2 segundos
                        elsif tick_1hz = '1' then
                            if tiempo_restante > 1 then
                                tiempo_restante <= tiempo_restante - 1;
                            else
                                tiempo_restante <= 0;
                                tiempo_extra    <= 0;
                                state           <= EXCESO;
                            end if;
                        end if;

                    when FELICITACION =>
                        if tick_1hz = '1' then
                            if felic_seg > 1 then
                                felic_seg <= felic_seg - 1;
                            else
                                felic_seg <= 0;
                                state     <= ESPERA;
                            end if;
                        end if;

                    when EXCESO =>
                        if salida_evt = '1' then
                            state        <= ESPERA;
                            tiempo_extra <= 0;
                        elsif tick_1hz = '1' then
                            if tiempo_extra < 599 then
                                tiempo_extra <= tiempo_extra + 1;
                            end if;
                        end if;

                end case;
            end if;
        end if;
    end process;

    -- Qué tiempo se muestra en los displays
    process(state, tiempo_restante, tiempo_extra)
    begin
        case state is
            when CUENTA_35 =>
                tiempo_mostrar <= tiempo_restante; -- cuenta regresiva
            when EXCESO =>
                tiempo_mostrar <= tiempo_extra;    -- tiempo de más
            when others =>
                tiempo_mostrar <= 0;               -- espera o felicitación
        end case;
    end process;

    -- Conversión de segundos a formato M:SS
    process(tiempo_mostrar)
        variable v_min : integer;
        variable v_d1  : integer;
        variable v_d0  : integer;
    begin
        v_min := tiempo_mostrar / 60;
        v_d1  := (tiempo_mostrar mod 60) / 10;
        v_d0  := (tiempo_mostrar mod 60) mod 10;

        bcd_hex2 <= std_logic_vector(to_unsigned(v_min, 4));
        bcd_hex1 <= std_logic_vector(to_unsigned(v_d1, 4));
        bcd_hex0 <= std_logic_vector(to_unsigned(v_d0, 4));
    end process;

    -- Displays
    DISP0: bcd_7seg port map(bcd => bcd_hex0, seg => HEX0_D);
    DISP1: bcd_7seg port map(bcd => bcd_hex1, seg => HEX1_D);
    DISP2: bcd_7seg port map(bcd => bcd_hex2, seg => HEX2_D);

    -- Punto decimal para separar M:SS
    HEX0_DP <= '1';
    HEX1_DP <= '1';
    HEX2_DP <= '0';

    -- LEDs de estado
    LEDG0 <= '1' when (state = CUENTA_35 or state = EXCESO) else '0'; -- ocupado
    LEDG1 <= '1' when (state = FELICITACION) else '0';                 -- felicitación
    LEDG2 <= '1' when (state = EXCESO) else '0';                       -- alarma

end architecture;