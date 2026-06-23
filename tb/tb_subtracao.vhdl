library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_subtracao is
end entity tb_subtracao;

architecture sim of tb_subtracao is

    constant N : positive := 8;
    constant DELTA : time := 10 ns;

    signal input_a : signed(N - 1 downto 0) := (others => '0');
    signal input_b : signed(N - 1 downto 0) := (others => '0');
    signal diff    : signed(N downto 0);
    
    component subtracao
        generic(N : positive);
        port(
            input_a : in  signed(N - 1 downto 0);
            input_b : in  signed(N - 1 downto 0);
            diff    : out signed(N downto 0)
        );
    end component;

begin

    DUT: subtracao
        generic map(N => N)
        port map(
            input_a => input_a,
            input_b => input_b,
            diff    => diff
        );

    process
        procedure aplicar_e_verificar(
            a        : in integer;
            b        : in integer;
            esperado : in integer
        ) is
        begin
            input_a <= to_signed(a, N);
            input_b <= to_signed(b, N);
            wait for DELTA;

            assert to_integer(diff) = esperado
                report "FALHA: " & integer'image(a) & " - " & integer'image(b) &
                       " = " & integer'image(to_integer(diff)) &
                       ", esperado: " & integer'image(esperado)
                severity error;
        end procedure;

    begin
        -- Casos de teste
        aplicar_e_verificar(0,    0,    0);
        aplicar_e_verificar(10,   5,    5);
        aplicar_e_verificar(5,    10,  -5);
        
        -- Casos de limites (comportamento de sinal)
        aplicar_e_verificar(127,  1,    126);
        aplicar_e_verificar(-128, 1,   -129); -- Teste de underflow mantido pelo N+1
        aplicar_e_verificar(-1,  -1,    0);
        aplicar_e_verificar(-128, -128, 0);
        
        report "Simulação de subtração concluída." severity note;
        wait;
    end process;

end architecture sim;