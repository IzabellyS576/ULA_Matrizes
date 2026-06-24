library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ula_pack.all;

--módulo de soma de dois números com sinal, com N bits de entrada e N+1 bits de saída
--para somar uma matriz inteira, os números serão passados indiviualmente, de par em par

entity multiplicacao is
  generic (
    W : positive := 8; -- número de bits das entradas
    N : positive := 8 -- dimensão da matriz
  );
  port (
    clk     : in std_logic;
    input_a : in signed(W - 1 downto 0);
    input_b : in signed(W - 1 downto 0);

    comandos : in comandos_t;

    multi : out signed(ula_length(W, N) - 1 downto 0)

  );
end multiplicacao;
architecture arch of multiplicacao is
  constant tamanho_saida : positive := ula_length(W, N);

  signal multi_elementos                              : signed(2 * W - 1 downto 0);
  signal saida_mux                                    : std_logic_vector(tamanho_saida - 1 downto 0);
  signal multi_elementos2, saida_soma, saida_mux2, ac : signed(tamanho_saida - 1 downto 0);

begin

  multi_elementos  <= resize(input_a, 2 * W) * resize(input_b, 2 * W); -- multiplicação dos dois números de entrada
  multi_elementos2 <= resize(multi_elementos, tamanho_saida); -- resize da multiplicação para o tamanho da saída

  saida_soma <= multi_elementos2 + ac; -- soma da multiplicação com o acumulador

  MUXAC : entity work.mux_2to1(rtl)
    generic map(
      N => tamanho_saida
    )
    port map
    (
      sel     => comandos.zAc, -- sempre seleciona a entrada 0, que é a saída da multiplicação
      input_a => (others => '0'),
      input_b => std_logic_vector(saida_soma), -- entrada 1 do mux é zero
      y       => saida_mux
    );

  saida_mux2 <= signed(saida_mux); -- conversão da saída do mux para signed

  REGAC : entity work.reg_signed(rtl)
    generic map(
      N => tamanho_saida
    )
    port map
    (
      clk    => clk,
      rst    => '0',
      enable => comandos.cAc,
      d      => saida_mux2,
      q      => ac
    );

  multi <= ac; -- saída do módulo é a saída do acumulador

end architecture arch;