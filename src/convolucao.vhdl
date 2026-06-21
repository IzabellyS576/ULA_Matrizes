LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;
USE work.ula_pack.all;

ENTITY convolucao IS
    GENERIC(
		W : positive := 8
	);
	PORT (
		in_A     : IN  signed(W-1 DOWNTO 0);
		in_B     : IN  signed(W-1 DOWNTO 0);
		product : OUT signed(2*W-1 DOWNTO 0)
	);
END convolucao;

ARCHITECTURE arch OF convolucao IS
BEGIN
    product <= in_A * in_B;

END ARCHITECTURE arch; -- arch