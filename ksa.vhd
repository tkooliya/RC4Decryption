library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity part of the description.  Describes inputs and outputs

entity ksa is
    port(
        CLOCK_50    : in  std_logic;  -- Clock pin
        KEY         : in  std_logic_vector(3 downto 0);  -- push button switches
        SW          : in  std_logic_vector(17 downto 0);  -- slider switches
        LEDG        : out std_logic_vector(7 downto 0);  -- green lights
        LEDR        : out std_logic_vector(17 downto 0);  -- red lights
		  
		  lcd_rw : out std_logic;
		  lcd_en : out std_logic;
		  lcd_rs : out std_logic;
		  lcd_on : out std_logic;
		  lcd_blon : out std_logic;
		  lcd_data : out std_logic_vector(7 downto 0)
 );
end ksa;

-- Architecture part of the description

architecture rtl of ksa is

component ic_lcd_driver is
    port(
        print_i:	  in std_logic;
        data_i:     in std_logic_vector(7 downto 0);
        print_done_o : out std_logic;
        print_lcd_o  : out std_logic;
        lcd_en:     out std_logic;
        lcd_data:   out std_logic_vector(7 downto 0);
        lcd_rs:     out std_logic;
        lcd_rw:     out std_logic;
        lcd_on:     out std_logic;
        lcd_blon:   out std_logic;
        clk_i:   in std_logic
    );
end component;

    component s_memory is
	    port(
		    address	    : in std_logic_vector (7 downto 0);
		    clock	    : in std_logic := '1';
		    data		: in std_logic_vector (7 downto 0);
		    wren		: in std_logic;
		    q		    : out std_logic_vector (7 downto 0)
        );
    end component;

    component m_rom is
        port(
            address     : in std_logic_vector(4 downto 0);
            clock       : in std_logic;
            q           : out std_logic_vector(7 downto 0)
        );
    end component;

    component d_memory is
        port(
            address     : in std_logic_vector(4 downto 0);
            clock       : in std_logic;
            data        : in std_logic_vector(7 downto 0);
            wren        : in std_logic;
            q           : out std_logic_vector(7 downto 0)
        );
    end component;

	component ksa_controller is
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
            decrypt_write_j_o   : out std_logic;

            check_done_i        : in std_logic;
            check_fail_i        : in std_logic;
            check_last_key_i    : in std_logic;
            check_o             : out std_logic;
				
            print_done_i		  : in std_logic;
            print_o				  : out std_logic;

            done_o              : out std_logic;
            no_sol_o            : out std_logic
        );
	end component;

	component ksa_datapath is
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

            decrypt_read_i      : in std_logic;
            decrypt_read_j      : in std_logic;
            decrypt_write_i     : in std_logic;
            decrypt_write_j     : in std_logic;
            decrypt_read_k      : in std_logic;
            decrypt_write_k     : in std_logic;
            decrypt_done_o      : out std_logic;

            check_i             : in  std_logic;
            check_done_o        : out std_logic;
            check_fail_o        : out std_logic;
            check_last_key_o    : out std_logic;
				
            print_i		        : in std_logic;
            print_driver_i      : in std_logic;      

            wren_w_o            : out std_logic;
            address_w_o         : out std_logic_vector(7 downto 0);
            data_w_o            : out std_logic_vector(7 downto 0);
            q_w_i	            : in  std_logic_vector(7 downto 0);

            address_rom_o       : out std_logic_vector(4 downto 0);
            q_rom_i             : in  std_logic_vector(7 downto 0);

            wren_d_o            : out std_logic;
            address_d_o         : out std_logic_vector(4 downto 0);
            data_d_o            : out std_logic_vector(7 downto 0);
            q_d_i	            : in  std_logic_vector(7 downto 0);

            secret_key_o        : out std_logic_vector(23 downto 0)
        );
	end component;


    signal rst_active_1 : std_logic;
    signal clk          : std_logic;

    -- Memory signals
    signal wren_w       : std_logic;
    signal address_w    : std_logic_vector (7 downto 0);
    signal data_w       : std_logic_vector (7 downto 0);
    signal q_w          : std_logic_vector (7 downto 0);

    signal address_rom  : std_logic_vector(4 downto 0);
    signal q_rom        : std_logic_vector(7 downto 0);

    signal wren_d       : std_logic;
    signal address_d    : std_logic_vector (4 downto 0);
    signal data_d       : std_logic_vector (7 downto 0);
    signal q_d          : std_logic_vector (7 downto 0);

    -- Controller signals
    signal fill_done        : std_logic;
    signal fill             : std_logic;
	
    signal swap_done        : std_logic;
    signal swap_read_i      : std_logic;
    signal swap_compute_j   : std_logic;
    signal swap_read_j      : std_logic;
    signal swap_write_i     : std_logic;
    signal swap_write_j     : std_logic;

    signal decrypt_done     : std_logic;
    signal decrypt_read_i   : std_logic;
    signal decrypt_read_j   : std_logic;
    signal decrypt_write_i  : std_logic;
    signal decrypt_write_j  : std_logic;
    signal decrypt_read_k   : std_logic;
    signal decrypt_write_k  : std_logic;
	 
	 
    -- Display signals
    signal print : std_logic;
    signal print_done : std_logic;
    signal scaler : unsigned(25 downto 0);
    signal slowclk : std_logic;
    signal print_driver : std_logic;


    signal check            : std_logic;
    signal check_done       : std_logic;
    signal check_fail       : std_logic;
    signal check_last_key   : std_logic;
	 
    -- Display signals
    signal print : std_logic;
    signal print_done : std_logic;

    signal secret_key       : std_logic_vector(23 downto 0);

