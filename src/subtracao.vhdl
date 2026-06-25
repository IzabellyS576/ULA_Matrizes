library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Módulo de subtração de dois números com sinal
entity subtracao is
    generic(
        N : positive := 8 -- número de bits das entradas
    );
    port(
        input_a : in  signed(N - 1 downto 0);
        input_b : in  signed(N - 1 downto 0);
        diff    : out signed(N downto 0) -- saída com N+1 bits
    );
end subtracao;

architecture arch of subtracao is
    signal r_input_a, r_input_b: signed(N downto 0); 
begin
    -- Ajuste para N+1 para garantir a precisão do sinal na subtração
    r_input_a <= resize(input_a, N+1);
    r_input_b <= resize(input_b, N+1);
    diff      <= r_input_a - r_input_b;

end architecture arch;