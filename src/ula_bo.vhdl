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
        escalar : in signed(CFG.bits_per_element - 1 downto 0);
        op_code : in std_logic_vector(2 downto 0);

        address_end : out std_logic_vector(ceil_log2(CFG.lines_per_mem) - 1 downto 0); --log2 do numero de linhas da memoria [tamanho da variável end]
        elementoC : out signed(ula_length(bits_per_value => CFG.bits_per_element, matrix_size => CFG.lines_per_mem) - 1 downto 0);
        pronto : out std_logic
    );
end BO;

architecture arch of BO is

    constant matrix_order : positive := get_matrix_order(CFG.lines_per_mem);
    constant address_matrix_length : positive := ceil_log2(matrix_order);
    constant ula_len : positive := ula_length(bits_per_value => CFG.bits_per_element, matrix_size => CFG.lines_per_mem);

    signal address_i : std_logic_vector(address_matrix_length - 1 downto 0);
    signal address_J : std_logic_vector(address_matrix_length - 1 downto 0);
    signal address_W : std_logic_vector(address_matrix_length - 1 downto 0);

    signal mux_matricial_A_out : std_logic_vector(address_matrix_length - 1 downto 0);
    signal mux_matricial_B_out : std_logic_vector(address_matrix_length - 1 downto 0);
    signal mux_reg_saida_i_out : std_logic_vector(address_matrix_length - 1 downto 0);
    signal mux_reg_saida_J_out : std_logic_vector(address_matrix_length - 1 downto 0);

    signal mux_op_code_out : signed(ula_length(bits_per_value => CFG.bits_per_element, matrix_size => CFG.lines_per_mem) - 1 downto 0);
    signal zero_ula_len : signed(ula_len - 1 downto 0) := (others => '0');
    
    signal reg_A_out: signed(CFG.bits_per_element - 1 downto 0);
    signal reg_B_out: signed(CFG.bits_per_element - 1 downto 0);
    signal reg_K_out: signed(CFG.bits_per_element - 1 downto 0);
    signal reg_op_code_out: unsigned(2 downto 0);

    
    signal banco_A_out: signed(bits_per_element - 1 downto 0);
    signal banco_B_out: signed(bits_per_element - 1 downto 0);
    signal banco_C_out: signed(ula_length(bits_per_value => CFG.bits_per_element, matrix_size => CFG.matrix_order) - 1 downto 0);

begin

--=============== CONTADORES ===============-- 
    
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
            
--=============== COMPARADORES ===============-- 

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

--=============== MUXES ===============-- 

    MUX_MULTMATRICIAL_A: entity mux_2to1(behavior)
    generic map(N => address_matrix_length)
    port map(sel => comandos.zMultMatricial,
             in_0 => address_J,
             in_1 => address_W,
             y => mux_matricial_A_out
             );

    MUX_MULTMATRICIAL_B: entity mux_2to1(behavior)
    generic map(N => address_matrix_length)
    port map(sel => comandos.zMultMatricial,
             in_0 => address_i,
             in_1 => address_W,
             y => mux_matricial_B_out
             );

    MUX_REG_SAIDA_I: entity mux_2to1(behavior)
    generic map(N => address_matrix_length)
    port map(sel => comandos.zRegSaida,
             in_0 => address_i,
             in_1 => address_J,
             y => mux_reg_saida_i_out
             );

    MUX_REG_SAIDA_J: entity mux_2to1(behavior)
    generic map(N => address_matrix_length)
    port map(sel => comandos.zRegSaida,
             in_0 => address_J,
             in_1 => address_i,
             y => mux_reg_saida_J_out
             );

    MUX_OPCODE: entity mux_8to1(behavior)
    generic map(N => ula_len)
    port map(sel => std_logic_vector(reg_op_code_out),
             --in_0 => ,
             --in_1 => ,
             --in_2 => ,
             --in_3 => ,
             --in_4 => ,
             --in_5 => ,
             in_6 => zero_ula_len,
             in_7 => zero_ula_len,
             y => mux_op_code_out);

--=============== REGISTRADORES ===============-- 


    REG_A: entity work.signed_register(behavior)
    generic map(N => CFG.bits_per_element)
	port map(clk => clk, 
             enable => comandos.cA,
		     d => banco_A_out,
		     q => reg_A_out
	        );

    REG_B: entity work.signed_register(behavior)
    generic map(N => CFG.bits_per_element)
	port map(clk => clk, 
             enable => comandos.cB,
		     d => banco_B_out,
		     q => reg_B_out
	        );

    REG_K: entity work.signed_register(behavior)
    generic map(N => CFG.bits_per_element)
	port map(clk => clk, 
             enable => comandos.cK,
		     d => escalar,
		     q => reg_K_out
	        );

    
    REG_OP: entity work.unsigned_register(behavior)
    generic map(N => 3) --Fixo em 3
	port map(clk => clk, 
             enable => comandos.cOp,
		     d => unsigned(op_code),
		     q => reg_op_code_out
	        );

--=============== BANCO DE REGISTRADORES ===============-- 

    
    BANCO_REG_A: entity work.banco_reg(rtl)
    generic map(
        largura => CFG.bits_per_element,
        tam_end => address_matrix_length
                )
    port map(
        clk => clk,
        --reset => ???,
        --escrever  => ???,
        end_i => address_i,
        end_j => mux_matricial_A_out,
        d_escrito => elementoA,
        d_lido => banco_A_out
            );

    -----------------------------------------------
    
    BANCO_REG_B: entity work.banco_reg(rtl)
    generic map(
        largura => CFG.bits_per_element,
        tam_end => address_matrix_length
                )
    port map(
        clk => clk,
        --reset => ???,
        --escrever  => ???,
        end_i => mux_matricial_B_out,
        end_j => address_j,
        d_escrito => elementoB,
        d_lido => banco_B_out
            );

    -----------------------------------------------
    
    BANCO_REG_SAIDA: entity work.banco_reg(rtl)
    generic map(
        largura => ula_len,
        tam_end => address_matrix_length
                )
    port map(
        clk => clk,
        --reset => ???,
        --escrever  => ???,
        end_i => mux_reg_saida_i_out,
        end_j => mux_reg_saida_J_out,
        d_escrito => mux_op_code_out,
        d_lido => elementoC
            );

end architecture arch;