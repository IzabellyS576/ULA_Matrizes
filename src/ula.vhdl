library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ula_pack.all;

entity ula is
	generic(
        W : positive := 8;
        N : positive := 3;
	);
	port(
		inic     : in  std_logic;     -- iniciar
        rst_a      : in  std_logic;     -- reset
        clk        : in  std_logic;     -- clock

        elementoA, elementoB : in signed(W-1 downto 0);
        escalar : in std_logic_vector (W-1 downto 0);
        op_code : in std_logic_vector (2 downto 0);
        
        elementoC : out signed(ula_length(bits_per_value => W, matrix_size => N)-1 downto 0);
        endr : out std_logic_vector(5 downto 0);
        ler_mem   : out std_logic;     -- read
        escr_mem : out std_logic;
        pronto       : out std_logic      -- pronto
    );
end entity ula;

architecture structure of ula is
	signal comandos : comandos_t;
    signal status : status_t;
begin
    ULA_BC: entity work.ula_bc()
    port map();

    ULA_BO: entity work.ula_bo()
    generic map()
    port map ();
    
end architecture structure;
