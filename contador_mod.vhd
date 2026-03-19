library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_mod is
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
end entity;

architecture structural of contador_mod is

    component adder_4bit is
        port(
            A    : in  std_logic_vector(3 downto 0);
            B    : in  std_logic_vector(3 downto 0);
            S    : in  std_logic;
            Sum  : out std_logic_vector(3 downto 0);
            Cout : out std_logic
        );
    end component;

    component mux_4to1_4bit is
        port(
            A   : in  std_logic_vector(3 downto 0);
            B   : in  std_logic_vector(3 downto 0);
            C   : in  std_logic_vector(3 downto 0);
            D   : in  std_logic_vector(3 downto 0);
            Sel : in  std_logic_vector(1 downto 0);
            F   : out std_logic_vector(3 downto 0)
        );
    end component;

    signal q_reg   : std_logic_vector(3 downto 0) := (others => '0');
    signal q_sum   : std_logic_vector(3 downto 0);
    signal q_next  : std_logic_vector(3 downto 0);
    signal sel     : std_logic_vector(1 downto 0);

    constant CERO    : std_logic_vector(3 downto 0) := "0000";
    constant UNO     : std_logic_vector(3 downto 0) := "0001";
    constant LIM_VEC : std_logic_vector(3 downto 0) := std_logic_vector(to_unsigned(LIMITE, 4));

begin
    -- Q + 1
    SUMADOR: adder_4bit
        port map(
            A    => q_reg,
            B    => UNO,
            S    => '0',
            Sum  => q_sum,
            Cout => open
        );
    
	 -- MUX para elegir siguiente estado (mantener reset cargar o sumar limite)
    MUX_SIGUIENTE: mux_4to1_4bit
        port map(
            A   => q_reg,   -- mantener
            B   => CERO,    -- reset
            C   => q_sum,   -- incrementar
            D   => CERO,    -- rollover a 0
            Sel => sel,
            F   => q_next
        );

	-- Lógica combinacional de control
    process(reset, tick_1hz, enable, q_reg)
    begin
        if reset = '1' then
            sel <= "01";        -- cargar 0
        elsif tick_1hz = '0' or enable = '0' then
            sel <= "00";        -- mantener
        elsif q_reg = LIM_VEC then
            sel <= "11";        -- volver a 0
        else
            sel <= "10";        -- q + 1
        end if;
    end process;

	  -- Registro del contador
    process(clk)
    begin
        if rising_edge(clk) then
            q_reg <= q_next;
        end if;
    end process;

	 -- Acarreo al siguiente contador
    carry <= '1' when (tick_1hz = '1' and enable = '1' and q_reg = LIM_VEC) else '0';
    q <= q_reg;

end architecture;