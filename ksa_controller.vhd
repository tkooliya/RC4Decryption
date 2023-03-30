library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ksa_controller is
    port(
        clk_i       : in  std_logic;
        rst_i       : in  std_logic;
        fill_done_i : in  std_logic;
        fill_o      : out std_logic;
		  
		swap_done_i : in  std_logic; 
		swap_read_i_o : out std_logic;
		swap_compute_j_o  : out std_logic;
        swap_read_j_o   : out std_logic;
		swap_write_i_o  : out std_logic;
		swap_write_j_o  : out std_logic
    );
end entity;

architecture behaviour of ksa_controller is

    -- State signals
	type state_t is (
        RESET, 
        FILL,

		SWAP_READ_I,
		SWAP_NOTHING_1,
		SWAP_COMPUTE_J,
        SWAP_READ_J,
		SWAP_NOTHING_2,
		SWAP_WRITE_I,
		SWAP_WRITE_J,
		  
        DONE
    );
	signal curr_state : state_t;
    signal next_state : state_t;

    constant test_benching : boolean := true;

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
    process(curr_state, fill_done_i, swap_done_i) begin
        next_state <= curr_state;

        case curr_state is
            when RESET =>
                next_state <= FILL;
            
            when FILL =>
                if(fill_done_i = '1') then
                    next_state <= SWAP_READ_I;
                end if;
            
            when SWAP_READ_I =>
				next_state <= SWAP_NOTHING_1;
                if(test_benching) then
                    next_state <= SWAP_COMPUTE_J;
                end if;
						  
            when SWAP_NOTHING_1 =>
				next_state <= SWAP_COMPUTE_J;

            when SWAP_COMPUTE_J =>
                next_state <= SWAP_READ_J;
						
            when SWAP_READ_J =>
				next_state <= SWAP_NOTHING_2;
                if(test_benching) then
                    next_state <= SWAP_WRITE_I;
                end if;
						
            when SWAP_NOTHING_2 =>
				next_state <= SWAP_WRITE_I;
						
            when SWAP_WRITE_I =>
				next_state <= SWAP_WRITE_J;
						
            when SWAP_WRITE_J =>
                if(swap_done_i = '1') then
                    next_state <= DONE;
                else
                    next_state <= SWAP_READ_I;
                end if;
				
            when others =>
				
        end case;
    end process;

    fill_o              <= '1' when (curr_state = FILL) else '0';
	swap_read_i_o       <= '1' when (curr_state = SWAP_READ_I) else '0';
	swap_compute_j_o    <= '1' when (curr_state = SWAP_COMPUTE_J) else '0';
    swap_read_j_o       <= '1' when (curr_state = SWAP_READ_J) else '0';
	swap_write_i_o      <= '1' when (curr_state = SWAP_WRITE_I) else '0';
	swap_write_j_o      <= '1' when (curr_state = SWAP_WRITE_J) else '0';

end architecture;