library ieee;
use ieee.std_logic_1164.all;
use work.ula_pack.all;
use ieee.numeric_std.all;

entity ula_bo is
  generic (
    CFG : datapath_configuration_t := (
    bits_per_element => 8,
    lines_per_mem    => 64
    )
  );

  port (
    clk : in std_logic;
    rst : in std_logic;

    comandos : in comandos_t;
    status   : out status_t;

    elementoA : in signed(CFG.bits_per_element - 1 downto 0);
    elementoB : in signed(CFG.bits_per_element - 1 downto 0);
    escalar   : in signed(CFG.bits_per_element - 1 downto 0);
    op_code   : in std_logic_vector(2 downto 0);

    address_end : out std_logic_vector(ceil_log2(CFG.lines_per_mem) - 1 downto 0); --log2 do numero de linhas da memoria [tamanho da variável end]
    elementoC   : out signed(ula_length(bits_per_value => CFG.bits_per_element, matrix_size => get_matrix_order(CFG.lines_per_mem)) - 1 downto 0)
  );
end ula_bo;

architecture arch of ula_bo is

--CONSTANTES RECORRENTES
  constant matrix_order          : positive := get_matrix_order(CFG.lines_per_mem);
  constant address_matrix_length : positive := 4;
  constant ula_len               : positive := ula_length(bits_per_value => CFG.bits_per_element, matrix_size => matrix_order);

  signal address_i : std_logic_vector(address_matrix_length - 1 downto 0);
  signal address_J : std_logic_vector(address_matrix_length - 1 downto 0);
  signal address_W : std_logic_vector(address_matrix_length - 1 downto 0);

  signal mux_matricial_A_out : std_logic_vector(address_matrix_length - 1 downto 0);
  signal mux_matricial_B_out : std_logic_vector(address_matrix_length - 1 downto 0);
  signal mux_reg_saida_i_out : std_logic_vector(address_matrix_length - 1 downto 0);
  signal mux_reg_saida_J_out : std_logic_vector(address_matrix_length - 1 downto 0);

  signal mux_op_code_out : signed(ula_len - 1 downto 0);
  signal zero_ula_len    : signed(ula_len - 1 downto 0) := (others => '0');

  signal reg_A_out       : signed(CFG.bits_per_element - 1 downto 0);
  signal reg_B_out       : signed(CFG.bits_per_element - 1 downto 0);
  signal reg_K_out       : signed(CFG.bits_per_element - 1 downto 0);
  signal reg_op_code_out : unsigned(2 downto 0);
  signal banco_A_out     : signed(CFG.bits_per_element - 1 downto 0);
  signal banco_B_out     : signed(CFG.bits_per_element - 1 downto 0);
  signal banco_C_out     : signed(ula_len - 1 downto 0);

  --signals das operações
  signal soma_out            : signed(CFG.bits_per_element downto 0); --N+1 bits de saída
  signal soma_out_reajustado : signed(ula_len - 1 downto 0);

  signal subtracao_out            : signed(CFG.bits_per_element downto 0); --N+1 bits de saída
  signal subtracao_out_reajustado : signed(ula_len - 1 downto 0);

  signal mux_mult_out        : std_logic_vector(CFG.bits_per_element - 1 downto 0);
  signal mux_mult_out_signed : signed(CFG.bits_per_element - 1 downto 0);

  signal convolucao_out            : signed((2 * CFG.bits_per_element) - 1 downto 0); --2N bits de saída
  signal convolucao_out_reajustado : signed(ula_len - 1 downto 0);

  signal mult_escalar_out            : signed((2 * CFG.bits_per_element) - 1 downto 0); --2N bits de saída
  signal mult_escalar_out_reajustado : signed(ula_len - 1 downto 0);

  signal mult_matricial_out : signed(ula_len - 1 downto 0);

  signal resize_reg_a_out_ula_len: signed(CGF.bits_per_element-1 downto 0);

