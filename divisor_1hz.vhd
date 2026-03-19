library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divisor_1hz is
    generic(
        CLK_HZ : natural := 50000000; -- reloj real de la DE0
        OUT_HZ : natural := 1         -- velocidad del conteo
    );
    port(
        clk      : in  std_logic;
        reset    : in  std_logic;
        tick_1hz : out std_logic
    );
end entity;

architecture rtl of divisor_1hz is
    constant MAX_COUNT : natural := (CLK_HZ / OUT_HZ) - 1;
    signal contador    : natural range 0 to MAX_COUNT := 0;
    signal tick_reg    : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                contador <= 0;
                tick_reg <= '0';
            elsif contador = MAX_COUNT then
                contador <= 0;
                tick_reg <= '1'; -- pulso de 1 ciclo
            else
                contador <= contador + 1;
                tick_reg <= '0';
            end if;
        end if;
    end process;

    tick_1hz <= tick_reg;
end architecture;