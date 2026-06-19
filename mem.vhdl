library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memoria is
    generic (
        W        : integer := 8;   -- tamanho de cada dado
        N : integer := 64   -- linhas
    );
    port (
        clk          : in  std_logic;
        ler          : in  std_logic;
        escrever     : in  std_logic;
        endereco     : in  std_logic_vector(5 downto 0);  -- 6 bits → 0..63
        dado_entrada : in  std_logic_vector(W-1 downto 0);
        dado_saida   : out std_logic_vector(W-1 downto 0)
    );
end entity;

architecture arch of memoria is
    type mem_t is array (0 to N-1) of std_logic_vector(W-1 downto 0);
    signal mem : mem_t := (others => (others => '0'));
begin
    -escrita sincrona
    process(clk)
    begin
        if rising_edge(clk) then
            if escrever = '1' then
                mem(to_integer(unsigned(endereco))) <= dado_entrada;
            end if;
        end if;
    end process;

    -- leitura assíncrona
    dado_saida <= mem(to_integer(unsigned(endereco))) when ler = '1'
                  else (others => '0');
end architecture arch;