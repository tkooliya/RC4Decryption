library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ksa_controller is
    port(
        clk_i               : in  std_logic;
        rst_i               : in  std_logic;

        fill_done_i         : in  std_logic;
        fill_o              : out std_logic;
		  
		swap_done_i         : in  std_logic; 
		swap_read_i_o       : out std_logic;
		swap_compute_j_o    : out std_logic;
        swap_read_j_o       : out std_logic;
		swap_write_i_o      : out std_logic;
		swap_write_j_o      : out std_logic;

        decrypt_done_i      : in  std_logic;
        decrypt_read_i_o    : out std_logic;
        decrypt_read_j_o    : out std_logic;
        decrypt_read_k_o    : out std_logic;
        decrypt_write_k_o   : out std_logic;
        decrypt_write_i_o   : out std_logic;
        decrypt_write_j_o   : out std_logic
    );
end entity;

architecture behaviour of ksa_controller is

    -- State signals
	type state_t is (
        RESET, 
        FILL,

		SWAP_READ_I,
		SWAP_COMPUTE_J,
        SWAP_READ_J,
		SWAP_WRITE_I,
		SWAP_WRITE_J,

        DECRYPT_READ_I,
        DECRYPT_READ_J,
        DECRYPT_WRITE_I,
        DECRYPT_WRITE_J,
        DECRYPT_READ_K,
        DECRYPT_WRITE_K,
		
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
    process(
        curr_state,
        fill_done_i,
        swap_done_i,
        decrypt_done_i
    ) begin
        next_state <= curr_state;

        case curr_state is
            when RESET =>
                next_state <= FILL;
            
            when FILL =>
                if(fill_done_i = '1') then
                    next_state <= SWAP_READ_I;
                end if;
            
            when SWAP_READ_I =>
                next_state <= SWAP_COMPUTE_J;

            when SWAP_COMPUTE_J =>
                next_state <= SWAP_READ_J;
						
            when SWAP_READ_J =>
				next_state <= SWAP_WRITE_I;
						
            when SWAP_WRITE_I =>
				next_state <= SWAP_WRITE_J;
						
            when SWAP_WRITE_J =>
                if(swap_done_i = '1') then
                    next_state <= DECRYPT_READ_I;
                else
                    next_state <= SWAP_READ_I;
                end if;

            when DECRYPT_READ_I =>
                next_state <= DECRYPT_READ_J;
				
            when DECRYPT_READ_J =>
                next_state <= DECRYPT_WRITE_I;
				
            when DECRYPT_WRITE_I =>
                next_state <= DECRYPT_WRITE_J;
				
            when DECRYPT_WRITE_J =>
                next_state <= DECRYPT_READ_K;
				
            when DECRYPT_READ_K =>
                next_state <= DECRYPT_WRITE_K;
				
            when DECRYPT_WRITE_K =>
                if(decrypt_done_i = '1') then
                    next_state <= DONE;
                else
                    next_state <= DECRYPT_READ_I;
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

    decrypt_read_i_o    <= '1' when (curr_state = DECRYPT_READ_I) else '0';
    decrypt_read_j_o    <= '1' when (curr_state = DECRYPT_READ_J) else '0';
    decrypt_write_i_o   <= '1' when (curr_state = DECRYPT_WRITE_I) else '0';
    decrypt_write_j_o   <= '1' when (curr_state = DECRYPT_WRITE_J) else '0';
    decrypt_read_k_o    <= '1' when (curr_state = DECRYPT_READ_K) else '0';
    decrypt_write_k_o   <= '1' when (curr_state = DECRYPT_WRITE_K) else '0';

end architecture;