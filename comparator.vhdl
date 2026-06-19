library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparador is
    generic (N : positive := 3); 
    port (
        a      : in  unsigned(N-1 downto 0);
        b      : in  unsigned(N-1 downto 0);
        menor  : out std_logic
    );
end entity;

architecture rtl of comparador is
begin
    menor <= '1' when a < b else '0';
end architecture;