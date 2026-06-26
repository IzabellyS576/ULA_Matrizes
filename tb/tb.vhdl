library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ula_pack.all;

entity tb is
end entity tb;

architecture sim of tb is

  --type matrix_t is array (natural range <>, natural range <>) of signed(W-1 downto 0);

  constant W : positive  := 8;
  constant N : positive  := 8;
  signal clk : std_logic := '0';

  signal elementoA   : signed(W - 1 downto 0)       := (others => '0');
  signal elementoB   : signed(W - 1 downto 0)       := (others => '0');
  signal escalar     : signed(W - 1 downto 0)       := (others => '0');
  signal op_code     : std_logic_vector(2 downto 0) := (others => '0');
  signal elementoC   : signed(ula_length(W, N) - 1 downto 0);
  signal address_end : std_logic_vector(ceil_log2(CFG.lines_per_mem) - 1 downto 0);
  signal comandos    : comandos_t := (
  cAc => '0',
  zAc => '0',

  cEnd => '0',
  zEnd => '0',

  cI => '0',
  zI => '0',

  cJ => '0',
  zJ => '0',

  cW => '0',
  zW => '0',

  zMultMatricial => '0',

  cA => '0',
  cB => '0',
  cK => '0',

  zMult     => '0',
  cOp       => '1',
  zRegSaida => '0'
  );
  constant period : time    := 20 ns;
  signal finished : boolean := false; --para o clock generator quando o teste terminar

begin

  --clk <= not clk after period/2;

  clock_gen : process --clock generator respeitando o período definido
  begin
    while not finished loop
      clk <= '0';
      wait for period/2;
      clk <= '1';
      wait for period/2;
    end loop;
    wait;
  end process;

  DUT : entity work.ula_bo(arch)
    entity ula_bo is
      generic (
        CFG              => (
        bits_per_element => 8,
        lines_per_mem    => 64
        )
      );

      port map
      (
        clk         => clk,
        elementoA   => elementoA,
        elementoB   => elementoB,
        escalar     => escalar,
        op_code     => op_code,
        elementoC   => elementoC,
        address_end => address_end
    );

      st : process
        procedure testing(
          a        : in integer;
          b        : in integer;
          expected : in integer
      ) is
      begin
          elementoA    <= (others => '0'); -- fazendo isso para garantir que não tenham valores antigos na entrada
          elementoB    <= (others => '0'); -- fazendo isso para garantir que não tenham valores antigos na entrada
          comandos.cOp <= '1';
          comandos.zMult <= '0';

          comandos.cA <= '1';
          comandos.cB <= '1';
          
          comandos.cI <= '1';
          comandos.cJ <= '1';

          comandos.zI <= '0';
          comandos.zJ <= '0';


          -- wait until rising_edge(clk);

          -- comandos.zI <= '1';
          -- comandos.zJ <= '1';

          elementoA <= to_signed(a, W);
          elementoB <= to_signed(b, W);
          wait until rising_edge(clk);
          for op in 0 to 5 loop
            op_code <= std_logic_vector(to_unsigned(op, 3));
            

            wait until rising_edge(clk);
            
            if op = 0 then
              comandos.cA <= '1';
              comandos.cB <= '1';
              comandos.cK <= '0';
              comandos.cJ <= '1';
              comandos.zJ <= '1';
              comandos.cI <= '0'; --cI deve ficar assim????
              comandos.zMultMatricial <= '0';
              comandos.zRegSaida <= '0';
            elsif op = 1 then
              comandos.cA <= '1';
              comandos.cB <= '1';
              comandos.cK <= '0';
              comandos.cJ <= '1';
              comandos.zJ <= '1';
              comandos.cI <= '0';
              comandos.zMultMatricial <= '0';
              comandos.zRegSaida <= '0';
            elsif op = 2 then
              comandos.cA <= '1';
              comandos.cB <= '0';
              comandos.cK <= '0';
              comandos.cJ <= '1';
              comandos.zJ <= '1';
              comandos.cI <= '0';
              comandos.zMultMatricial <= '0';
              comandos.zRegSaida <= '1';
            elsif op = 3 then
              comandos.cA <= '1';
              comandos.cB <= '0';
              comandos.cK <= '1';
              comandos.cJ <= '1';
              comandos.zJ <= '1';
              comandos.cI <= '0';
              comandos.zMultMatricial <= '0';
              comandos.zRegSaida <= '1';
              comandos.zMult <= '1';
            elsif op = 4 then
              comandos.cA <= '1';
              comandos.cB <= '1';
              comandos.cK <= '0';
              comandos.cJ <= '1';
              comandos.zJ <= '1';
              comandos.cI <= '0';
              comandos.zMultMatricial <= '0';
              comandos.zRegSaida <= '0';
            else then --multiplicacao matricial ADICIONAR
              
            end if;
            wait until rising_edge(clk);

            --sinais do s8 ADICIONAR


            assert (to_integer(elementoC) = to_integer(expected))
                report "FALHA: obtido=" & integer'image(to_integer(elementoC)) &
                ", esperado=" & integer'image(expected)
                severity error;

            assert (to_integer(andress_end) = to_integer(expected_adress)) --FAZER CHECAGEM DO ENDEREÇO FINAL 
            --INCLUIR ADRESS NA INSTANCIACAO DA FUNCAO
                report "FALHA: obtido=" & integer'image(to_integer(andress_end)) &
                ", esperado=" & integer'image(expected_adress)
                severity error;
          end loop;

      end procedure;

    begin
        assert false report "BOT datapath" severity note;
        testing((1, 2, 3), (4, 5, 6), 32); --FAZER CASOS DE TESTE!!!!!

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
        assert false report "EOT datapath" severity note;
        finished <= true; --parar o clock generator
        wait;
    end process;

  end sim;
