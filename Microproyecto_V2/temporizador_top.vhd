library ieee;
use ieee.std_logic_1164.all;

entity temporizador_top is
    port(
        CLOCK_50 : in  std_logic;
        BUTTON   : in  std_logic_vector(2 downto 0);

        HEX0_D   : out std_logic_vector(6 downto 0);
        HEX1_D   : out std_logic_vector(6 downto 0);
        HEX2_D   : out std_logic_vector(6 downto 0);

        HEX0_DP  : out std_logic;
        HEX1_DP  : out std_logic;
        HEX2_DP  : out std_logic;

        LEDG0    : out std_logic
    );
end entity;

architecture structural of temporizador_top is

    component divisor_1hz is
        generic(
            CLK_HZ : natural := 50000000
        );
        port(
            clk      : in  std_logic;
            reset    : in  std_logic;
            tick_1hz : out std_logic
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

    signal start_i   : std_logic;
    signal stop_i    : std_logic;
    signal reset_i   : std_logic;

    signal tick_1hz  : std_logic;
    signal running   : std_logic := '0';
    signal finished  : std_logic;

    signal en_u      : std_logic;
    signal en_d      : std_logic;
    signal en_m      : std_logic;

    signal u_seg     : std_logic_vector(3 downto 0);
    signal d_seg     : std_logic_vector(3 downto 0);
    signal min_u     : std_logic_vector(3 downto 0);

    signal carry_u   : std_logic;
    signal carry_d   : std_logic;

begin

    -- Botones activos en bajo
    start_i <= not BUTTON(0);
    stop_i  <= not BUTTON(1);
    reset_i <= not BUTTON(2);

	 -- Generación del pulso de 1 Hz
    DIVISOR: divisor_1hz
        port map(
            clk      => CLOCK_50,
            reset    => reset_i,
            tick_1hz => tick_1hz
        );

    -- Control start/stop
    process(CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            if reset_i = '1' then
                running <= '0';
            elsif finished = '1' then
                running <= '0';
            elsif start_i = '1' then
                running <= '1';
            elsif stop_i = '1' then
                running <= '0';
            end if;
        end if;
    end process;

    -- Se detiene en 9:59
    finished <= '1' when (min_u = "1001" and d_seg = "0101" and u_seg = "1001") else '0';

	  -- Enables en cascada
    en_u <= running and (not finished);
    en_d <= en_u and carry_u;
    en_m <= en_u and carry_u and carry_d;

	 -- Contador unidades de segundo
    CONT_USEG: contador_mod
        generic map(LIMITE => 9)
        port map(
            clk      => CLOCK_50,
            reset    => reset_i,
            tick_1hz => tick_1hz,
            enable   => en_u,
            q        => u_seg,
            carry    => carry_u
        );

		-- Contador decenas de segundo
    CONT_DSEG: contador_mod
        generic map(LIMITE => 5)
        port map(
            clk      => CLOCK_50,
            reset    => reset_i,
            tick_1hz => tick_1hz,
            enable   => en_d,
            q        => d_seg,
            carry    => carry_d
        );

    -- Contador minutos

    CONT_MIN: contador_mod
        generic map(LIMITE => 9)
        port map(
            clk      => CLOCK_50,
            reset    => reset_i,
            tick_1hz => tick_1hz,
            enable   => en_m,
            q        => min_u,
            carry    => open
        );
		  
    -- Decodificación a displays

    DISP0: bcd_7seg port map(bcd => u_seg, seg => HEX0_D);
    DISP1: bcd_7seg port map(bcd => d_seg, seg => HEX1_D);
    DISP2: bcd_7seg port map(bcd => min_u, seg => HEX2_D);

    -- puntos decimales 
    HEX0_DP <= '1';
    HEX1_DP <= '1';
    HEX2_DP <= '1';

    -- LED para ver si está corriendo o no
    LEDG0 <= running;

end architecture;