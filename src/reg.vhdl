library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registrador is
	generic(
		largura : integer := 8
	);
	port(
        clk : in std_logic;
        rst : in std_logic;
        carrega : in std_logic; -- recebe o comando do registrador respectivo na instanciação
        entrada : in std_logic_vector(largura-1 downto 0);
        saida : out std_logic_vector(largura-1 downto 0)
    );
end registrador

architecture rtl_reg of registrador is
begin
    process(clk, rst)
    begin
        if rst = '1' then
            saida <= (others => '0');

        elsif rising_edge(clk) then
            if carrega = '1' then
                saida <= entrada;
            end if;

        end if;
    end process;
end rtl_reg;