library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ksa_datapath is
    port(
        clk_i               : in std_logic;
        rst_i               : in std_logic;

        fill_i              : in std_logic;
        fill_done_o         : out std_logic;
		  
		swap_read_i_i       : in std_logic;
		swap_compute_j_i    : in std_logic;
        swap_read_j_i       : in std_logic;
		swap_write_i_i      : in std_logic;
		swap_write_j_i      : in std_logic;
		swap_done_o         : out std_logic;

        secret_key_i        : in std_logic_vector(23 downto 0);

        wren_o              : out std_logic;
        address_o           : out std_logic_vector(7 downto 0);
        data_o              : out std_logic_vector(7 downto 0);
		q_i	                : in std_logic_vector (7 downto 0)
    );
end entity;

architecture behaviour of ksa_datapath is

    -- Init State signals
    signal index_r  : unsigned(7 downto 0);

    -- Swap State signals
    signal swap_i_r         : unsigned(7 downto 0);
    signal swap_j_r         : unsigned(7 downto 0);
    signal swap_temp_r      : unsigned(7 downto 0);
    signal swap_done        : std_logic;
    signal swap_next_j      : unsigned(7 downto 0);

    signal secret_key_byte_index   : integer;

begin

    -- Index filling register
    process(clk_i, rst_i) begin
        if(rst_i = '1') then
            index_r <= to_unsigned(0, index_r'length);
        elsif(rising_edge(clk_i)) then
            if(fill_i = '1') then
                index_r <= index_r + to_unsigned(1, index_r'length);
            else
                index_r <= to_unsigned(0, index_r'length);
            end if;
        end if;
    end process;
	 
	 
	 -- Swap state registers
    process(clk_i, rst_i) begin
        if(rst_i = '1') then
            swap_i_r    <= to_unsigned(0, swap_i_r'length);
            swap_j_r    <= to_unsigned(0, swap_j_r'length);
            swap_temp_r <= to_unsigned(0, swap_temp_r'length);
				
        elsif(rising_edge(clk_i)) then
            if(swap_compute_j_i = '1') then
                swap_j_r <= swap_next_j;
                swap_temp_r <= unsigned(q_i);

            elsif(swap_write_j_i = '1') then
                if(swap_done = '1') then
                    swap_i_r    <= to_unsigned(0, swap_i_r'length);
                    swap_j_r    <= to_unsigned(0, swap_j_r'length);
                    swap_temp_r <= to_unsigned(0, swap_temp_r'length);
                else
                    swap_i_r <= swap_i_r + 1;
                end if;

            end if;	
        end if;
    end process;

    secret_key_byte_index <= 2 - (to_integer(swap_i_r) mod 3);
    swap_next_j <= (swap_j_r + unsigned(q_i) + unsigned(secret_key_i(8 * secret_key_byte_index + 7 downto 8 * secret_key_byte_index)));
	 

    fill_done_o <= '1' when (index_r = 255) else '0';
    swap_done   <= '1' when (swap_i_r = 255) else '0';
    swap_done_o <= swap_done;

    -- Memory signal control
    process(
        fill_i,
        swap_read_i_i,
        swap_compute_j_i,
        swap_read_j_i,
        swap_write_i_i,
        swap_write_j_i,
        index_r,
        swap_i_r,
        q_i,
        swap_j_r,
        swap_temp_r
    ) begin
        wren_o      <= '0';
        address_o   <= "00000000";
        data_o      <= "00000000";

        if(fill_i = '1') then
            wren_o      <= '1';
            address_o   <= std_logic_vector(index_r);
            data_o      <= std_logic_vector(index_r);

        elsif(swap_read_i_i = '1') then
            address_o   <= std_logic_vector(swap_i_r);

        elsif(swap_read_j_i = '1') then
            address_o   <= std_logic_vector(swap_j_r);

        elsif(swap_write_i_i = '1') then
            wren_o      <= '1';
            address_o   <= std_logic_vector(swap_i_r);
            data_o      <= std_logic_vector(q_i);

        elsif(swap_write_j_i = '1') then
            wren_o      <= '1';
            address_o   <= std_logic_vector(swap_j_r);
            data_o      <= std_logic_vector(swap_temp_r);
        end if;
    end process;

end architecture;