library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ksa_controller is
    port(
        clk_i       : in  std_logic;
        rst_i       : in  std_logic;
        fill_done_i : in  std_logic;
        fill_o      : out std_logic
    );
end entity;

architecture behaviour of ksa_controller is

    -- State signals
	type state_t is (
        RESET, 
        FILL,
        DONE
    );
	signal curr_state : state_t;
    signal next_state : state_t;

begin

    -- State register
    process(clk_i, rst_i) begin
        if(rst_i = '1') then
            curr_state <= RESET;
        elsif(rising_edge(clk_i)) then
            curr_state <= next_state;
        end if;
    end process;

    -- next_state logic
    process(curr_state, fill_done_i) begin
        next_state <= curr_state;

        case curr_state is
            when RESET =>
                next_state <= FILL;
            
            when FILL =>
                if(fill_done_i = '1') then
                    next_state <= DONE;
                end if;
            
            when others =>
        end case;
    end process;

    fill_o <= '1' when (curr_state = FILL) else '0';

end architecture;