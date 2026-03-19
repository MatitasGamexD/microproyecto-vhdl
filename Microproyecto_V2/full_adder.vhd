library ieee;
use ieee.std_logic_1164.all;

entity full_adder is
    port(
        A    : in  std_logic;
        B    : in  std_logic;
        Cin  : in  std_logic;
        Sum  : out std_logic;
        Cout : out std_logic
    );
end entity;

architecture rtl of full_adder is
begin
    -- Suma de un bit
    Sum  <= A xor B xor Cin;
	 
	 -- Acarreo de la salida
    Cout <= (A and B) or (A and Cin) or (B and Cin);
end architecture;