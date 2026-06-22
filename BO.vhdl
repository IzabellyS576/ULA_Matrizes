library ieee;
use ieee.std_logic_1164.all;
use work.ula_pack.all;
use ieee.numeric_std.all;

entity BO is
    generic (
        CFG : datapath_configuration_t := (
            bits_per_element => 8,
            lines_per_mem => 64
        )
    );

    port (
        clk      : in  std_logic;

        comandos : in  comandos_t;
        status   : out status_t;
        
        elementoA: in signed(CFG.bits_per_element - 1 downto 0);
        elementoB: in signed(CFG.bits_per_element - 1 downto 0);
        escalar : in unsigned(CFG.bits_per_element - 1 downto 0);
        op_code : in std_logic_vector(2 downto 0);

        address_end : out std_logic_vector(ceil_log2(CFG.lines_per_mem) - 1 downto 0); --log2 do numero de linhas da memoria [tamanho da variável end]
        elementoC : out signed(ula_length(bits_per_value => CFG.bits_per_element, matrix_size => CFG.lines_per_mem) - 1 downto 0);
        pronto : out std_logic
    );
end BO;

architecture arch of BO is

    constant matrix_order : positive := get_matrix_order(CFG.lines_per_mem);
    constant address_matrix_length : positive := ceil_log2(matrix_order);

    signal address_i : std_logic_vector(address_matrix_length - 1 downto 0);
    signal address_J : std_logic_vector(address_matrix_length - 1 downto 0);
    signal address_W : std_logic_vector(address_matrix_length - 1 downto 0);

begin

--=================================================--
    --CONTADORES
    COUNTER_END: entity work.counter(behavior)
    generic map(N => ceil_log2(CFG.lines_per_mem))
    port map(clk => clk,
		     sel_mux => comandos.zEnd,
		     enable_reg => comandos.cEnd,
		     counter_out => address_end
            );

    COUNTER_I: entity work.counter(behavior)
    generic map(N => address_matrix_length)
    port map(clk => clk,
		     sel_mux => comandos.zi,
		     enable_reg => comandos.ci,
		     counter_out => address_i
            );

    COUNTER_J: entity work.counter(behavior)
    generic map(N => address_matrix_length)
    port map(clk => clk,
		     sel_mux => comandos.zJ,
		     enable_reg => comandos.cJ,
		     counter_out => address_J
            );

    COUNTER_W: entity work.counter(behavior)
    generic map(N => address_matrix_length)
    port map(clk => clk,
		     sel_mux => comandos.zW,
		     enable_reg => comandos.cW,
		     counter_out => address_W
            );

--=================================================--
    --COMPARADORES
    COMP_I: entity work.comparator(behavior)
    generic map(N => address_matrix_length)
    port map(a => unsigned(address_i),
             b => to_unsigned(matrix_order, address_matrix_length),
             menor => status.i_menor
            );

    COMP_J: entity work.comparator(behavior)
    generic map(N => address_matrix_length)
    port map(a => unsigned(address_J),
             b => to_unsigned(matrix_order, address_matrix_length),
             menor => status.j_menor
            );

    COMP_W: entity work.comparator(behavior)
    generic map(N => address_matrix_length)
    port map(a => unsigned(address_W),
             b => to_unsigned(matrix_order, address_matrix_length),
             menor => status.w_menor
            );

end architecture arch;