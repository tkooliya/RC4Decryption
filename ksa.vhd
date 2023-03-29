library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity part of the description.  Describes inputs and outputs

entity ksa is
    port(
        CLOCK_50    : in  std_logic;  -- Clock pin
        KEY         : in  std_logic_vector(3 downto 0);  -- push button switches
        SW          : in  std_logic_vector(15 downto 0);  -- slider switches
        LEDG        : out std_logic_vector(7 downto 0);  -- green lights
        LEDR        : out std_logic_vector(17 downto 0)  -- red lights
    );
end ksa;

-- Architecture part of the description

architecture rtl of ksa is

    component s_memory is
	    port(
		    address	    : in std_logic_vector (7 downto 0);
		    clock	    : in std_logic := '1';
		    data		: in std_logic_vector (7 downto 0);
		    wren		: in std_logic;
		    q		    : out std_logic_vector (7 downto 0)
        );
    end component;

	component ksa_controller is
		 port(
			  clk_i       : in  std_logic;
			  rst_i       : in  std_logic;
			  fill_done_i : in  std_logic;
			  fill_o      : out std_logic;
			  
			  swap_done_i : in  std_logic; 
			  swap_read_i_o : out std_logic;
			  swap_compute_j_o  : out std_logic;
			  swap_write_i_o  : out std_logic;
			  swap_write_j_o  : out std_logic
		 );
	end component;

	component ksa_datapath is
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
	end component;


    signal rst_active_1 : std_logic;

    -- RAM signals
	signal address  : std_logic_vector (7 downto 0);
	signal data     : std_logic_vector (7 downto 0);
	signal wren     : std_logic;
	signal q        : std_logic_vector (7 downto 0);

   -- Controller signals
   signal fill_done : std_logic;
   signal fill : std_logic;
	
   signal swap_done : std_logic;
   signal swap_read_i: std_logic;
	signal swap_compute_j : std_logic;
	signal swap_write_i : std_logic;
	signal swap_write_j : std_logic;

begin

    rst_active_1 <= not KEY(3);

    u0 : s_memory
        port map(
            address,
            CLOCK_50,
            data,
            wren,
            q
        );

    controller0 : ksa_controller
        port map(
            clk_i       => CLOCK_50,
            rst_i       => rst_active_1,
            fill_done_i => fill_done,
            fill_o      => fill,
				swap_done_i => swap_done, 
			   swap_read_i_o => swap_read_i,
			   swap_compute_j_o => swap_compute_j,
			   swap_write_i_o  => swap_write_i,
			   swap_write_j_o  => swap_write_j
        );

    datapath0 : ksa_datapath
        port map(
            clk_i       => CLOCK_50,
            rst_i       => rst_active_1,
				q_i 				=> q,
            fill_i      => fill,
            fill_done_o => fill_done,
				swap_read_i_i => swap_read_i,
		      swap_compute_j_i => swap_compute_j,
		      swap_write_i_i  => swap_write_i,
		      swap_write_j_i => swap_write_j,
				swap_done_o => swap_done,
            wren_o      => wren,
            address_o   => address,
            data_o      => data
        );

end rtl;


