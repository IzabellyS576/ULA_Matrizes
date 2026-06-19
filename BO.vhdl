library ieee;
use ieee.std_logic_1164.all;
use work.pkg_ula.all;

entity BO is
    port (
        clk      : in  std_logic;
        comandos : in  t_comandos;
        status   : out t_status;
        -- entradas/saídas de dados...
    );
end entity;