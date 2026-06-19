library ieee;
use ieee.std_logic_1164.all;

package pkg_ula is

    constant W : integer := 8;
    constant S : integer := 19;

    type t_comandos is record
        ci            : std_logic;
        zi            : std_logic;
        cj            : std_logic;
        zj            : std_logic;
        cEnd          : std_logic;
        zEnd          : std_logic;
        cOp           : std_logic;
        cA            : std_logic;
        cB            : std_logic;
        cK            : std_logic;
        cAc           : std_logic;
        zAc           : std_logic;
        cW            : std_logic;
        zW            : std_logic;
        zMult         : std_logic;
        zMultMatricial: std_logic;
        zRegSaida     : std_logic;
    end record;

    type t_status is record
        i_menor : std_logic;
        j_menor : std_logic;
        w_menor : std_logic;
    end record;

end package;