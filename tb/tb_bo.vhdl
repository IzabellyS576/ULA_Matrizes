library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ula_pack.all;
---vai pfv
entity tb_bo is
end tb_bo;

architecture sim of tb_bo is

  type matrix_t is array (natural range <>, natural range <>) of signed(W-1 downto 0);

  constant W : positive  := 8;
  constant N : positive  := 8;

  constant A1 : matrix_t(0 to 1, 0 to 2) := (
        (to_signed(1, W), to_signed(2, W), to_signed(3, W)),
        (to_signed(4, W), to_signed(5, W), to_signed(6, W))
    );

    constant B1 : matrix_t(0 to 1, 0 to 2) := (
        (to_signed(4, W), to_signed(5, W), to_signed(6, W)),
        (to_signed(7, W), to_signed(8, W), to_signed(9, W))
    );

  
  signal clk : std_logic := '0';

  signal elementoA   : signed(W - 1 downto 0)       := (others => '0');
  signal elementoB   : signed(W - 1 downto 0)       := (others => '0');
  signal escalar     : signed(W - 1 downto 0)       := (others => '0');
  signal op_code     : std_logic_vector(2 downto 0) := (others => '0');
  signal elementoC   : signed(ula_length(W, N) - 1 downto 0);
  signal adress_end : std_logic_vector(ceil_log2(CFG.lines_per_mem) - 1 downto 0);
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
  signal status: status_t;
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
      generic map(
        CFG              => (
        bits_per_element => 8,
        lines_per_mem    => 64
        )
      )

      port map
      (
        clk         => clk,
        elementoA   => elementoA,
        elementoB   => elementoB,
        escalar     => escalar,
        op_code     => op_code,
        elementoC   => elementoC,
        address_end => address_end,
        rst => rst, 
        status => status,
        comandos => comandos
    );

      st : process
        procedure testing(
          a        : in matrix_t;
          b        : in matrix_t;
          op : in integer;
          expected : in integer;
          expected_adress: in integer
          
      ) is
      begin
          --elementoA    <= (others => (others => (others => '0'))); -- fazendo isso para garantir que não tenham valores antigos na entrada
          --elementoB    <= (others => (others => (others => '0'))); -- fazendo isso para garantir que não tenham valores antigos na entrada
          elementoA <= (others => '0'); 
          elementoB <= (others => '0'); 
          comandos.cOp <= '1';
          comandos.zEnd <= '0';
          comandos.cEnd <= '1';
          comandos.zMult <= '0';

          comandos.cA <= '1';
          comandos.cB <= '1';
          
          comandos.cI <= '1';
          comandos.cJ <= '1';

          


          -- wait until rising_edge(clk);

          -- comandos.zI <= '1';
          -- comandos.zJ <= '1';

          for i in a'range(1) loop
            for j in a'range(2) loop
              elementoA <= a(i,j);
              elementoB <= b(i,j);

              comandos.zI <= '0';
              comandos.zJ <= '0';
              comandos.zEnd <= '1';
              wait until rising_edge(clk);
            end loop;
          end loop;
          
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
            elsif op = 5 then --multiplicacao matricial ADICIONAR
              comandos.zMultMatricial <= '0';
              comandos.cA <= '1';
              comandos.cB <= '1';
              comandos.cK <= '0';
              comandos.zMult <= '1';

              comandos.zAc <= '0'; --zera ac no inicio da multiplicacao matricial
              comandos.cAc <= '1';
              wait until rising_edge(clk);
              for i in a'range(1) loop
                for j in a'range(2) loop
                  comandos.cJ <= '0';
                  comandos.zAc <= '1';
                  wait until rising_edge(clk);
                end loop;
                  comandos.zAc <= '0';
                  comandos.cJ <= '1';
                  wait until rising_edge(clk);
              end loop;
            else --sem op
              
            end if;
            wait until rising_edge(clk);

            --sinais do s8 ADICIONAR


            assert (to_integer(elementoC) = expected)
                report "FALHA: obtido=" & integer'image(to_integer(elementoC)) &
                ", esperado=" & integer'image(expected)
                severity error;

            assert (to_integer(unsigned(andress_end)) = expected_adress) --FAZER CHECAGEM DO ENDEREÇO FINAL 
            --INCLUIR ADRESS NA INSTANCIACAO DA FUNCAO
                report "FALHA: obtido=" & integer'image(to_integer(andress_end)) &
                ", esperado=" & integer'image(expected_adress) 
                severity error;
          

      end process;

    begin
        assert false report "BOT datapath" severity note;
        testing(A1, B1, 1, 5, 2);
        
        assert false report "EOT datapath" severity note;
        finished <= true; --parar o clock generator
        wait;
    end process;

  end sim;
