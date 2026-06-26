library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_2to1_1b is
  port (
    sel     : in std_logic;
    in_0 : in std_logic;
    in_1 : in std_logic;
    y       : out std_logic
  );
end entity;

architecture rtl of mux_2to1 is

begin
  y <= in_0 when sel = '0' else
    in_1;

end architecture;