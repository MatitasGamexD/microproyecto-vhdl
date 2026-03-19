library ieee;
use ieee.std_logic_1164.all;

entity mux_4to1_1bit is
    port(
        A   : in  std_logic;
        B   : in  std_logic;
        C   : in  std_logic;
        D   : in  std_logic;
        Sel : in  std_logic_vector(1 downto 0);
        F   : out std_logic
    );
end entity;

architecture rtl of mux_4to1_1bit is
begin
    with Sel select
        F <= A when "00",
             B when "01",
             C when "10",
             D when others;
end architecture;