-- RESPONSABILIDADE: verificar integração e controle

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ula_pack.all;

entity tb_ula is
end entity;

architecture sim of tb_ula is
    constant CLK_PERIOD : time    := 10 ns;
    constant W          : positive := 8;
    constant N          : positive := 3;

    signal clk     : std_logic := '0';
    signal rst     : std_logic := '0';
    signal inic    : std_logic := '0';
    signal escalar : signed(W-1 downto 0) := (others => '0');
    signal op_code : std_logic_vector(2 downto 0) := (others => '0');
    signal pronto  : std_logic;

    signal finished : boolean := false; -- para parar o gerador de clock no fim da simulação

begin

    UUT: entity work.ula(structure)  -- Conecta cada sinal declarado acima à porta correspondente
        generic map(W => W, N => N)
        port map(
            clk     => clk,
            rst     => rst,
            inic    => inic,
            escalar => escalar,
            op_code => op_code,
            pronto  => pronto
        );

    clk_proc: process    -- Gerador de clock, fica alternando 0/1 até sim_done virar true
    begin
        while not sim_done loop
            clk <= '0'; wait for CLK_PERIOD / 2;
            clk <= '1'; wait for CLK_PERIOD / 2;
        end loop;
        wait;            -- para o processo após o fim da simulação
    end process;

    stim_proc: process

        procedure executar_op(
            constant op  : in std_logic_vector(2 downto 0);
            constant esc : in signed(W-1 downto 0);
            constant msg : in string
        ) is
        begin
            op_code <= op;
            escalar <= esc;

         -- Pulsa inic por exatamente 1 ciclo de clock
            wait until rising_edge(clk);    
            inic <= '1';
            wait until rising_edge(clk);
            inic <= '0';


            -- Aguarda pronto subir (a FSM terminou a operação)
            -- Timeout de 10000 ciclos evita loop infinito se algo travar
            for i in 0 to 9999 loop
                if pronto = '1' then exit; end if;
                wait until rising_edge(clk);
            end loop;

            assert pronto = '1'
                report "TIMEOUT na operação: " & msg
                severity failure;

            report "OK: " & msg;
        end procedure;

    begin
        rst <= '1';
        wait for CLK_PERIOD * 2;   --segura o reset por 2 cliclos
        rst <= '0';
        wait until rising_edge(clk);

        assert pronto = '0'
            report "ERRO: pronto deveria ser 0 após reset"
            severity error;

        -- Testa cada op_code
        executar_op("000", to_signed(0, W), "Adição de matrizes");
        wait for CLK_PERIOD * 2;

        executar_op("001", to_signed(0, W), "Subtração de matrizes");
        wait for CLK_PERIOD * 2;

        executar_op("010", to_signed(0, W), "Transposição");
        wait for CLK_PERIOD * 2;

        executar_op("011", to_signed(3, W), "Multiplicação por escalar");
        wait for CLK_PERIOD * 2;

        executar_op("100", to_signed(0, W), "Convolução");
        wait for CLK_PERIOD * 2;

        executar_op("101", to_signed(0, W), "Multiplicação matricial");
        wait for CLK_PERIOD * 2;

        -- Testa reset no meio de uma operação
        op_code <= "101";
        wait until rising_edge(clk);
        inic <= '1';
        wait until rising_edge(clk);
        inic <= '0';
        wait for CLK_PERIOD * 3;

        rst <= '1';
        wait for CLK_PERIOD * 2;
        rst <= '0';
        wait until rising_edge(clk);

        assert pronto = '0'
            report "ERRO: pronto deveria ser 0 após reset no meio da operação"
            severity error;
        report "OK: Reset no meio da operação";

         --  Verifica que a ULA retoma normalmente após o reset
        executar_op("000", to_signed(0, W), "Operação após reset");


    -- Fim da simulação
        report "Todos os testes do toplevel concluídos!";
        sim_done <= true;       -- sinaliza o gerador de clock para parar
        wait;
    end process;

end architecture sim;