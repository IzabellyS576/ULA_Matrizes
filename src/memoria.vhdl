library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ula_pack.all;

entity memoria is
        generic (
        CFG : datapath_configuration_t := (
            bits_per_element => 8,
            lines_per_mem => 64
        )
    ); --oioioi
    port (
        clk          : in  std_logic;
        ler          : in  std_logic;
        ler_dado     : in std_logic;
        escrever     : in  std_logic;
        escrever_dado : in std_logic;
        endereco     : in  std_logic_vector(5 downto 0);
        dado_entrada : in  signed(CFG.bits_per_element-1 downto 0);
        dado_saida   : out signed(CFG.bits_per_element-1 downto 0)
    );
end entity memoria;

architecture arch of memoria is
    type mem_t is array (0 to CFG.lines_per_mem-1) of signed(CFG.bits_per_element-1 downto 0);
    signal mem : mem_t := (others => (others => '0'));
    signal s_endereco_escolhido : std_logic_vector(5 downto 0);
begin

    MUX_ADDRESS: entity work.mux_2to1(rtl)
    generic map(N => 6)
    port map (
            sel  => zMem,
            input_a  => endereco_dado, --dado para popular mem
            input_b  => endereco,
            y => s_endereco
    );

    MUX_LER: entity work.mux_2to1(rtl)
    generic map(N => 6)
    port map (
            sel  => zMem,
            input_a  => ler_dado, --sinal ler do TB
            input_b  => ler,
            y => s_ler
    );

    MUX_ESCREVER: entity work.mux_2to1(rtl)
    generic map(N => 6)
    port map (
            sel  => zMem,
            input_a  => escrever_dado, --sinal escrever do TB
            input_b  => escrever,
            y => s_escrever
    );

    --escrita sincrona
    process(clk)
    begin
        if rising_edge(clk) then
            if s_escrever = '1' then
                mem(to_integer(unsigned(s_endereco))) <= dado_entrada;
            end if;
        end if;
    end process;

    -- leitura assíncrona
    dado_saida <= mem(to_integer(unsigned(s_endereco_escolhido))) when s_ler = '1'
                  else (others => '0');
end architecture arch;