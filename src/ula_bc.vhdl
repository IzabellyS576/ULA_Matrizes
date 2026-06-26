library ieee;
use ieee.std_logic_1164.all;
use work.ula_pack.all;

entity ula_bc is
	port(
		clk: in std_logic;  
		rst: in std_logic;   
		iniciar: in std_logic;
		status: in status_t;
        op_code: in std_logic_vector(2 downto 0);

		ler: out std_logic;
		escrever: out std_logic;
        pronto: out std_logic;
		comandos: out comandos_t
	);
end entity;


architecture behavior of ula_bc is
   type state_t is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, S18, S19, S20, S21, S22);
   signal current_state, next_state : state_t;
begin
    reg_state : process(clk, rst)
    begin
        if rst = '1' then
            current_state <= S0;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process reg_state;
    
    lpe: process(status, iniciar, current_state)
    begin
        case current_state is
            WHEN S0 =>
                if iniciar = '1' then
                    next_state <= S1;
                else
                    next_state <= S0;
                end if;

            WHEN S1 =>
                next_state <= S2;

            WHEN S2 =>
                if status.i_menor = '1' then
                    next_state <= S3;
                else
                    next_state <= S6;
                end if;

            WHEN S3 =>
                if status.j_menor = '1' then
                    next_state <= S4;
                else
                    next_state <= S5;
                end if;

            WHEN S4 =>
                next_state <= S3;

            WHEN S5 =>
                next_state <= S2;
            
            WHEN S6 =>
                next_state <= S7;

            WHEN S7 =>
                if status.i_menor = '1' then
                    next_state <= S8;
                else
                    next_state <= S18;
                end if;

            WHEN S8 =>                                    
                if status.j_menor = '1' then              
                        case op_code is
                            WHEN "000" =>
                                next_state <= S9;
                            
                            WHEN "001" =>
                                next_state <= S10;
                            
                            WHEN "010" =>
                                next_state <= S11;

                            WHEN "011" =>
                                next_state <= S12;
                            
                            WHEN "100" =>
                                next_state <= S13;

                            WHEN "101" =>
                                next_state <= S14;

                            WHEN OTHERS =>
                                next_state <= S0; --erro: volta para estado inicial
                        end case;
                else
                    next_state <= S17;
                end if;

            WHEN S9 =>
                next_state <= S8;

            WHEN S10 =>
                next_state <= S8;

            WHEN S11 =>
                next_state <= S8;

            WHEN S12 =>
                next_state <= S8;

            WHEN S13 =>
                next_state <= S8;

            WHEN S14 =>
                if status.w_menor = '1' then
                    next_state <= S15;
                else
                    next_state <= S16;
                end if;

            WHEN S15 =>
                next_state <= S14;

            WHEN S16 =>
                next_state <= S8;

            WHEN S17 =>
                next_state <= S7;
            
            WHEN S18 =>
                next_state <= S19;

            WHEN S19 =>
                if status.i_menor = '1' then
                    next_state <= S20;
                else
                    next_state <= S0;
                end if;

            WHEN S20 =>
                if status.j_menor = '1' then
                    next_state <= S21;
                else
                    next_state <= S22;
                end if;

            WHEN S21 =>
                next_state <= S20;

            WHEN S22 =>
                next_state <= S19;

        end case;
    end process lpe;
    
    ls: process(current_state) is
    begin
        case current_state is
            WHEN S0 =>
                comandos.cEnd <= '0';
                comandos.zEnd <= '-';

                comandos.ci <= '0';
                comandos.zi <= '-';

                comandos.cJ <= '0';
                comandos.zJ <= '-';

                comandos.cW <= '0';
                comandos.zW <= '-';

                comandos.zMultMatricial <= '-';

                comandos.cA <= '0';
                comandos.cB <= '0';
                comandos.cK <= '0';

                comandos.zMult <= '-';

                comandos.cAc <= '0';
                comandos.zAc <= '-';

                comandos.cOp <= '0';

                comandos.zRegSaida <= '-';

                comandos.zMem <= '1';

                esc_A <= '1';
                esc_B <= '1';
                ler_C <='1';

                ler <= '0';
                escrever <= '0';
                pronto <= '1';
                

            WHEN S1 =>
                comandos.cEnd <= '1';
                comandos.zEnd <= '0';

                comandos.ci <= '1';
                comandos.zi <= '0';

                comandos.cJ <= '1';
                comandos.zJ <= '0';

                comandos.cW <= '0';
                comandos.zW <= '-';

                comandos.zMultMatricial <= '-';

                comandos.cA <= '0';
                comandos.cB <= '0';
                comandos.cK <= '0';

                comandos.zMult <= '-';

                comandos.cAc <= '0';
                comandos.zAc <= '-';

                comandos.cOp <= '1';

                comandos.zRegSaida <= '-';

                comandos.zMem <= '-';

                esc_A <= '0';
                esc_B <= '0';
                ler_C <='0';

                ler <= '0';
                escrever <= '0';
                pronto <= '0';

            WHEN S2 =>
                comandos.cEnd <= '0';
                comandos.zEnd <= '-';

                comandos.ci <= '0';
                comandos.zi <= '-';

                comandos.cJ <= '0';
                comandos.zJ <= '-';

                comandos.cW <= '0';
                comandos.zW <= '-';

                comandos.zMultMatricial <= '-';

                comandos.cA <= '0';
                comandos.cB <= '0';
                comandos.cK <= '0';

                comandos.zMult <= '-';

                comandos.cAc <= '0';
                comandos.zAc <= '-';

                comandos.cOp <= '0';

                comandos.zRegSaida <= '-';

                comandos.zMem <= '-';

                esc_A <= '0';
                esc_B <= '0';
                ler_C <='0';

                ler <= '0';
                escrever <= '0';
                pronto <= '0';

            WHEN S3 =>
                comandos.cEnd <= '0';
                comandos.zEnd <= '-';

                comandos.ci <= '0';
                comandos.zi <= '-';

                comandos.cJ <= '0';
                comandos.zJ <= '-';

                comandos.cW <= '0';
                comandos.zW <= '-';

                comandos.zMultMatricial <= '-';

                comandos.cA <= '0';
                comandos.cB <= '0';
                comandos.cK <= '0';

                comandos.zMult <= '-';

                comandos.cAc <= '0';
                comandos.zAc <= '-';

                comandos.cOp <= '0';

                comandos.zRegSaida <= '-';

                comandos.zMem <= '-';

                esc_A <= '0';
                esc_B <= '0';
                ler_C <='0';

                ler <= '0';
                escrever <= '0';
                pronto <= '0';
            WHEN S4 =>
                comandos.cEnd <= '1';
                comandos.zEnd <= '1';

                comandos.ci <= '0';
                comandos.zi <= '-';

                comandos.cJ <= '1';
                comandos.zJ <= '1';

                comandos.cW <= '0';
                comandos.zW <= '-';

                comandos.zMultMatricial <= '-';

                comandos.cA <= '0';
                comandos.cB <= '0';
                comandos.cK <= '0';

                comandos.zMult <= '-';

                comandos.cAc <= '0';
                comandos.zAc <= '-';

                comandos.cOp <= '0';

                comandos.zRegSaida <= '-';

                comandos.zMem <= '-';

                esc_A <= '0';
                esc_B <= '0';
                ler_C <='0';

                ler <= '1';
                escrever <= '0';
                pronto <= '0';

            WHEN S5 =>
                comandos.cEnd <= '0';
                comandos.zEnd <= '-';

                comandos.ci <= '1';
                comandos.zi <= '1';

                comandos.cJ <= '1';
                comandos.zJ <= '0';

                comandos.cW <= '0';
                comandos.zW <= '-';

                comandos.zMultMatricial <= '-';

                comandos.cA <= '0';
                comandos.cB <= '0';
                comandos.cK <= '0';

                comandos.zMult <= '-';

                comandos.cAc <= '0';
                comandos.zAc <= '-';

                comandos.cOp <= '0';

                comandos.zRegSaida <= '-';

                comandos.zMem <= '-';

                esc_A <= '0';
                esc_B <= '0';
                ler_C <='0';

                ler <= '0';
                escrever <= '0';
                pronto <= '0';

            WHEN S6 =>
                comandos.cEnd <= '0';
                comandos.zEnd <= '-';

                comandos.ci <= '1';
                comandos.zi <= '0';

                comandos.cJ <= '1';
                comandos.zJ <= '0';

                comandos.cW <= '0';
                comandos.zW <= '-';

                comandos.zMultMatricial <= '-';

                comandos.cA <= '0';
                comandos.cB <= '0';
                comandos.cK <= '0';

                comandos.zMult <= '-';

                comandos.cAc <= '0';
                comandos.zAc <= '-';

                comandos.cOp <= '0';

                comandos.zRegSaida <= '-';

                comandos.zMem <= '-';

                esc_A <= '0';
                esc_B <= '0';
                ler_C <='0';

                ler <= '0';
                escrever <= '0';
                pronto <= '0';

            WHEN S7 =>
                comandos.cEnd <= '0';
                comandos.zEnd <= '-';

                comandos.ci <= '0';
                comandos.zi <= '-';

                comandos.cJ <= '0';
                comandos.zJ <= '-';

                comandos.cW <= '0';
                comandos.zW <= '-';

                comandos.zMultMatricial <= '-';

                comandos.cA <= '0';
                comandos.cB <= '0';
                comandos.cK <= '0';

                comandos.zMult <= '-';

                comandos.cAc <= '0';
                comandos.zAc <= '-';

                comandos.cOp <= '0';

                comandos.zRegSaida <= '-';

                comandos.zMem <= '-';

                esc_A <= '0';
                esc_B <= '0';
                ler_C <='0';

                ler <= '0';
                escrever <= '0';
                pronto <= '0';
            WHEN S8 =>
                comandos.cEnd <= '0';
                comandos.zEnd <= '-';

                comandos.ci <= '0';
                comandos.zi <= '-';

                comandos.cJ <= '0';
                comandos.zJ <= '-';

                comandos.cW <= '1';
                comandos.zW <= '0';

                comandos.zMultMatricial <= '-';

                comandos.cA <= '0';
                comandos.cB <= '0';
                comandos.cK <= '0';

                comandos.zMult <= '-';

                comandos.cAc <= '1';
                comandos.zAc <= '0';

                comandos.cOp <= '0';

                comandos.zRegSaida <= '-';

                comandos.zMem <= '-';

                esc_A <= '0';
                esc_B <= '0';
                ler_C <='0';

                ler <= '0';
                escrever <= '0';
                pronto <= '0';

            WHEN S9 =>
                comandos.cEnd <= '0';
                comandos.zEnd <= '-';

                comandos.ci <= '0';
                comandos.zi <= '-';

                comandos.cJ <= '1';
                comandos.zJ <= '1';

                comandos.cW <= '0';
                comandos.zW <= '-';

                comandos.zMultMatricial <= '0';

                comandos.cA <= '1';
                comandos.cB <= '1';
                comandos.cK <= '0';

                comandos.zMult <= '-';

                comandos.cAc <= '0';
                comandos.zAc <= '-';

                comandos.cOp <= '0';

                comandos.zRegSaida <= '0';

                comandos.zMem <= '-';

                esc_A <= '0';
                esc_B <= '0';
                ler_C <='0';

                ler <= '0';
                escrever <= '0';
                pronto <= '0';

            WHEN S10 =>
                comandos.cEnd <= '0';
                comandos.zEnd <= '-';

                comandos.ci <= '0';
                comandos.zi <= '-';

                comandos.cJ <= '1';
                comandos.zJ <= '1';

                comandos.cW <= '0';
                comandos.zW <= '-';

                comandos.zMultMatricial <= '0';

                comandos.cA <= '1';
                comandos.cB <= '1';
                comandos.cK <= '0';

                comandos.zMult <= '-';

                comandos.cAc <= '0';
                comandos.zAc <= '-';

                comandos.cOp <= '0';

                comandos.zRegSaida <= '0';

                comandos.zMem <= '-';

                esc_A <= '0';
                esc_B <= '0';
                ler_C <='0';

                ler <= '0';
                escrever <= '0';
                pronto <= '0';

            WHEN S11 =>
                comandos.cEnd <= '0';
                comandos.zEnd <= '-';

                comandos.ci <= '0';
                comandos.zi <= '-';

                comandos.cJ <= '1';
                comandos.zJ <= '1';

                comandos.cW <= '0';
                comandos.zW <= '-';

                comandos.zMultMatricial <= '0';

                comandos.cA <= '1';
                comandos.cB <= '0';
                comandos.cK <= '0';

                comandos.zMult <= '-';

                comandos.cAc <= '0';
                comandos.zAc <= '-';

                comandos.cOp <= '0';

                comandos.zRegSaida <= '1';

                comandos.zMem <= '-';

                esc_A <= '0';
                esc_B <= '0';
                ler_C <='0';

                ler <= '0';
                escrever <= '0';
                pronto <= '0';

            WHEN S12 =>
                comandos.cEnd <= '0';
                comandos.zEnd <= '-';

                comandos.ci <= '0';
                comandos.zi <= '-';

                comandos.cJ <= '1';
                comandos.zJ <= '1';

                comandos.cW <= '0';
                comandos.zW <= '-';

                comandos.zMultMatricial <= '0';

                comandos.cA <= '1';
                comandos.cB <= '0';
                comandos.cK <= '1';

                comandos.zMult <= '1';

                comandos.cAc <= '0';
                comandos.zAc <= '-';

                comandos.cOp <= '0';

                comandos.zRegSaida <= '0';

                comandos.zMem <= '-';

                esc_A <= '0';
                esc_B <= '0';
                ler_C <='0';

                ler <= '0';
                escrever <= '0';
                pronto <= '0';

            WHEN S13 =>
                comandos.cEnd <= '0';
                comandos.zEnd <= '-';

                comandos.ci <= '0';
                comandos.zi <= '-';

                comandos.cJ <= '1';
                comandos.zJ <= '1';

                comandos.cW <= '0';
                comandos.zW <= '-';

                comandos.zMultMatricial <= '0';

                comandos.cA <= '1';
                comandos.cB <= '1';
                comandos.cK <= '0';

                comandos.zMult <= '-';

                comandos.cAc <= '0';
                comandos.zAc <= '-';

                comandos.cOp <= '0';

                comandos.zRegSaida <= '0';

                comandos.zMem <= '-';

                esc_A <= '0';
                esc_B <= '0';
                ler_C <='0';

                ler <= '0';
                escrever <= '0';
                pronto <= '0';

            WHEN S14 =>
                comandos.cEnd <= '0';
                comandos.zEnd <= '-';

                comandos.ci <= '0';
                comandos.zi <= '-';

                comandos.cJ <= '0';
                comandos.zJ <= '-';

                comandos.cW <= '0';
                comandos.zW <= '-';

                comandos.zMultMatricial <= '-';

                comandos.cA <= '0';
                comandos.cB <= '0';
                comandos.cK <= '0';

                comandos.zMult <= '-';

                comandos.cAc <= '0';
                comandos.zAc <= '-';

                comandos.cOp <= '0';

                comandos.zRegSaida <= '-';

                comandos.zMem <= '-';

                esc_A <= '0';
                esc_B <= '0';
                ler_C <='0';

                ler <= '0';
                escrever <= '0';
                pronto <= '0';

            WHEN S15 =>
                comandos.cEnd <= '0';
                comandos.zEnd <= '-';

                comandos.ci <= '0';
                comandos.zi <= '-';

                comandos.cJ <= '0';
                comandos.zJ <= '-';

                comandos.cW <= '1';
                comandos.zW <= '1';

                comandos.zMultMatricial <= '1';

                comandos.cA <= '1';
                comandos.cB <= '1';
                comandos.cK <= '0';

                comandos.zMult <= '0';

                comandos.cAc <= '1';
                comandos.zAc <= '1';

                comandos.cOp <= '0';

                comandos.zRegSaida <= '-';

                comandos.zMem <= '-';

                esc_A <= '0';
                esc_B <= '0';
                ler_C <='0';

                ler <= '0';
                escrever <= '0';
                pronto <= '0';

            WHEN S16 =>
                comandos.cEnd <= '0';
                comandos.zEnd <= '-';

                comandos.ci <= '0';
                comandos.zi <= '-';

                comandos.cJ <= '1';
                comandos.zJ <= '1';

                comandos.cW <= '0';
                comandos.zW <= '-';

                comandos.zMultMatricial <= '-';

                comandos.cA <= '0';
                comandos.cB <= '0';
                comandos.cK <= '0';

                comandos.zMult <= '-';

                comandos.cAc <= '0';
                comandos.zAc <= '-';

                comandos.cOp <= '0';

                comandos.zRegSaida <= '0';

                comandos.zMem <= '-';

                esc_A <= '0';
                esc_B <= '0';
                ler_C <='0';

                ler <= '0';
                escrever <= '0';
                pronto <= '0';

            WHEN S17 =>
                comandos.cEnd <= '0';
                comandos.zEnd <= '-';

                comandos.ci <= '1';
                comandos.zi <= '1';

                comandos.cJ <= '1';
                comandos.zJ <= '0';

                comandos.cW <= '0';
                comandos.zW <= '-';

                comandos.zMultMatricial <= '-';

                comandos.cA <= '0';
                comandos.cB <= '0';
                comandos.cK <= '0';

                comandos.zMult <= '-';

                comandos.cAc <= '0';
                comandos.zAc <= '-';

                comandos.cOp <= '0';

                comandos.zRegSaida <= '-';

                comandos.zMem <= '-';

                esc_A <= '0';
                esc_B <= '0';
                ler_C <='0';

                ler <= '0';
                escrever <= '0';
                pronto <= '0';

            WHEN S18 =>
                comandos.cEnd <= '1';
                comandos.zEnd <= '0';

                comandos.ci <= '1';
                comandos.zi <= '0';

                comandos.cJ <= '1';
                comandos.zJ <= '0';

                comandos.cW <= '0';
                comandos.zW <= '-';

                comandos.zMultMatricial <= '-';

                comandos.cA <= '0';
                comandos.cB <= '0';
                comandos.cK <= '0';

                comandos.zMult <= '-';

                comandos.cAc <= '0';
                comandos.zAc <= '-';

                comandos.cOp <= '0';

                comandos.zRegSaida <= '-';

                comandos.zMem <= '-';

                esc_A <= '0';
                esc_B <= '0';
                ler_C <='0';

                ler <= '0';
                escrever <= '0';
                pronto <= '0';

            WHEN S19 =>
                comandos.cEnd <= '0';
                comandos.zEnd <= '-';

                comandos.ci <= '0';
                comandos.zi <= '-';

                comandos.cJ <= '0';
                comandos.zJ <= '-';

                comandos.cW <= '0';
                comandos.zW <= '-';

                comandos.zMultMatricial <= '-';

                comandos.cA <= '0';
                comandos.cB <= '0';
                comandos.cK <= '0';

                comandos.zMult <= '-';

                comandos.cAc <= '0';
                comandos.zAc <= '-';

                comandos.cOp <= '0';

                comandos.zRegSaida <= '-';

                comandos.zMem <= '-';

                esc_A <= '0';
                esc_B <= '0';
                ler_C <='0';

                ler <= '0';
                escrever <= '0';
                pronto <= '0';

            WHEN S20 =>
                comandos.cEnd <= '0';
                comandos.zEnd <= '-';

                comandos.ci <= '0';
                comandos.zi <= '-';

                comandos.cJ <= '0';
                comandos.zJ <= '-';

                comandos.cW <= '0';
                comandos.zW <= '-';

                comandos.zMultMatricial <= '-';

                comandos.cA <= '0';
                comandos.cB <= '0';
                comandos.cK <= '0';

                comandos.zMult <= '-';

                comandos.cAc <= '0';
                comandos.zAc <= '-';

                comandos.cOp <= '0';

                comandos.zRegSaida <= '-';

                comandos.zMem <= '-';

                esc_A <= '0';
                esc_B <= '0';
                ler_C <='0';

                ler <= '0';
                escrever <= '0';
                pronto <= '0';

            WHEN S21 =>
                comandos.cEnd <= '1';
                comandos.zEnd <= '1';

                comandos.ci <= '0';
                comandos.zi <= '-';

                comandos.cJ <= '1';
                comandos.zJ <= '1';

                comandos.cW <= '0';
                comandos.zW <= '-';

                comandos.zMultMatricial <= '-';

                comandos.cA <= '0';
                comandos.cB <= '0';
                comandos.cK <= '0';

                comandos.zMult <= '-';

                comandos.cAc <= '0';
                comandos.zAc <= '-';

                comandos.cOp <= '0';

                comandos.zRegSaida <= '-';

                comandos.zMem <= '0';

                esc_A <= '0';
                esc_B <= '0';
                ler_C <='0';

                ler <= '0';
                escrever <= '1';
                pronto <= '0';

            WHEN S22 =>
                comandos.cEnd <= '0';
                comandos.zEnd <= '-';

                comandos.ci <= '1';
                comandos.zi <= '1';

                comandos.cJ <= '1';
                comandos.zJ <= '0';

                comandos.cW <= '0';
                comandos.zW <= '-';

                comandos.zMultMatricial <= '-';

                comandos.cA <= '0';
                comandos.cB <= '0';
                comandos.cK <= '0';

                comandos.zMult <= '-';

                comandos.cAc <= '0';
                comandos.zAc <= '-';

                comandos.cOp <= '0';

                comandos.zRegSaida <= '-';

                comandos.zMem <= '-';

                esc_A <= '0';
                esc_B <= '0';
                ler_C <='0';

                ler <= '0';
                escrever <= '0';
                pronto <= '0';

        end case;
    end process ls;
    
end architecture;
