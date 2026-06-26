library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
	generic(N : positive := 3);
	port(
		clk          : in std_logic;
		sel_mux      : in  std_logic;
		enable_reg   : in  std_logic;
		counter_out  : out std_logic_vector(N - 1 downto 0)
	);
end counter;

architecture behavior of counter is

	signal mux_out: std_logic_vector(N-1 downto 0);
	signal reg_out: unsigned(N-1 downto 0);
	signal adder_out: unsigned(N downto 0);

begin
    MUX_COUNTER: entity work.mux_2to1(rtl)
	generic map (N => N)
	port map(sel => sel_mux,
			 input_a => std_logic_vector(to_unsigned(0, N)),
			 input_b => std_logic_vector(adder_out(N-1 downto 0)),
			 y => mux_out);

	REG_COUNTER: entity work.unsigned_register(behavior)
	generic map(N => N)
	port map (clk => clk,
			  enable => enable_reg,
			  d => unsigned(mux_out),
			  q => reg_out);

	ADDER_COUNTER: entity work.unsigned_adder(arch)
	generic map(N => N)
	port map(input_a => to_unsigned(1,N),
			 input_b => reg_out,
			 sum => adder_out);

	counter_out <= std_logic_vector(reg_out);
    
end architecture behavior;