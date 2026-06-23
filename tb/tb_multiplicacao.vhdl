library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ula_pack.all;

entity tb_multiplicacao is
end entity tb_multiplicacao;

architecture sim of tb_multiplicacao is

  type int_array is array (natural range <>) of integer;

  constant A_tests : int_array := (4, 0, 2, -2, -2, 5, -5, 3);
  constant B_tests : int_array := (2, 1, 3, 3, -3, 4, -7, 2);
  constant E_tests : int_array := (8, 8, 14, 8, 14, 34, 69, 75);
  constant W       : positive  := 8;
  constant N       : positive  := 8;
  signal clk       : std_logic := '0';
  signal rst       : std_logic := '1';

  signal input_a  : signed(W - 1 downto 0);
  signal input_b  : signed(W - 1 downto 0);
  signal multi    : signed(ula_length(W, N) - 1 downto 0);
  signal comandos : comandos_t;
  constant period : time := 20 ns;

begin

  clk <= not clk after period/2;
  DUT : entity work.multiplicacao
    generic map(W => W, N => N)
    port map
    (
      clk      => clk,
      rst      => rst,
      input_a  => input_a,
      input_b  => input_b,
      comandos => comandos,
      multi    => multi
    );

  st : process
    -- procedure testing(
    --   a        : in integer; --vetor como integer assim dá?
    --   k        : in integer;
    --   expected : in integer
    -- ) is
  begin
    assert false report "BOT" severity note;

    rst <= '1';
    wait for rising_edge(clk);
    rst <= '0';
    wait for rising_edge(clk);

    comandos.zAc <= '0';
    comandos.cAc <= '1';

    wait until rising_edge(clk);

    comandos.zAc <= '1';
    wait until rising_edge(clk);
    for i in A_tests'range loop
      input_a <= to_signed(A_tests(i), W);
      input_b <= to_signed(B_tests(i), W);

      wait for rising_edge(clk);

      assert (to_integer(multi) = E_tests(i))
      report "FALHA: obtido=" & integer'image(to_integer(multi)) &
        ", esperado=" & integer'image(E_tests(i))
        severity error;

    end loop;

    assert false report "EOT" severity note;
    wait;
  end process;

end architecture sim;
