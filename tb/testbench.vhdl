library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end testbench;

architecture tb of testbench is
    CONSTANT N_BITS : natural := 4;
    signal clk : std_logic := '0';
    signal finished: std_logic := '0';
    signal input_value: std_logic_vector(N_BITS-1 DOWNTO 0);
    signal output_value: std_logic_vector(N_BITS-1 DOWNTO 0);

    CONSTANT period : TIME := 20 ns;
begin

-- Connect DUV
DUV: entity work.registrador(arch)
    generic map(N => N_BITS)
    port map(clk=>clk, D => input_value, Q => output_value);

-- clk <= not clk after period/2;
clk <= not clk after period/2 when finished /= '1' else '0';

st: process
begin
    --! Imprime mensagem de inicio de teste
    assert false report "BOT" severity note;

    -- mais testes aqui aa

    assert false report "EOT" severity note;
    wait;
end process;

end tb;
