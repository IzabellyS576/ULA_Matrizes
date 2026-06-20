library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--módulo de soma de dois números com sinal, com N bits de entrada e N+1 bits de saída
--para somar uma matriz inteira, os números serão passados indiviualmente, de par em par

entity soma is
	generic(
		N : positive := 8 -- número de bits das entradas
	);
	port(
		input_a : in  signed(N - 1 downto 0); -- entrada A com N bits com sinal
		input_b : in  signed(N - 1 downto 0); -- entrada B com N bits com sinal
		sum     : out signed(N downto 0)      -- saída da soma com N+1 bits (para evitar overflow)
	);
end soma;


architecture arch of soma is
    signal r_input_a, r_input_b: signed(N downto 0); 
    
begin
    r_input_a <= resize(input_a, N+1); --precisamos fazer um resize das entradas para N+1 bits, para evitar overflow na soma
    r_input_b <= resize(input_b, N+1);
    sum <= r_input_a + r_input_b;

end architecture arch;