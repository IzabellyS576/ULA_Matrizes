library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registrador is
  generic (
    N : positive := 8
  );
  port (
    clk    : in std_logic;
    rst    : in std_logic;
    enable : in std_logic;
    d      : in signed(N - 1 downto 0);
    q      : out signed(N - 1 downto 0)
  );
end entity;

architecture rtl of registrador is
  signal reg : signed(N - 1 downto 0);
begin

  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        reg <= (others => '0');
      elsif enable = '1' then
        reg <= d;
      end if;
    end if;
  end process;

  q <= reg;

end architecture;