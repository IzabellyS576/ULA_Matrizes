library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_soma is
    --testbench não tem portas, pois não vai se conectar a nada, ele é apenas um ambiente de simulação para testar o módulo soma
end entity tb_soma;

architecture sim of tb_soma is

    constant N : positive := 8; --equivalente ao generic N do módulo soma
    constant DELTA : time := 10 ns; --tempo entre um estímulo e outro

    
    signal input_a : signed(N - 1 downto 0) := (others => '0'); --nossas portas vem para ca como signals
    signal input_b : signed(N - 1 downto 0) := (others => '0'); --others => '0' é uma boa prática pro signal não iniciar com null
    signal sum     : signed(N downto 0);
    
    component soma --declaração do componente que vamos testar, equivalente à entidade do módulo soma
        generic(N : positive);
        port(
            input_a : in  signed(N - 1 downto 0);
            input_b : in  signed(N - 1 downto 0);
            sum     : out signed(N downto 0)
        );
    end component;

begin

    
    DUT: soma --DUT = Device Under Test, é uma convenção de nome para a instância do módulo que estamos testando
        generic map(N => N)
        port map(
            input_a => input_a, --porta_do_modulo => sinal_do_testbench
            input_b => input_b,
            sum     => sum
        );

    
    process
        
        procedure aplicar_e_verificar( --procedure é tipo uma função, vai evitar de ter que escrever o mesmo algoritmo para todos os valores do testbench
            a        : in integer; --estão em integer para ficar mais fácil de testar (assim, podemos usar o numero direto, sem ficar convertendo pra signed toda hora em aplicar_e_verificar)
            b        : in integer;
            esperado : in integer
        ) is
        begin
            input_a <= to_signed(a, N);
            input_b <= to_signed(b, N);
            wait for DELTA;

            assert to_integer(sum) = esperado --assert é uma instrução que verifica se uma condição é verdadeira, e reclama se não for.
                report "FALHA: " & integer'image(a) & " + " & integer'image(b) & --integer'image é para escrever o número em string
                       " = " & integer'image(to_integer(sum)) &
                       ", esperado: " & integer'image(esperado)
                severity error;
        end procedure;

    begin
        
        aplicar_e_verificar(0,    0,    0); --porque usamos o procedure, agora basta passar os valores de teste como "parâmetro"
        aplicar_e_verificar(1,    1,    2);
        aplicar_e_verificar(10,   20,   30);

        
        aplicar_e_verificar(127,  127,  254);
        aplicar_e_verificar(127,  1,    128);

        
        aplicar_e_verificar(-1,   -1,   -2);
        aplicar_e_verificar(-128, -128, -256);
        aplicar_e_verificar(-128, 127,  -1);

        
        aplicar_e_verificar(50,  -50,   0);
        aplicar_e_verificar(100, -30,   70);

        
        aplicar_e_verificar(0,   -128,  -128);
        aplicar_e_verificar(0,    127,   127);

        report "Simulação concluída." severity note;
        wait; --IMPORTANTE PARA NÃO FICAR RODANDO O TESTBENCH INFINITAMENTE
    end process;

end architecture sim;