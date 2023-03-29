library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ksa_datapath is
    port(
        clk_i       : in std_logic;
        rst_i       : in std_logic;
		  q_i			  : in std_logic_vector (7 downto 0);

        fill_i      : in std_logic;
        fill_done_o : out std_logic;
		  
		  swap_read_i_i : in std_logic;
		  swap_compute_j_i : in std_logic;
		  swap_write_i_i  : in std_logic;
		  swap_write_j_i : in std_logic;
		  swap_done_o : out std_logic;


        wren_o      : out std_logic;
        address_o   : out std_logic_vector(7 downto 0);
        data_o      : out std_logic_vector(7 downto 0)
    );
end entity;

architecture behaviour of ksa_datapath is

    signal index_r  : unsigned(7 downto 0);
	 signal swap_i_r : unsigned(7 downto 0);
	 signal swap_j_r : unsigned(7 downto 0);
	 signal swap_temp_r : unsigned(7 downto 0);

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
	 
	 
	 -- Index j swap register
	 process(clk_i, rst_i) begin
	 
        if(rst_i = '1') then
		  
            swap_j_r <= to_unsigned(0, swap_j_r'length);
				
        elsif(rising_edge(clk_i)) then
		  
            if(swap_write_j_i = '1') then
				
                swap_j_r <= swap_j_r + to_unsigned(1, swap_j_r'length);
					 
            elsif(swap_i_r = 255) then
				
                swap_j_r <= to_unsigned(0, swap_j_r'length);
					 
            end if;
				
        end if;
		  
    end process;
	 
	 
	 -- Index i swap register
	 process(clk_i, rst_i) begin
	 
        if(rst_i = '1') then
		  
            swap_i_r <= to_unsigned(0, swap_i_r'length);
				
        elsif(rising_edge(clk_i)) then
		  
            if(swap_write_j_i = '1') then
				
                swap_i_r <= swap_i_r + to_unsigned(1, swap_i_r'length);
					 
            elsif(swap_i_r = 255) then
				
                swap_i_r <= to_unsigned(0, swap_i_r'length);
					 
            end if;
				
        end if;
		  
    end process;
	 
	 
	 -- Temporary swap register
	 
	 process(clk_i, rst_i) begin
	 
        if(rst_i = '1') then
		  
            swap_temp_r <= to_unsigned(0, swap_i_r'length);
				
        elsif(rising_edge(clk_i)) then
		  
            if(swap_compute_j_i = '1') then
				
                swap_temp_r <= q_i;
					 
            elsif(swap_i_r = 255) then
				
                swap_temp_r <= to_unsigned(0, swap_temp_r'length);
					 
            end if;
				
        end if;
		  
    end process;
	 
	 

    fill_done_o <= '1' when (index_r = 255) else '0';
	 swap_done_o <= '1' when (swap_i_r = 255) else '0';
    
    wren_o      <= fill_i;
    address_o   <= std_logic_vector(index_r);
    data_o      <= std_logic_vector(index_r);

end architecture;