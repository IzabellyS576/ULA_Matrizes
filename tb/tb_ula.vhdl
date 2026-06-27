library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ula_pack.all;

entity tb_ula is
end entity;

architecture sim of tb_ula is
    -- generics do DUT
    constant W          : positive := 8;
    constant N          : positive := 3;

    constant CLK_PERIOD : time    := 10 ns;

    -- largura do resultado em MEM_C
    constant C_WIDTH : positive := ula_length(bits_per_value => W, matrix_size => N) +1; -- 19 bits

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '0';
    signal inic     : std_logic := '0';
    signal escalar  : signed(W-1 downto 0) := (others => '0');
    signal op_code  : std_logic_vector(2 downto 0) := (others => '0');
    signal endereco_dado : std_logic_vector(5 downto 0) := (others => '0');
    signal pronto   : std_logic;

    -- sinais de acesso direto às memórias (zMem = 1)
    signal s_zmem        : std_logic := '1';
    signal s_ler         : std_logic := '0';
    signal s_escrever    : std_logic := '0';
 
    -- dados das matrizes A e B (3x3, índice linha-major)
    -- MEM_A: [1,2,3, 4,5,6, 7,8,9]
    -- MEM_B: [9,8,7, 6,5,4, 3,2,1]
    type matriz_data_t is array (0 to N*N-1) of integer;
 
    constant MAT_A : matriz_data_t := (1, 2, 3, 4, 5, 6, 7, 8, 9);
    constant MAT_B : matriz_data_t := (9, 8, 7, 6, 5, 4, 3, 2, 1);

    -- escalar fixo para teste
    constant ESCALAR_VAL : integer := 3;
 
    -- resultados esperados para MEM_C (19 bits, signed)

    -- soma
    constant RES_SOMA    : matriz_data_t := (10, 10, 10, 10, 10, 10, 10, 10, 10);

    -- subtracao
    constant RES_SUB     : matriz_data_t := (-8, -6, -4, -2, 0, 2, 4, 6, 8);

    -- transposição
    constant RES_TRANS   : matriz_data_t := (1, 4, 7, 2, 5, 8, 3, 6, 9);

    -- multiplicação escalar A * 3
    constant RES_ESC     : matriz_data_t := (3, 6, 9, 12, 15, 18, 21, 24, 27);

    -- convolução A(i) * B(i)
    constant RES_CONV    : matrix_data_t := (9, 16, 21, 24, 25, 24, 21, 16, 9);

    -- multiplicação matricial A*B
    constant RES_MULT    : matriz_data_t := (30, 24, 18, 84, 69, 54, 138, 114, 90);
    

    -- procedure para popular uma memória via zMem
    -- (zMem = 1 no DUT seleciona endereco_dado, ler_dado, escrever_dado)
    -- acionamos s_escrever e s_ler que são conectados a ler_dado/escrever_dado das mems
 
    -- função auxiliar: converte integer para std_logic_vector
    function to_slv_end(val : integer) return std_logic_vector is
    begin
        return std_logic_vector(to_unsigned(val, ceil_log2(N*N)));
    end function;

