library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparator is
    generic (N : positive := 3); 
    port (
        a      : in  unsigned(N downto 0);
        b      : in  unsigned(N downto 0);
        menor  : out std_logic
    );
end entity;

architecture behavior of comparator is
begin
    menor <= '1' when a <= b else '0';
end architecture behavior;