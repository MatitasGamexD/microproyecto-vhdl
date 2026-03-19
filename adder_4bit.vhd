library ieee;
use ieee.std_logic_1164.all;

entity adder_4bit is
    port(
        A    : in  std_logic_vector(3 downto 0);
        B    : in  std_logic_vector(3 downto 0);
        S    : in  std_logic; -- 0 = suma, 1 = resta
        Sum  : out std_logic_vector(3 downto 0);
        Cout : out std_logic
    );
end entity;

architecture structural of adder_4bit is

    component full_adder is
        port(
            A    : in  std_logic;
            B    : in  std_logic;
            Cin  : in  std_logic;
            Sum  : out std_logic;
            Cout : out std_logic
        );
    end component;

    signal BX         : std_logic_vector(3 downto 0);
    signal C1, C2, C3, C4 : std_logic;

begin
    BX(0) <= B(0) xor S;
    BX(1) <= B(1) xor S;
    BX(2) <= B(2) xor S;
    BX(3) <= B(3) xor S;

    -- OJO: para resta correcta el Cin del primer full adder debe ser S
    FA0: full_adder port map(A => A(0), B => BX(0), Cin => S,  Sum => Sum(0), Cout => C1);
    FA1: full_adder port map(A => A(1), B => BX(1), Cin => C1, Sum => Sum(1), Cout => C2);
    FA2: full_adder port map(A => A(2), B => BX(2), Cin => C2, Sum => Sum(2), Cout => C3);
    FA3: full_adder port map(A => A(3), B => BX(3), Cin => C3, Sum => Sum(3), Cout => C4);

    Cout <= C4;
end architecture;