library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ula_pack.all;

entity ula is
	generic(
        W : positive := 8; -- 'tamanho' em bits das entradas das operações (elementoA, elementoB e escalar)
        N : positive := 3 -- ordem das matrizes sendo operadas (uma matriz 3x3 teria N = 3)
	);
	port(
        clk: in  std_logic;
        rst: in  std_logic;
        inic: in  std_logic;
        escalar: in  signed(W-1 downto 0);
        op_code: in  std_logic_vector(2 downto 0);
        pronto: out std_logic
    );
end entity ula;

architecture structure of ula is
    signal comandos : comandos_t;
    signal status : status_t;
    signal s_ler_mem : std_logic;
    signal s_ler_dado : std_logic;
    signal s_escr_mem : std_logic;
    signal s_escr_dado : std_logic;
    signal elem_a : signed(W-1 downto 0);
    signal elem_b : signed(W-1 downto 0);
    signal elem_c : signed(ula_length(bits_per_value => W, matrix_size => N)-1 downto 0);
    signal endr : std_logic_vector(ceil_log2(N*N) - 1 downto 0);

begin
    ULA_BC: entity work.ula_bc(behavior)
    port map(clk => clk,
            rst => rst,
            iniciar => inic,
            status => status,
            op_code => op_code,
            ler => s_ler_mem,
            escr_A_B => s_escr_dado,
            ler_C => s_ler_dado,
            escrever => s_escr_mem,
            pronto => pronto,
            comandos => comandos
            );

    ULA_BO: entity work.ula_bo(arch)
    generic map(CFG => (
				bits_per_element => W, 
                lines_per_mem => N*N
			))
    port map (clk => clk,
            rst => rst,
            comandos => comandos,
            status => status,
            elementoA => elem_a,
            elementoB => elem_b,
            escalar => escalar,
            op_code => op_code,
            address_end => endr,
            elementoC => elem_c
            );

    MEM_A: entity work.memoria(arch)
    generic map(CFG => (
				bits_per_element => W, 
                lines_per_mem => N*N
			))
    port map (
            clk  => clk,
            ler  => s_ler_mem,
            ler_dado => s_ler_dado,
            escrever  => s_escr_mem,
            escrever_dado => s_escr_dado,
            endereco => endr,
            dado_entrada => (others => '0'),
            dado_saida   => elem_a

    );

    MEM_B: entity work.memoria(arch)
   generic map(CFG => (
		bits_per_element => W, 
                lines_per_mem => N*N
			))
    port map (
            clk  => clk,
            ler  => s_ler_mem,
            ler_dado => s_ler_dado,
            escrever  => s_escr_mem,
            escrever_dado => s_escr_dado,
            endereco => endr,
            dado_entrada => (others => '0'),
            dado_saida   => elem_b
    );

    MEM_C: entity work.memoria(arch)
    generic map(CFG => (
				bits_per_element => ula_length(bits_per_value => W, matrix_size => N), 
                lines_per_mem => N*N
			))
    port map (
            clk => clk,
            ler  => s_ler_mem,
            ler_dado => s_ler_dado,
            escrever  => s_escr_mem,
            escrever_dado => s_escr_dado,
            endereco => endr,
            dado_entrada => elem_c,
            dado_saida   => open
    );
    
end architecture structure;
