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

    component s_memory IS
	    PORT
        (
		    address	    : in std_logic_vector (7 downto 0);
		    clock	    : in std_logic := '1';
		    data		: in std_logic_vector (7 downto 0);
		    wren		: in std_logic;
		    q		    : out std_logic_vector (7 downto 0)
        );
    end component;
	
    -- State signals
	type state_t is (
        RESET, 
        FILL,
        DONE
    );
	signal curr_state : state_t;
    signal next_state : state_t;

    signal fill_o : std_logic;

    -- RAM signals
	signal address  : std_logic_vector (7 downto 0);
	signal data     : std_logic_vector (7 downto 0);
	signal wren     : std_logic;
	signal q        : std_logic_vector (7 downto 0);

    signal rst_active_1 : std_logic;

    signal i_r : unsigned(7 downto 0);

	begin

        rst_active_1 <= not KEY(3);

	    -- Include the S memory structurally
        u0 : s_memory
            port map (
	            address,
                CLOCK_50,
                data,
                wren,
                q
            );

    process(CLOCK_50, rst_active_1) begin
        if(rst_active_1 = '1') then
            curr_state <= RESET;
        elsif(rising_edge(CLOCK_50)) then
            curr_state <= next_state;
        end if;
    end process;

    -- next_state logic
    process(curr_state, i_r) begin
        next_state <= curr_state;

        case curr_state is
            when RESET =>
                next_state <= FILL;
            
            when FILL =>
                if(i_r = 255) then
                    next_state <= DONE;
                end if;
            
            when others =>
        end case;
    end process;

    fill_o <= '1' when (curr_state = FILL) else '0';
    wren <= fill_o;

    -- Index register
    process(CLOCK_50, rst_active_1) begin
        if(rst_active_1 = '1') then
            i_r <= to_unsigned(0, i_r'length);
        elsif(rising_edge(CLOCK_50)) then
            if(fill_o = '1') then
                i_r <= i_r + to_unsigned(1, i_r'length);
            else
                i_r <= to_unsigned(0, i_r'length);
            end if;
        end if;
    end process;

    address <= std_logic_vector(i_r);
    data    <= address;

end rtl;


