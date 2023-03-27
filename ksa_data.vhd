library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



-- xxxxxxxx_w_o => working memory (RAM) (S)
-- xxxxxxxx_d_o => decrypted message memory (RAM)
-- xxxxxxxx_m_o => encrypted message memory (ROM)

entity ksa_data is
  port(clk_i 		   : in  std_logic;  
       secret_key_i  : in std_logic_vector(23 downto 0);
		 byte_array_256_en_i  : in std_logic;
		 
		 q_m_i 			: std_logic_vector(7 downto 0);
		 q_w_i  		   : in std_logic;
		 
		 wren_w_o		: out std_logic; -- Working Memory RAM(S)(256x8)
		 wren_d_o 	   : out std_logic; -- Decrypted Message RAM (32x8)
		 data_w_o 		: out std_logic_vector(7 downto 0);  -- might have to change the bit size
		 data_d_o		: out std_logic_vector(7 downto 0);  -- might have to change the bit size
		 address_w_o   : out std_logic_vector(7 downto 0);
		 address_d_o   : out std_logic_vector(7 downto 0);
		 address_m_o   : out std_logic_vector(7 downto 0);
		 byte_array_256_done_o : out std_logic
		 );
end ksa_data;



architecture behaviour of ksa_data is
	-- These are signals that are used to connect to the memory	
	
	type mem_array is array(255 downto 0) of std_logic_vector(7 downto 0); -- create the array of 256 bytes (256-8 bit numbers)
	signal byte_array_256 : mem_array;

	begin
		 
	process(clk_i, byte_array_256_en_i)

	variable i : integer := 0;

	begin
		if(rising_edge(clk_i)) then
			if(i < 255 AND byte_array_256_en_i = '1') then
				-- byte_array_256(i) <= std_logic_vector(to_unsigned(i, 8));
				i := i + 1;
				address_w_o <= std_logic_vector(to_unsigned(i, 8));
				data_w_o <= std_logic_vector(to_unsigned(i, 8));
				wren_w_o <= '0';
			else
				i := 0;
				byte_array_256_done_o <= '1';
			end if;
		end if;	
	end process;

end behaviour;
				
			
				-- change to next state
		