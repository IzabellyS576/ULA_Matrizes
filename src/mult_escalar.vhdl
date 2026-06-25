library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Calcula a multiplicação entre os elementos de uma matriz e um valor inteiro (um escalar)
-- Nosso circuito será parametrizável para N bits e as entradas e saídas são signed.
entity mult_escalar is
  generic (
    W : positive := 8
  );
  port (
    input_a : in signed(W - 1 downto 0);
    input_k : in signed(W - 1 downto 0);
    product : out signed((2 * W) - 1 downto 0)
  );
end entity;

architecture structure of mult_escalar is
begin

  product <= (input_a * input_k);

end architecture structure;
