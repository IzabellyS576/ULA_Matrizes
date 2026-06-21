library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package ula_pack is

    -- Declaração de tipo comandos_t.
    -- Responsável por agrupar todos os sinais de comando.
    type comandos_t is record
        cEnd : std_logic;
        zEnd : std_logic;
        ci : std_logic;
        zi : std_logic;
        cJ : std_logic;
        zJ : std_logic;
        cW : std_logic;
        zW : std_logic;
        zMultMatricial : std_logic;
        cA : std_logic;
        cB : std_logic;
        cK : std_logic;
        zMult : std_logic;
        cAc : std_logic;
        zAc : std_logic;
        cOp : std_logic;
        zRegSaida : std_logic;
	end record;
    
    -- Declaração de tipo status_t.
    -- Responsável por agrupar todos os sinais de status.
    type status_t is record
        i_menor : std_logic;
        j_menor : std_logic;
        w_menor : std_logic;
    end record;


    -- Calcula o número de bits necessários para representar o maior produto que a ULA pode obter.
    -- O resultado é: 2* bits_per_value + ceil(log2(bits_per_value))
    function ula_length(bits_per_value : positive; matrix_size : positive)
    return positive;

end package ula_pack;

package body ula_pack is

    function ula_length(bits_per_value : positive; matrix_size : positive)
    return positive is
    begin
        return 2 * bits_per_value + integer(ceil(log2(real(matrix_size))));
    end function ula_length;

end package body ula_pack;