begin

  --=============== CONTADORES ===============-- 

  COUNTER_END : entity work.counter(behavior)
    generic map(N => ceil_log2(CFG.lines_per_mem))
    port map
    (
      clk         => clk,
      sel_mux     => comandos.zEnd,
      enable_reg  => comandos.cEnd,
      counter_out => address_end
    );
  COUNTER_I : entity work.counter(behavior)
    generic map(N => address_matrix_length)
    port map
    (
      clk         => clk,
      sel_mux     => comandos.zi,
      enable_reg  => comandos.ci,
      counter_out => address_i
    );
  COUNTER_J : entity work.counter(behavior)
    generic map(N => address_matrix_length)
    port map
    (
      clk         => clk,
      sel_mux     => comandos.zJ,
      enable_reg  => comandos.cJ,
      counter_out => address_J
    );
  COUNTER_W : entity work.counter(behavior)
    generic map(N => address_matrix_length)
    port map
    (
      clk         => clk,
      sel_mux     => comandos.zW,
      enable_reg  => comandos.cW,
      counter_out => address_W
    );
  --=============== COMPARADORES ===============-- 

  COMP_I : entity work.comparator(behavior)
    generic map(N => address_matrix_length)
    port map
    (
      a     => unsigned(address_i),
      b     => to_unsigned(matrix_order, address_matrix_length),
      menor => status.i_menor
    );
  COMP_J : entity work.comparator(behavior)
    generic map(N => address_matrix_length)
    port map
    (
      a     => unsigned(address_J),
      b     => to_unsigned(matrix_order, address_matrix_length),
      menor => status.j_menor
    );
  COMP_W : entity work.comparator(behavior)
    generic map(N => address_matrix_length)
    port map
    (
      a     => unsigned(address_W),
      b     => to_unsigned(matrix_order, address_matrix_length),
      menor => status.w_menor
    );
  --=============== MUXES ===============-- 

  MUX_MULTMATRICIAL_A : entity work.mux_2to1(rtl)
    generic map(N => address_matrix_length)
    port map
    (
      sel  => comandos.zMultMatricial,
      in_0 => address_J,
      in_1 => address_W,
      y    => mux_matricial_A_out
    );
  MUX_MULTMATRICIAL_B : entity work.mux_2to1(rtl)
    generic map(N => address_matrix_length)
    port map
    (
      sel  => comandos.zMultMatricial,
      in_0 => address_i,
      in_1 => address_W,
      y    => mux_matricial_B_out
    );
  MUX_REG_SAIDA_I : entity work.mux_2to1(rtl)
    generic map(N => address_matrix_length)
    port map
    (
      sel  => comandos.zRegSaida,
      in_0 => address_i,
      in_1 => address_J,
      y    => mux_reg_saida_i_out
    );
  MUX_REG_SAIDA_J : entity work.mux_2to1(rtl)
    generic map(N => address_matrix_length)
    port map
    (
      sel  => comandos.zRegSaida,
      in_0 => address_J,
      in_1 => address_i,
      y    => mux_reg_saida_J_out
    );

  resize_reg_a_out_ula_len <= resize(reg_A_out, ula_len);
  MUX_OPCODE : entity work.mux_8to1(rtl)
    generic map(N => ula_len)
    port map
    (
      sel  => std_logic_vector(reg_op_code_out),
      in_0 => soma_out_reajustado,
      in_1 => subtracao_out_reajustado,
      in_2 => resize_reg_a_out_ula_len, --não existe módulo específico para transposição
      in_3 => mult_escalar_out_reajustado,
      in_4 => convolucao_out_reajustado,
      in_5 => mult_matricial_out,
      in_6 => zero_ula_len,
      in_7 => zero_ula_len,
      y    => mux_op_code_out
    );

  MUX_MULT : entity work.mux_2to1(rtl)
    generic map(N => CFG.bits_per_element)
    port map
    (
      sel  => comandos.zMult,
      in_0 => std_logic_vector(reg_B_out),
      in_1 => std_logic_vector(reg_K_out),
      y    => mux_mult_out
    );

  mux_mult_out_signed <= signed(mux_mult_out); --conversão de std_logic_vector para signed

  --=============== REGISTRADORES ===============-- 
  REG_A : entity work.signed_register(behavior)
    generic map(N => CFG.bits_per_element)
    port map
    (
      clk    => clk,
      enable => comandos.cA,
      d      => banco_A_out,
      q      => reg_A_out
    );
  REG_B : entity work.signed_register(behavior)
    generic map(N => CFG.bits_per_element)
    port map
    (
      clk    => clk,
      enable => comandos.cB,
      d      => banco_B_out,
      q      => reg_B_out
    );
  REG_K : entity work.signed_register(behavior)
    generic map(N => CFG.bits_per_element)
    port map
    (
      clk    => clk,
      enable => comandos.cK,
      d      => escalar,
      q      => reg_K_out
    );

  REG_OP : entity work.unsigned_register(behavior)
    generic map(N => 3) --Fixo em 3
    port map
    (
      clk    => clk,
      enable => comandos.cOp,
      d      => unsigned(op_code),
      q      => reg_op_code_out
    );
  --=============== BANCO DE REGISTRADORES ===============-- 
  BANCO_REG_A : entity work.banco_reg(rtl)
    generic map(
      largura => CFG.bits_per_element,
      tam_end => address_matrix_length
    )
    port map
    (
      clk => clk,
      reset => rst,
      escrever  => comandos.cA,
      end_i     => address_i,
      end_j     => mux_matricial_A_out,
      d_escrito => elementoA,
      d_lido    => banco_A_out
    );

  -----------------------------------------------

  BANCO_REG_B : entity work.banco_reg(rtl)
    generic map(
      largura => CFG.bits_per_element,
      tam_end => address_matrix_length
    )
    port map
    (
      clk => clk,
      reset => rst,
      escrever  => comandos.cB,
      end_i     => mux_matricial_B_out,
      end_j     => address_J,
      d_escrito => elementoB,
      d_lido    => banco_B_out
    );

  -----------------------------------------------

  BANCO_REG_SAIDA : entity work.banco_reg(rtl)
    generic map(
      largura => ula_len,
      tam_end => address_matrix_length
    )
    port map
    (
      clk => clk,
      reset => rst,
      escrever  => '1', --sem comando direto, fixei em 1 por enquanto
      end_i     => mux_reg_saida_i_out,
      end_j     => mux_reg_saida_J_out,
      d_escrito => mux_op_code_out,
      d_lido    => elementoC
    );

  --=============== MÓDULOS DE OPERAÇÕES ===============-- 

  SOMA : entity work.soma(arch)
    generic map(
      N => CFG.bits_per_element
    )
    port map
    (
      input_a => reg_A_out,
      input_b => reg_B_out,
      sum     => soma_out
    );

  soma_out_reajustado <= resize(soma_out, ula_len); --extensão de sinal

  -----------------------------------------------

  SUBTRACAO : entity work.subtracao(arch)
    generic map(
      N => CFG.bits_per_element
    )
    port map
    (
      input_a => reg_A_out,
      input_b => reg_B_out,
      diff    => subtracao_out
    );

  subtracao_out_reajustado <= resize(subtracao_out, ula_len); --extensão de sinal

  -----------------------------------------------

  CONVOLUCAO : entity work.convolucao(arch)
    generic map(
      W => CFG.bits_per_element
    )
    port map
    (
      input_a => reg_A_out,
      input_b => mux_mult_out_signed,
      product => convolucao_out
    );

  convolucao_out_reajustado <= resize(convolucao_out, ula_len); --extensão de sinal

  -----------------------------------------------

  MULT_ESCALAR : entity work.mult_escalar(structure)
    generic map(
      W => CFG.bits_per_element
    )
    port map
    (
      input_a => reg_A_out,
      input_k => mux_mult_out_signed,
      product => mult_escalar_out
    );

  mult_escalar_out_reajustado <= resize(mult_escalar_out, ula_len); --extensão de sinal

  -----------------------------------------------

  MULTIPLICACAO_MATRICIAL : entity work.multiplicacao(arch)
    generic map(
      W => CFG.bits_per_element,
      N => CFG.lines_per_mem
    )
    port map
    (
      clk      => clk,
      input_a  => reg_A_out,
      input_b  => mux_mult_out_signed,
      comandos => comandos,
      multi    => mult_matricial_out -- ja esta no tamanho ula_len
    );

  -----------------------------------------------
end architecture arch;