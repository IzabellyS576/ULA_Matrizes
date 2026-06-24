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

  signal in_a         : signed(W - 1 downto 0) := (others => '0');
  signal in_b         : signed(W - 1 downto 0) := (others => '0');
  signal output_value : signed(ula_length(W, N) - 1 downto 0);
  signal comandos     : comandos_t := (
  cAc => '0',
  zAc => '1'
  );
  constant period : time := 20 ns;

begin

  clk <= not clk after period/2;
  DUT : entity work.multiplicacao(arch)
    generic map(W => W, N => N)
    port map
    (
      clk      => clk,
      input_a  => in_a,
      input_b  => in_b,
      comandos => comandos,
      multi    => output_value
    );

  st : process
    procedure testing(
      a        : in int_array;
      b        : in int_array;
      expected : in integer
    ) is
    begin
      comandos.cAc <= '1';
      comandos.zAc <= '0';

      wait until rising_edge(clk);

      comandos.zAc <= '1';
      wait until rising_edge(clk);

      for i in a'range loop
        in_a <= to_signed(a(i), W);
        in_b <= to_signed(b(i), W);

        wait until rising_edge(clk);

      end loop;

      wait until rising_edge(clk);

      assert (to_integer(output_value) = expected)
      report "FALHA: obtido=" & integer'image(to_integer(output_value)) &
        ", esperado=" & integer'image(expected)
        severity error;

    end procedure;

  begin
    assert false report "BOT multiplicacao" severity note;
    testing((1, 2, 3), (4, 5, 6), 32);

    testing((0, 0, 0), (1, 2, 3), 0);
    testing((1, 0, 0), (7, 8, 9), 7);
    testing((0, 1, 0), (7, 8, 9), 8);
    testing((0, 0, 1), (7, 8, 9), 9);

    testing((-1, 2, 3), (4, 5, 6), 24);
    testing((-1, -2, -3), (4, 5, 6), -32);
    testing((-1, -2, -3), (-4, -5, -6), 32);
    testing((1, -2, 3), (-4, 5, -6), -32);

    testing((2, -1, 4), (1, 2, 0), 0);

    testing((127, 127, 127), (1, 1, 1), 381);
    testing((-128, -128, -128), (1, 1, 1), -384);

    testing((1, 2, 3), (1, 0, 0), 1);
    testing((1, 2, 3), (0, 1, 0), 2);
    testing((1, 2, 3), (0, 0, 1), 3);
    assert false report "EOT multiplicacao" severity note;
    wait;
  end process;

end sim;
