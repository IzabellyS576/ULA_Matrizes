library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_2to1 is
  generic (
    N : positive := 8
  );
  port (
    sel     : in std_logic;
    input_a : in std_logic_vector(N - 1 downto 0);
    input_b : in std_logic_vector(N - 1 downto 0);
    y       : out std_logic_vector(N - 1 downto 0)
  );
end entity;

architecture rtl of mux_2to1 is

begin
  y <= input_a when sel = '0' else
    input_b;

end architecture;