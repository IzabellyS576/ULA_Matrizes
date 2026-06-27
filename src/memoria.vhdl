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
    );
    port (
        clk          : in  std_logic;
        ler          : in  std_logic;
        ler_dado     : in std_logic;
        escrever     : in  std_logic;
        escrever_dado : in std_logic;
        endereco     : in  std_logic_vector(ceil_log2(CFG.lines_per_mem)-1 downto 0);
        endereco_dado : in std_logic_vector(ceil_log2(CFG.lines_per_mem)-1 downto 0);
        dado_entrada : in  signed(CFG.bits_per_element-1 downto 0);
        dado_saida   : out signed(CFG.bits_per_element-1 downto 0);
        comandos: in comandos_t
    );
end entity memoria;

architecture arch of memoria is
    type mem_t is array (0 to CFG.lines_per_mem-1) of signed(CFG.bits_per_element-1 downto 0);
    signal mem : mem_t := (others => (others => '0'));
    signal s_endereco_escolhido : std_logic_vector(ceil_log2(CFG.lines_per_mem)-1 downto 0);
    signal s_ler : std_logic;
    signal s_escrever : std_logic;
begin

    MUX_ADDRESS: entity work.mux_2to1(rtl)
    generic map(N => ceil_log2(CFG.lines_per_mem))
    port map (
            sel  => comandos.zMem,
            in_0  => endereco_dado, --dado para popular mem
            in_1  => endereco,
            y => s_endereco_escolhido
    );

    MUX_LER: entity work.mux_2to1_1b(rtl)
    port map (
            sel  => comandos.zMem,
            in_0  => ler_dado, --sinal ler do TB
            in_1  => ler,
            y => s_ler
    );

    MUX_ESCREVER: entity work.mux_2to1_1b(rtl)
    port map (
            sel  => comandos.zMem,
            in_0  => escrever_dado, --sinal escrever do TB
            in_1  => escrever,
            y => s_escrever
    );

    --escrita sincrona
    process(clk)
    begin
        if rising_edge(clk) then
            if s_escrever = '1' then
                mem(to_integer(unsigned(s_endereco_escolhido))) <= dado_entrada;
            end if;
        end if;
    end process;

    -- leitura assíncrona
    dado_saida <= mem(to_integer(unsigned(s_endereco_escolhido))) when s_ler = '1'
                  else (others => '0');
end architecture arch;