library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity part of the description. Describes inputs and outputs

entity ksa is
    port(
        CLOCK_50    : in  std_logic;  -- Clock pin
        KEY         : in  std_logic_vector(3 downto 0);  -- push button switches
        SW          : in  std_logic_vector(15 downto 0);  -- slider switches
		LEDG       : out std_logic_vector(7 downto 0);  -- green lights
		LEDR       : out std_logic_vector(17 downto 0)  -- red lights
    );
end ksa;

-- Architecture part of the description

architecture rtl of ksa is

    -- Declare the component for the ram. This should match the entity description 
	-- in the entity created by the megawizard. If you followed the instructions in the 
	-- handout exactly, it should match. If not, look at s_memory.vhd and make the
	-- changes to the component below
	
    COMPONENT s_memory IS
	    PORT (
		    address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		    clock		: IN STD_LOGIC := '1';
		    data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		    wren		: IN STD_LOGIC;
		    q		    : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
    END component;
	
	component ksa_data is
		port(
            clk_i 		            : in std_logic;
            rst_i                   : in std_logic;
            secret_key_i            : in std_logic_vector(23 downto 0);
            byte_array_256_en_i     : in std_logic;
			 
            q_m_i 			        : in std_logic_vector(7 downto 0);
            q_w_i  		            : in std_logic;
			 
            wren_w_o		        : out std_logic; -- Working Memory RAM(S)(256x8)
            wren_d_o 	            : out std_logic; -- Decrypted Message RAM (32x8)
            data_w_o 		        : out std_logic_vector(7 downto 0);  -- might have to change the bit size
            data_d_o		        : out std_logic_vector(7 downto 0);  -- might have to change the bit size
            address_w_o             : out std_logic_vector(7 downto 0);
            address_d_o             : out std_logic_vector(7 downto 0);
            address_m_o             : out std_logic_vector(7 downto 0);
            byte_array_256_done_o   : out std_logic
        );
	end component;
	
	component ksa_controller is
		port(
            clk_i 				    : in  std_logic;
            rst_i                   : in  std_logic;
			byte_array_256_done_i   : in  std_logic;
			byte_array_256_en_o     : out std_logic;
			address_d_o   			: out std_logic_vector(7 downto 0)
        );
	end component;

	-- Enumerated type for the state variable. You will likely be adding extra
	-- state names here as you complete your design								
    -- These are signals that are used to connect to the memory			

	
    signal address  : STD_LOGIC_VECTOR (7 DOWNTO 0);
    signal data     : STD_LOGIC_VECTOR (7 DOWNTO 0);
    signal wren     : STD_LOGIC;
    signal q        : STD_LOGIC_VECTOR (7 DOWNTO 0);


    signal rst_active_1 : std_logic;
	 
    -- Data signals
    signal secret_key   : std_logic_vector(23 downto 0);
    signal q_m          : std_logic_vector(7 downto 0);
    signal q_w	        : std_logic;
    signal wren_w       : std_logic;
    signal wren_d	    : std_logic;
    signal data_w	    : std_logic_vector(7 downto 0);
    signal data_d       : std_logic_vector(7 downto 0);
    signal address_w    : std_logic_vector(7 downto 0);
    signal address_m    : std_logic_vector(7 downto 0);
	 
	 
    -- Controller signals
    signal reset : std_logic;
    signal byte_array_256_done : std_logic;
    signal byte_array_256_en : std_logic;
    signal address_d : std_logic_vector(7 downto 0);
	  

begin

    rst_active_1 <= not KEY(3);

    -- Include the S memory structurally
    u0 : s_memory
        port map(
            address => address_w, 
            clock => CLOCK_50, 
            data => data_w, 
            wren => wren_w, 
            q => q
        );
        
    -- write your code here. As described in the slide set, this 
    -- code will drive the address, data, and wren signals to
    -- fill the memory with the values 0...255

    -- You will be likely writing this is a state machine. Ensure
    -- that after the memory is filled, you enter a DONE state which
    -- does nothing but loop back to itself. 

    ksa_data0 : ksa_data
        port map(
            clk_i                   => CLOCK_50,
            rst_i                   => rst_active_1,
            secret_key_i            => secret_key,
            byte_array_256_en_i     => byte_array_256_en,
            q_m_i                   => q_m,
            q_w_i                   => q_w,	  
            wren_w_o	            => wren_w,
            wren_d_o                => wren_d,	  
            data_w_o                => data_w,	
            data_d_o	            => data_d,
            address_w_o             => address_w,
            address_d_o             => address_d,
            address_m_o             => address_m,
            byte_array_256_done_o   => byte_array_256_done
        );	

    ksa_controller0 : ksa_controller 
        port map(
            clk_i                   => CLOCK_50,
            rst_i                   => rst_active_1,
            byte_array_256_done_i   => byte_array_256_done,
            byte_array_256_en_o     => byte_array_256_en,
            address_d_o             => address_d   
        );

end rtl;


