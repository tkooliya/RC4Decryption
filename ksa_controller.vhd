library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ksa_controller is
  port(clk_i 		: in  std_logic;  
		 byte_array_256_done_i : in std_logic;	
		 byte_array_256_en_o   : out std_logic;
		 address_d_o   : out std_logic_vector(7 downto 0));
end ksa_controller;


architecture behaviour of ksa_controller is

type state_type is (INIT, DONE);
signal current_state : state_type := INIT;
signal next_state : state_type;

begin

	process(clk_i) begin
        if(rising_edge(clk_i)) then
            current_state <= next_state;
        end if;
	end process;
	
	process(current_state, byte_array_256_done_i) begin
	    next_state <= current_state;

        case current_state is
            when INIT =>
                byte_array_256_en_o <= '1';	
                
                if(byte_array_256_done_i = '1') then
                    byte_array_256_en_o <= '0';
                    next_state <= DONE;
                else
                    next_state <= INIT;
                end if;
                
            when DONE =>
                next_state <= DONE;
        end case;
	end process;

end behaviour;