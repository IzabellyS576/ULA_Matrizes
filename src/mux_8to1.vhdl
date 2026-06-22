library ieee;
use ieee.std_logic_1164.all;

entity mux_8to1 is
	generic(N : positive);
	port(
		sel        : in  std_logic_vector(2 downto 0);
		in_0, in_1, in_2, in_3, in_4, in_5, in_6, in_7 : in  signed(N - 1 downto 0);
		y          : out signed(N - 1 downto 0)
	);
end mux_8to1;

architecture behavior of mux_8to1 is
begin
    
    y <= in_0 when (sel="000") else 
         in_1 when (sel="001") else
         in_2 when (sel="010") else
         in_3 when (sel="011") else
         in_4 when (sel="100") else
         in_5 when (sel="101") else
         in_6 when (sel="110") else
         in_7;
    
end architecture behavior;