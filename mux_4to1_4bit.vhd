library ieee;
use ieee.std_logic_1164.all;

entity mux_4to1_4bit is
    port(
        A   : in  std_logic_vector(3 downto 0);
        B   : in  std_logic_vector(3 downto 0);
        C   : in  std_logic_vector(3 downto 0);
        D   : in  std_logic_vector(3 downto 0);
        Sel : in  std_logic_vector(1 downto 0);
        F   : out std_logic_vector(3 downto 0)
    );
end entity;

architecture structural of mux_4to1_4bit is

    component mux_4to1_1bit is
        port(
            A   : in  std_logic;
            B   : in  std_logic;
            C   : in  std_logic;
            D   : in  std_logic;
            Sel : in  std_logic_vector(1 downto 0);
            F   : out std_logic
        );
    end component;

begin
    M0: mux_4to1_1bit port map(A => A(0), B => B(0), C => C(0), D => D(0), Sel => Sel, F => F(0));
    M1: mux_4to1_1bit port map(A => A(1), B => B(1), C => C(1), D => D(1), Sel => Sel, F => F(1));
    M2: mux_4to1_1bit port map(A => A(2), B => B(2), C => C(2), D => D(2), Sel => Sel, F => F(2));
    M3: mux_4to1_1bit port map(A => A(3), B => B(3), C => C(3), D => D(3), Sel => Sel, F => F(3));
end architecture;