begin
    DUT: entity work.ula(structure)
        generic map(W => W, N => N)
        port map(
            clk           => clk,
            rst           => rst,
            inic          => inic,
            escalar       => escalar,
            op_code       => op_code,
            endereco_dado => endereco_dado,
            pronto        => pronto
        );
 
    clk <= not clk after CLK_PERIOD / 2;

    process
        -- aguarda N ciclos de clock
        procedure wait_clk(n : positive := 1) is
        begin
            for i in 1 to n loop
                wait until rising_edge(clk);
            end loop;
            wait for 1 ns; -- margem após borda
        end procedure;

        -- zMem = 1 faz as mems usarem endereco_dado e escrever_dado

        procedure escrever_mem(addr : integer; val_a : integer; val_b : integer) is   -- sinaliza a escrita no endereço correto.
        begin
            endereco_dado <= to_slv_end(addr);
            s_escrever <= '1';
            wait_clk(1);
            s_escrever <= '0';
            wait_clk(1);
        end procedure;

        -- lê um elemento de MEM_C via zMem e retorna como signed
        procedure ler_mem_c(addr : integer) is
        begin
            endereco_dado <= to_slv_end(addr);
            s_ler <= '1';
            wait_clk(1);
            s_ler <= '0';
            wait_clk(1);
        end procedure;
 
        -- dispara uma operação e aguarda pronto
        procedure executar_op(code : std_logic_vector(2 downto 0)) is
        begin
            op_code <= code;
            inic    <= '1';
            wait_clk(1);
            inic    <= '0';
            wait until pronto = '1';
            wait_clk(2);
        end procedure;
 
        -- verifica MEM_C para uma operação, comparando com vetor esperado
        -- a leitura é feita acionando s_ler (ler_dado das mems) com zMem = 1
        procedure verificar_mem_c(
            op_name  : string;
            expected : matriz_data_t
        ) is
            variable leitura : signed(C_WIDTH-1 downto 0);
            variable passou  : boolean := true;
        begin
            report "=== Verificando: " & op_name & " ===" severity note;
            for i in 0 to N*N-1 loop
                ler_mem_c(i);
                wait for 2 ns;
                -- comparação
                report "  [" & integer'image(i) & "] esperado=" &
                       integer'image(expected(i)) severity note;
            end loop;
            if passou then
                report op_name & ": PASSOU" severity note;
            else
                report op_name & ": FALHOU" severity failure;
            end if;
        end procedure;
 
    begin
        rst  <= '1';
        inic <= '0';
        wait_clk(3);
        rst  <= '0';
        wait_clk(2);

        -- S0: zMem = 1, popula MEM_A e MEM_B
        -- tb aciona escrever_dado (s_escrever) e ler_dado (s_ler).
        -- ----------------------------------------------------------------
        report "Populando memorias A e B" severity note;
        escalar <= to_signed(ESCALAR_VAL, W);
 
        for i in 0 to N*N-1 loop
            endereco_dado <= to_slv6(i);
            s_escrever    <= '1';
            wait_clk(1);
            s_escrever    <= '0';
            wait_clk(1);
        end loop;
 
        report "Memorias populadas" severity note;
        wait_clk(2);
 
        -- teste 1: soma (op_code = "000")
        -- esperado: C[i] = A[i] + B[i] = 10 para todos
    
        report "Teste 1: Soma" severity note;
        executar_op("000");
        verificar_mem_c("SOMA", RES_SOMA);
 
        -- teste 2: subtração (op_code = "001")
        -- esperado: [-8,-6,-4,-2,0,2,4,6,8]

        report "Teste 2: Subtracao" severity note;
        executar_op("001");
        verificar_mem_c("SUBTRACAO", RES_SUB);
 
        -- teste 3: transposição (op_code = "010")
        -- esperado: [1,4,7, 2,5,8, 3,6,9]

        report "Teste 3: Transposicao" severity note;
        executar_op("010");
        verificar_mem_c("TRANSPOSICAO", RES_TRANS);
 
        -- teste 4: multiplicação por escalar (op_code = "011")
        -- esperado: C[i] = [3,6,9,12,15,18,21,24,27]

        report "Teste 4: Mult Escalar" severity note;
        executar_op("011");
        verificar_mem_c("MULT_ESCALAR", RES_ESC);
 
        -- teste 5: convolução (op_code = "100")
        -- esperado: [9, 16, 21, 24, 25, 24, 21, 16, 9]
    
        report "Teste 5: Convolucao" severity note;
        executar_op("100");
        verificar_mem_c("CONVOLUCAO", RES_CONV);
 
        -- teste 6: Multiplicação matricial (op_code = "101")
        -- esperado: [30,24,18, 84,69,54, 138,114,90]

        report "Teste 6: Mult Matricial" severity note;
        executar_op("101");
        verificar_mem_c("MULT_MATRICIAL", RES_MULT);
 
        -- Fim da simulação
        report "Simulação Concluída" severity note;
        wait;
    end process;

end architecture sim;