library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divisor_tick is
    generic(
        CLK_HZ : natural := 50000000;
        OUT_HZ : natural := 1
    );
    port(
        clk   : in  std_logic;
        reset : in  std_logic;
        tick  : out std_logic
    );
end entity;

architecture rtl of divisor_tick is
    constant DIVISOR   : natural := CLK_HZ / OUT_HZ;
    constant MAX_COUNT : natural := DIVISOR - 1;

    signal count_reg : natural range 0 to MAX_COUNT := 0;
    signal tick_reg  : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                count_reg <= 0;
                tick_reg  <= '0';
            elsif count_reg = MAX_COUNT then
                count_reg <= 0;
                tick_reg  <= '1';
            else
                count_reg <= count_reg + 1;
                tick_reg  <= '0';
            end if;
        end if;
    end process;

    tick <= tick_reg;
end architecture;