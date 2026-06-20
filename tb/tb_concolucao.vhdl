library IEEE;
use IEEE.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
 
entity tb_concolucao is
end tb_concolucao; 

architecture tb of tb_concolucao is
--entradas e saída são elementos das matrizes signed
signal inputA: signed(7 DOWNTO 0);
signal inputB: signed(7 DOWNTO 0);
signal output: signed(18 downto 0);

CONSTANT passo : TIME := 20 ns;	 

begin

  -- Connect DUV
  DUV: entity work.convolucao 
    port map(inputA, inputB, output); --talvez erro aqui??

  process
  begin
    inputA <= to_signed(0, inputA'length); 
    inputB <= to_signed(0, inputB'length); 
    wait for passo;
    assert(output = to_signed(0, output'length)) 
    report "Fail 0" severity error;

    inputA <= to_signed(0, inputA'length); 
    inputB <= to_signed(50, inputB'length); 
    wait for passo;
    assert(output = to_signed(0, output'length)) 
    report "Fail 1" severity error;

    inputA <= to_signed(0, inputA'length); 
    inputB <= to_signed(-50, inputB'length); 
    wait for passo;
    assert(output = to_signed(0, output'length)) 
    report "Fail 2" severity error;

    inputA <= to_signed(1, inputA'length); 
    inputB <= to_signed(1, inputB'length); 
    wait for passo;
    assert(output = to_signed(1, output'length)) 
    report "Fail 3" severity error;

    inputA <= to_signed(-1, inputA'length); 
    inputB <= to_signed(-1, inputB'length); 
    wait for passo;
    assert(output = to_signed(1, output'length)) 
    report "Fail 4" severity error;

    inputA <= to_signed(-1, inputA'length); 
    inputB <= to_signed(1, inputB'length); 
    wait for passo;
    assert(output = to_signed(-1, output'length)) 
    report "Fail 5" severity error;

    inputA <= to_signed(1, inputA'length); 
    inputB <= to_signed(-1, inputB'length); 
    wait for passo;
    assert(output = to_signed(-1, output'length)) 
    report "Fail 6" severity error;

    inputA <= to_signed(127, inputA'length); 
    inputB <= to_signed(127, inputB'length); 
    wait for passo;
    assert(output = to_signed(16129, output'length)) 
    report "Fail 7" severity error;

    inputA <= to_signed(-128, inputA'length); 
    inputB <= to_signed(-128, inputB'length); 
    wait for passo;
    assert(output = to_signed(16384, output'length)) 
    report "Fail 8" severity error;

    inputA <= to_signed(-128, inputA'length); 
    inputB <= to_signed(127, inputB'length); 
    wait for passo;
    assert(output = to_signed(-16256, output'length)) 
    report "Fail 9" severity error;

    inputA <= to_signed(127, inputA'length); 
    inputB <= to_signed(-128, inputB'length); 
    wait for passo;
    assert(output = to_signed(-16256, output'length)) 
    report "Fail 10" severity error;

    inputA <= to_signed(-128, inputA'length); 
    inputB <= to_signed(1, inputB'length); 
    wait for passo;
    assert(output = to_signed(-128, output'length)) 
    report "Fail 11" severity error;

    inputA <= to_signed(-128, inputA'length); 
    inputB <= to_signed(0, inputB'length); 
    wait for passo;
    assert(output = to_signed(0, output'length)) 
    report "Fail 12" severity error;

    inputA <= to_signed(64, inputA'length); 
    inputB <= to_signed(-64, inputB'length); 
    wait for passo;
    assert(output = to_signed(-4096, output'length)) 
    report "Fail 13" severity error;

    inputA <= to_signed(-64, inputA'length); 
    inputB <= to_signed(-64, inputB'length); 
    wait for passo;
    assert(output = to_signed(4096, output'length)) 
    report "Fail 14" severity error;

    inputA <= to_signed(100, inputA'length); 
    inputB <= to_signed(100, inputB'length); 
    wait for passo;
    assert(output = to_signed(10000, output'length)) 
    report "Fail 15" severity error;

    inputA <= to_signed(-100, inputA'length); 
    inputB <= to_signed(100, inputB'length); 
    wait for passo;
    assert(output = to_signed(-10000, output'length)) 
    report "Fail 16" severity error;

    wait for passo;
    assert false report "Test done." severity note;
    wait;
  end process;
end tb;
