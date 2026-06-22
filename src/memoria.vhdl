library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memoria is
        generic (
        CFG : datapath_configuration_t := (
            bits_per_element => 8,
            lines_per_mem => 64
        )
    );
    port (
        clk          : in  std_logic;
        ler          : in  std_logic;
        escrever     : in  std_logic;
        endereco     : in  std_logic_vector(ceil_log2(CFG.lines_per_mem) - 1 downto 0);
        dado_entrada : in  signed(CFG.bits_per_element-1 downto 0);
        dado_saida   : out signed(CFG.bits_per_element-1 downto 0)
    );
end entity;

architecture arch of memoria is
    type mem_t is array (0 to CFG.lines_per_mem-1) of signed(CFG.bits_per_element-1 downto 0);
    signal mem : mem_t := (others => (others => '0'));
begin
    --escrita sincrona
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