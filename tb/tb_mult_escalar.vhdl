library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_mult_escalar is
end tb_mult_escalar;

architecture tb of tb_mult_escalar is
    CONSTANT W_BITS : natural := 8;
    signal in_a: signed(W_BITS-1 DOWNTO 0);
    signal in_k: signed(W_BITS-1 DOWNTO 0);
    signal output_value: signed((2*W_BITS)-1 DOWNTO 0);

    CONSTANT period : TIME := 20 ns;
begin

-- Connect DUV
DUV: entity work.mult_escalar(structure)
    generic map(W => W_BITS)
    port map(input_a => in_a, 
             input_k => in_k, 
             product => output_value);

st: process

    procedure testing(
        a : in integer;
        k : in integer;
        expected : in integer
    ) is
        begin
            in_a <= to_signed(a,W_BITS);
            in_k <= to_signed(k,W_BITS);
            wait for period;
            assert (to_integer(output_value) = expected) report "FALHA: " & integer'image(a) & " * " & integer'image(k) & --integer'image é para escrever o número em string
                                                  " = " & integer'image(to_integer(output_value)) &
                                                  ", esperado: " & integer'image(expected)
            severity error;
    end procedure;

begin
    --! Imprime mensagem de inicio de teste
    assert false report "BOT" severity note;

    testing(0,127,0);
    testing(78,0,0);

    testing(15,7,105);
    testing(127,127,16129);

    testing(-20,40,-800);
    testing(27,-84,-2268);

    testing(-128,-128,16384);
    testing(-12,-9,108);

    --! Imprime mensagem de fim de teste
    assert false report "EOT" severity note;
    wait;
end process;

end tb;
