library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ula_pack.all;

entity tb_bc is
end entity;

architecture sim of tb_bc is

    constant CLK_PERIOD : time := 10 ns;

    signal clk       : std_logic := '0';
    signal rst       : std_logic := '0';
    signal iniciar   : std_logic := '0';
    signal pronto    : std_logic;
    signal ler       : std_logic;
    signal escrever  : std_logic;
    signal op_code   : std_logic_vector(2 downto 0) := (others => '0');

    signal status    : status_t   := (i_menor => '0', j_menor => '0', w_menor => '0');
    signal comandos  : comandos_t;

begin

    uut: entity work.bc 
        port map (
            clk          => clk,
            rst          => rst,
            iniciar      => iniciar,
            pronto       => pronto,
            ler          => ler,
            escrever     => escrever,
            op_code      => op_code,
            status_in    => status,   
            comandos_out => comandos  
        );

    
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    --Processo de Estímulos com Procedures
    stimulus_process : process

        -- Procedure para Resetar o Sistema
        procedure reset_system is
        begin
            rst <= '1';
            iniciar <= '0';
            status <= (i_menor => '0', j_menor => '0', w_menor => '0');
            op_code <= "000";
            wait for CLK_PERIOD * 2;
            rst <= '0';
            wait until falling_edge(clk);
        end procedure;

        -- Procedure para aplicar entradas, verificar saídas e esperar um ciclo de clock
        procedure passo_e_verifica(
            --sinais injetados
            constant st_i_menor : in std_logic;
            constant st_j_menor : in std_logic;
            constant st_w_menor : in std_logic;
            constant op : in std_logic_vector(2 downto 0);

            --sinais esperados
            constant pronto_exp : in std_logic;
            constant ler_exp : in std_logic;
            constant escrever_exp : in std_logic;
            constant cmd_exp : in comandos_t; 
        
            constant msg : in string

        ) is
        begin
            status.i_menor <= st_i_menor;
            status.j_menor <= st_j_menor;
            status.w_menor <= st_w_menor;
            op_code <= op;

            wait until falling_edge(clk); 

            -- Valida os sinais esperados que estão fora do record
            assert (pronto = pronto_exp and ler = ler_exp and escrever = escrever_exp)
                report "FALHA nos sinais globais (pronto/ler/escrever) em: " & msg
                severity error;
                
            -- Valida todos os sinais que estão dentro do record de uma vez só
            assert (comandos = cmd_exp)
                report "FALHA no record de comandos em: " & msg
                severity error;
        end procedure;

        -- Variável auxiliar para preencher o record esperado com todos os sinais = 0 em cada estado
        variable cmd_esperado : comandos_t;

        procedure s0_ate_s8 is (
            constant op_desejado : in std_logic_vector(2 downto 0)
        ) is
        begin
            reset_system;

            -- Em S0 -> S1
            cmd_esperado := (others => '0'); 
            
            passo_e_verifica(
                st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => op_desejado,
                pronto_exp => '1', ler_exp => '0', escrever_exp => '0',
                cmd_exp => cmd_esperado, msg => "Estado S0-S1 - TESTE S0_ATE_S8"
            );

            iniciar <= '1'; 

            --Em S1 -> S2
            cmd_esperado := ( 
                ci => '1', zi => '0', cJ => '1', zJ => '0',
                cEnd => '1', zEnd => '0', cOp => '1',
                others => '0'
            );

            passo_e_verifica(
                st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => op_desejado,
                pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
                cmd_exp => cmd_esperado, msg => "Estado S1-S2 - TESTE S0_ATE_S8"
            );
            iniciar <= '0'; 

            -- Em S2 -> S6
            cmd_esperado := (others => '0')

            passo_e_verifica(
                st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => op_desejado,
                pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
                cmd_exp => cmd_esperado, msg => "Estado S2-S6 - TESTE S0_ATE_S8"
            );

            -- Em S6 -> S7
            cmd_esperado := (
                ci => '1', zi => '0', cJ => '1', zJ => '0',
                others => '0')

            passo_e_verifica(
                st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => op_desejado,
                pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
                cmd_exp => cmd_esperado, msg => "Estado S6-S7 - TESTE S0_ATE_S8"
            );

            -- Em S7 -> S8
            cmd_esperado := (others => '0')

            passo_e_verifica(
                st_i_menor => '1', st_j_menor => '0', st_w_menor => '0', op => op_desejado,
                pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
                cmd_exp => cmd_esperado, msg => "Estado S7-S8 - TESTE S0_ATE_S8"
            );

            -- (PARA EM S8)

        end procedure;

    begin
        -- --- Início dos Testes ---
        --===========================================================================
        --                       INÍCIO TESTE GERAL
        --===========================================================================
        -- Indo de S0 até S8 (Estado das ramificações dos op_codes), depois vai de S8 até S0 novamente
        reset_system; -- Coloca em S0
        
        -- Em S0 -> S1
        cmd_esperado := (others => '0'); --reseta todos os sinais
        
        -- Mantemos iniciar em '0' para continuar em S0 e testamos as saídas
        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => "000",
            pronto_exp => '1', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S0-S1 - TESTE GERAL"
        );

        iniciar <= '1'; -- Força a ida para S1 no próximo ciclo

        --Em S1 -> S2
        --seta os comandos esperados para s1
        cmd_esperado := ( --seta os comandos esperados para s1
            ci => '1', zi => '0', cJ => '1', zJ => '0',
            cEnd => '1', zEnd => '0', cOp => '1',
            others => '0'
        );

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => "000",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S1-S2 - TESTE GERAL"
        );
        iniciar <= '0'; -- Desliga o iniciar para os próximos estados

        -- Em S2 -> S3
        cmd_esperado := (others => '0')

        passo_e_verifica(
            st_i_menor => '1', st_j_menor => '0', st_w_menor => '0', op => "000",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S2-S3 - TESTE GERAL"
        );

        -- Em S3 -> S4
        cmd_esperado := (others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '1', st_w_menor => '0', op => "000",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S3-S4 - TESTE GERAL"
        );

        -- Em S4 -> S3
        cmd_esperado := (
            cEnd => '1', zEnd => '1', cJ => '1', zJ => '1',
            others => '0'
        );

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => "000",
            pronto_exp => '0', ler_exp => '1', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S4-S3 - TESTE GERAL"
        );

        -- Em S3 -> S5
        cmd_esperado := (others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => "000",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S3-S5 - TESTE GERAL"
        );

        -- Em S5 -> S2
        cmd_esperado := (
            ci => '1', zi => '1', cJ => '1', zJ = '0',
            others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => "000",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S5-S2 - TESTE GERAL"
        );

        -- Em S2 -> S6
        cmd_esperado := (others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => "000",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S2-S6 - TESTE GERAL"
        );

        -- Em S6 -> S7
        cmd_esperado := (
            ci => '1', zi => '0', cJ => '1', zJ => '0',
            others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => "000",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S6-S7 - TESTE GERAL"
        );

        -- Em S7 -> S8
        cmd_esperado := (others => '0')

        passo_e_verifica(
            st_i_menor => '1', st_j_menor => '0', st_w_menor => '0', op => "000",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S7-S8 - TESTE GERAL"
        );

        -- Em S8 -> S17
        cmd_esperado := (
            cAc => '1', zAc => '0', cW => '1', zW => '0',
            others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => "000",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S8-S17 - TESTE GERAL"
        );

        -- Em S17 -> S7
        cmd_esperado := (
            ci => '1', zi => '1', cJ => '1', zJ = '0',
            others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => "000",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S17-S7 - TESTE GERAL"
        );

        -- Em S7 -> S18
        cmd_esperado := (others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => "000",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S7-S18 - TESTE GERAL"
        );

        -- Em S18 -> S19
        cmd_esperado := (
            ci => '1', zi => '0', cJ => '1', zJ => '0', cEnd => '1', zEnd => '0',
            others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => "000",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S18-S19 - TESTE GERAL"
        );

        -- Em S19 -> S20
        cmd_esperado := ( others => '0')

        passo_e_verifica(
            st_i_menor => '1', st_j_menor => '0', st_w_menor => '0', op => "000",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S19-S20 - TESTE GERAL"
        );

        -- Em S20 -> S21
        cmd_esperado := ( others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '1', st_w_menor => '0', op => "000",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S20-S21 - TESTE GERAL"
        );

        -- Em S21 -> S20
        cmd_esperado := ( 
            cEnd => '1', zEnd => '1', cJ => '1', zJ => '1',
            others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => "000",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '1',
            cmd_exp => cmd_esperado, msg => "Estado S21-S20 - TESTE GERAL"
        );

        -- Em S20 -> S22
        cmd_esperado := (others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => "000",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S20-S22 - TESTE GERAL"
        );

        -- Em S22 -> S19
        cmd_esperado := (
            ci > '1', zi => '1', cJ => '1', zJ => '0',
            others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => "000",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S22-S19 - TESTE GERAL"
        );

        -- Em S19 -> S0
        cmd_esperado := (others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => "000",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S19-S0 - TESTE GERAL"
        );

        --===========================================================================
        --                       FIM TESTE GERAL
        --===========================================================================

        --===========================================================================
        --                       TESTA ADIÇÃO (op_code = "000")
        --===========================================================================
        -- reseta e vai até s8
        s0_ate_s8(op_desejado => "000");

        --em S8 -> S9
        cmd_esperado := (
            cAc => '1', zAc => '0', cW => '1', zW => '0',
            others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '1', st_w_menor => '0', op => "000",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S8-S9 - TESTE ADIÇÃO"
        );

        --em S9 -> S8
        cmd_esperado := (
            cA => '1', cB => '1', cJ => '1', zJ = '1', zMultMatricial ='0', zRegSaida = '0',
            others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => "000",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S9-S8 - TESTE ADIÇÃO"
        );

        --===========================================================================
        --                       TESTA SUBTRAÇÃO (op_code = "001")
        --===========================================================================
        -- reseta e vai até s8
        s0_ate_s8(op_desejado => "001");

        --em S8 -> S10
        cmd_esperado := (
            cAc => '1', zAc => '0', cW => '1', zW => '0',
            others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '1', st_w_menor => '0', op => "001",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S8-S10 - TESTE SUBTRAÇÃO"
        );

        --em S10 -> S8
        cmd_esperado := (
            cA => '1', cB => '1', cJ => '1', zJ = '1', zMultMatricial ='0', zRegSaida = '0',
            others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => "001",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S10-S8 - TESTE SUBTRAÇÃO"
        );

        --===========================================================================
        --                       TESTA TRANSPOSIÇÃO (op_code = "010")
        --===========================================================================
        -- reseta e vai até s8
        s0_ate_s8(op_desejado => "010");

        --em S8 -> S11
        cmd_esperado := (
            cAc => '1', zAc => '0', cW => '1', zW => '0',
            others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '1', st_w_menor => '0', op => "010",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S8-S11 - TESTE TRANSPOSIÇÃO"
        );

        --em S11 -> S8
        cmd_esperado := (
            cA => '1', cJ => '1', zJ = '1', zMultMatricial ='0', zRegSaida = '1',
            others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => "010",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S11-S8 - TESTE TRANSPOSIÇÃO"
        );

        --===========================================================================
        --                       TESTA MULTIPLICAÇÃO POR ESCALAR (op_code = "011")
        --===========================================================================
        -- reseta e vai até s8
        s0_ate_s8(op_desejado => "011");

        --em S8 -> S12
        cmd_esperado := (
            cAc => '1', zAc => '0', cW => '1', zW => '0',
            others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '1', st_w_menor => '0', op => "011",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S8-S12 - TESTE MULTIPLICAÇÃO POR ESCALAR"
        );

        --em S12 -> S8
        cmd_esperado := (
            cA => '1', cK => '1', cJ => '1', zJ = '1', zMult => '1', zMultMatricial ='0', zRegSaida = '0',
            others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => "011",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S12-S8 - TESTE MULTIPLICAÇÃO POR ESCALAR"
        );

        --===========================================================================
        --                       TESTA CONVOLUÇÃO (op_code = "100")
        --===========================================================================
        -- reseta e vai até s8
        s0_ate_s8(op_desejado => "100");

        --em S8 -> S13
        cmd_esperado := (
            cAc => '1', zAc => '0', cW => '1', zW => '0',
            others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '1', st_w_menor => '0', op => "100",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S8-S13 - TESTE CONVOLUÇÃO"
        );

        --em S13 -> S8
        cmd_esperado := (
            cA => '1', cB => '1', cJ => '1', zJ = '1', zMultMatricial ='0', zRegSaida = '0',
            others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => "100",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S13-S8 - TESTE CONVOLUÇÃO"
        );

        --===========================================================================
        --                       TESTA MULTIPLICAÇÃO MATRICIAL (op_code = "101")
        --===========================================================================
        -- reseta e vai até s8
        s0_ate_s8(op_desejado => "101");

        --em S8 -> S14
        cmd_esperado := (
            cAc => '1', zAc => '0', cW => '1', zW => '0',
            others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '1', st_w_menor => '0', op => "101",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S8-S14 - TESTE MULTIPLICAÇÃO MATRICIAL"
        );

        --em S14 -> S15
        cmd_esperado := (others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '0', st_w_menor => '1', op => "101",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S14-S15 - TESTE MULTIPLICAÇÃO MATRICIAL"
        );

        --em S15 -> S14
        cmd_esperado := (
            cA => '1', cB => '1', cAc => '1', zAc => '1', cW => '1', zW => '1', zMult => '0', zMultMatricial => '1',
            others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => "101",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S15-S14 - TESTE MULTIPLICAÇÃO MATRICIAL"
        );

        --em S14 -> S16
        cmd_esperado := (others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => "101",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S14-S16 - TESTE MULTIPLICAÇÃO MATRICIAL"
        );

        --em S16 -> S8
        cmd_esperado := (
            cJ => '1', zJ => '1', zRegSaida => '0',
            others => '0')

        passo_e_verifica(
            st_i_menor => '0', st_j_menor => '0', st_w_menor => '0', op => "101",
            pronto_exp => '0', ler_exp => '0', escrever_exp => '0',
            cmd_exp => cmd_esperado, msg => "Estado S16-S8 - TESTE MULTIPLICAÇÃO MATRICIAL"
        );

        -- Finaliza a simulação
        report "Simulação do controle concluída com sucesso!";
        wait;
    end process;

end architecture;