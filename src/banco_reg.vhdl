
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity banco_reg is
    generic(
        largura : integer := 8;  -- quantos bits cada célula guarda
        tam_end : integer := 3   -- quantos bits tem cada endereço
    );
    port(
        clk       : in  std_logic;
        reset     : in std_logic;
        escrever  : in  std_logic;
        end_i     : in  std_logic_vector(tam_end-1 downto 0);
        end_j     : in  std_logic_vector(tam_end-1 downto 0);
        d_escrito : in  std_logic_vector(largura-1 downto 0);
        d_lido    : out std_logic_vector(largura-1 downto 0)
    );
end banco_reg;

architecture rtl of banco_reg is
    type t_linha is array (0 to 2**tam_end-1) of std_logic_vector(largura-1 downto 0); -- linha da matriz
    type t_matriz is array (0 to 2**tam_end -1) of t_linha;                            -- array de linhas

    signal regs : t_matriz;   -- representa todos os registradores

    signal linha_i, coluna_j : integer range 0 to 2**tam_end - 1;  -- Sinais auxiliares do tipo integer para usar como índice de array

begin
    linha_i <= integer(unsigned(end_i));
    coluna_j <= integer(unsigned(end_j));

    process(clk, reset)
    begin
        if reset = '1' then
            regs <= (others => (others => (others => '0')));   -- Três others porque regs é uma estrutura em três níveis (matriz → linha → bit)
        elsif rising_edge(clk) then
            if escrever = '1' then
                regs(linha_i)(coluna_j) <= d_escrito;
            end if;
        end if;
    end process;

    d_lido <= regs(linha_i)(coluna_j);

end rtl;