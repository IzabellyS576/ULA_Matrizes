library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_convolucao is
end ;

architecture sim of tb_convolucao is
    CONSTANT W_BITS : natural := 8;
    signal input_a: signed(W_BITS-1 DOWNTO 0);
    signal input_b: signed(W_BITS-1 DOWNTO 0);
    signal output_value: signed((2*W_BITS)-1 DOWNTO 0);

    CONSTANT period : TIME := 20 ns;
begin

-- Connect DUV
DUV: entity work.convolucao(arch)
    generic map(W => W_BITS)
    port map(input_a => input_a, 
             input_b => input_b, 
             product => output_value);

st: process

    procedure testing(
        a : in integer;
        b : in integer;
        expected : in integer
    ) is
        begin
            input_a <= to_signed(a, W_BITS);
            input_b <= to_signed(b, W_BITS);
            wait for period;
            assert (to_integer(output_value) = expected) report "FALHA: " & integer'image(a) & " * " & integer'image(b) &
              " = " & integer'image(to_integer(output_value)) &
              ", esperado: " & integer'image(expected)
            severity error;
    end procedure;

begin
    assert false report "Iniciando Simulação" severity note;

    testing(0,0,0);
    testing(0,50,0);
    testing(0,-50,0);
    testing(1,1,1);
    testing(-1,-1,1);
    testing(-1,1,-1);
    testing(1,-1,-1);
    testing(127,127,16129);
    testing(-128,-128,16384);
    testing(-128,127,-16256);
    testing(127,-128,-16256);
    testing(-128,1,-128);
    testing(-128,0,0);
    testing(64,-64,-4096);
    testing(100,100,10000);
    testing(-100,100,-10000);


    --! Imprime mensagem de fim de teste
     report "Simulação concluída." severity note;
    wait;
end process;

end sim;