begin
	 
    clk <= CLOCK_50 when print = '0' else slowclk;
    rst_active_1 <= not KEY(3);

    LEDR <= secret_key(17 downto 0);

    ic_lcd_driver0 : ic_lcd_driver
        port map(
        print_i			=> print,
        data_i 			=> q_d,
        print_done_o    => print_done,
        print_lcd_o     => print_driver,
        lcd_en  		=> lcd_en,
        lcd_data        => lcd_data,
        lcd_rs  		=> lcd_rs,
        lcd_rw 		    => lcd_rw,
        lcd_on  		=> lcd_on,
        lcd_blon 		=> lcd_blon,
        clk_i 		    => clk
    );

    u0 : s_memory
        port map(
            address     => address_w,
            clock       => clk,
            data        => data_w,
            wren        => wren_w,
            q           => q_w
        );

    m_rom0 : m_rom
        port map(
            address     => address_rom,
            clock       => clk,
            q           => q_rom
        );

    d_mem0 : d_memory
        port map(
            address     => address_d,
            clock       => clk,
            data        => data_d,
            wren        => wren_d,
            q           => q_d
        );

    controller0 : ksa_controller
        port map(
            clk_i               => clk,
            rst_i               => rst_active_1,

            fill_done_i         => fill_done,
            fill_o              => fill,
            
            print_done_i		  => print_done,
            print_o				  => print,

            swap_done_i         => swap_done, 
            swap_read_i_o       => swap_read_i,
            swap_compute_j_o    => swap_compute_j,
            swap_read_j_o       => swap_read_j,
            swap_write_i_o      => swap_write_i,
            swap_write_j_o      => swap_write_j,

            decrypt_done_i      => decrypt_done,
            decrypt_read_i_o    => decrypt_read_i,
            decrypt_read_j_o    => decrypt_read_j,
            decrypt_write_i_o   => decrypt_write_i,
            decrypt_write_j_o   => decrypt_write_j,
            decrypt_read_k_o    => decrypt_read_k,
            decrypt_write_k_o   => decrypt_write_k,

            check_done_i        => check_done,
            check_fail_i        => check_fail,
            check_last_key_i    => check_last_key,
            check_o             => check,

            done_o              => LEDG(0),
            no_sol_o            => LEDG(1)
        );

    datapath0 : ksa_datapath
        port map(
            clk_i               => clk,
            rst_i               => rst_active_1,

            fill_i              => fill,
            fill_done_o         => fill_done,

            swap_read_i_i       => swap_read_i,
            swap_compute_j_i    => swap_compute_j,
            swap_read_j_i       => swap_read_j,
            swap_write_i_i      => swap_write_i,
            swap_write_j_i      => swap_write_j,
            swap_done_o         => swap_done,

            decrypt_read_i      => decrypt_read_i,
            decrypt_read_j      => decrypt_read_j,
            decrypt_write_i     => decrypt_write_i,
            decrypt_write_j     => decrypt_write_j,
            decrypt_read_k      => decrypt_read_k,
            decrypt_write_k     => decrypt_write_k,
            decrypt_done_o      => decrypt_done,

            check_i             => check,
            check_done_o        => check_done,
            check_fail_o        => check_fail,
            check_last_key_o    => check_last_key,
				
            print_i			    => print,
            print_driver_i      => print_driver,
            
            wren_w_o            => wren_w,
            address_w_o         => address_w,
            data_w_o            => data_w,
            q_w_i	              => q_w,

            address_rom_o       => address_rom,
            q_rom_i             => q_rom,

            wren_d_o            => wren_d,
            address_d_o         => address_d,
            data_d_o            => data_d,
            q_d_i	            => q_d,

            secret_key_o        => secret_key
        );	 
	 
    process(CLOCK_50, rst_active_1) begin
        if(rst_active_1 = '1') then
            scaler <= to_unsigned(0, scaler'length);
        elsif(rising_edge(CLOCK_50)) then
            scaler <= scaler + 1;
        end if;
    end process;
	 
    slowclk <= scaler(20);

end rtl;


