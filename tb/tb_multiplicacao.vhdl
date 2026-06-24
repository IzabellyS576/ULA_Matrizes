library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ula_pack.all;

entity tb_multiplicacao is
end entity tb_multiplicacao;

architecture sim of tb_multiplicacao is

  type int_array is array (natural range <>) of integer;

  constant W : positive  := 8;
  constant N : positive  := 8;
  signal clk : std_logic := '0';

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
      input_a  => input_a,
      input_b  => input_b,
      comandos => comandos,
      multi    => multi
    );

  st : process
    procedure testing(
      a        : in int_array;
      b        : in int_array;
      expected : in integer
    ) is
    begin
      assert false report "BOT" severity note;

      comandos.cAc <= '1';
      comandos.zAc <= '0';

      wait until rising_edge(clk);

      comandos.zAc <= '1';
      wait until rising_edge(clk);

      for i in a'range loop
        input_a <= to_signed(a(i), W);
        input_b <= to_signed(b(i), W);

        wait for rising_edge(clk);

      end loop;

      assert (to_integer(multi) = expected)
      report "FALHA: obtido=" & integer'image(to_integer(multi)) &
        ", esperado=" & integer.image(expected)
        severity error;

      assert false report "EOT" severity note;
      wait;
    end process;

  end architecture sim;
