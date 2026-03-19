library ieee;
use ieee.std_logic_1164.all;

entity temporizador_un_boton_top is
    port(
        CLOCK_50 : in  std_logic;
        BUTTON0  : in  std_logic;

        HEX0_D   : out std_logic_vector(6 downto 0);
        HEX1_D   : out std_logic_vector(6 downto 0);
        HEX2_D   : out std_logic_vector(6 downto 0);

        HEX0_DP  : out std_logic;
        HEX1_DP  : out std_logic;
        HEX2_DP  : out std_logic;

        LEDG0    : out std_logic
    );
end entity;

architecture structural of temporizador_un_boton_top is

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

    component control_boton_unico is
        generic(
            DEB_TICKS  : natural := 3;
            LONG_TICKS : natural := 201
        );
        port(
            clk         : in  std_logic;
            tick_sample : in  std_logic;
            button_n    : in  std_logic;
            running     : out std_logic;
            reset_pulse : out std_logic
        );
    end component;

    component contador_mod is
        generic(
            LIMITE : natural := 9
        );
        port(
            clk      : in  std_logic;
            reset    : in  std_logic;
            tick_1hz : in  std_logic;
            enable   : in  std_logic;
            q        : out std_logic_vector(3 downto 0);
            carry    : out std_logic
        );
    end component;

    component bcd_7seg is
        port(
            bcd : in  std_logic_vector(3 downto 0);
            seg : out std_logic_vector(6 downto 0)
        );
    end component;

    signal tick_1hz    : std_logic;
    signal tick_100hz  : std_logic;

    signal running     : std_logic;
    signal reset_pulse : std_logic;
    signal finished    : std_logic;

    signal en_u        : std_logic;
    signal en_d        : std_logic;
    signal en_m        : std_logic;

    signal u_seg       : std_logic_vector(3 downto 0);
    signal d_seg       : std_logic_vector(3 downto 0);
    signal min_u       : std_logic_vector(3 downto 0);

    signal carry_u     : std_logic;
    signal carry_d     : std_logic;

begin

    -- Tick del temporizador 1hz
    DIV_1HZ: divisor_tick
        generic map(
            CLK_HZ => 50000000,
            OUT_HZ => 1
        )
        port map(
            clk   => CLOCK_50,
            reset => reset_pulse,
            tick  => tick_1hz
        );

    -- Tick para leer el botón de 100hz
    DIV_100HZ: divisor_tick
        generic map(
            CLK_HZ => 50000000,
            OUT_HZ => 100
        )
        port map(
            clk   => CLOCK_50,
            reset => reset_pulse,
            tick  => tick_100hz
        );

    -- Control del botón único
    CTRL_BTN: control_boton_unico
        generic map(
            DEB_TICKS  => 3,
            LONG_TICKS => 201
        )
        port map(
            clk         => CLOCK_50,
            tick_sample => tick_100hz,
            button_n    => BUTTON0,
            running     => running,
            reset_pulse => reset_pulse
        );

    -- reloj se detiene al llegar a 9:59
    finished <= '1' when (min_u = "1001" and d_seg = "0101" and u_seg = "1001") else '0';

    en_u <= running and (not finished);
    en_d <= en_u and carry_u;
    en_m <= en_u and carry_u and carry_d;

    CONT_USEG: contador_mod
        generic map(LIMITE => 9)
        port map(
            clk      => CLOCK_50,
            reset    => reset_pulse,
            tick_1hz => tick_1hz,
            enable   => en_u,
            q        => u_seg,
            carry    => carry_u
        );

    CONT_DSEG: contador_mod
        generic map(LIMITE => 5)
        port map(
            clk      => CLOCK_50,
            reset    => reset_pulse,
            tick_1hz => tick_1hz,
            enable   => en_d,
            q        => d_seg,
            carry    => carry_d
        );

    CONT_MIN: contador_mod
        generic map(LIMITE => 9)
        port map(
            clk      => CLOCK_50,
            reset    => reset_pulse,
            tick_1hz => tick_1hz,
            enable   => en_m,
            q        => min_u,
            carry    => open
        );

    DISP0: bcd_7seg port map(bcd => u_seg,  seg => HEX0_D);
    DISP1: bcd_7seg port map(bcd => d_seg,  seg => HEX1_D);
    DISP2: bcd_7seg port map(bcd => min_u,  seg => HEX2_D);

    -- Punto decimal para ver m:ss
    HEX0_DP <= '1';
    HEX1_DP <= '1';
    HEX2_DP <= '0';

    LEDG0 <= running;

end architecture;