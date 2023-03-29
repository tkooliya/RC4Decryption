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
	    port
        (
		    address	    : in std_logic_vector (7 downto 0);
		    clock	    : in std_logic := '1';
		    data		: in std_logic_vector (7 downto 0);
		    wren		: in std_logic;
		    q		    : out std_logic_vector (7 downto 0)
        );
    end component;

    component ksa_controller is
        port
        (
            clk_i       : in  std_logic;
            rst_i       : in  std_logic;
            fill_done_i : in  std_logic;
            fill_o      : out std_logic
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

    signal index_r : unsigned(7 downto 0);

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

    controller0 : ksa_controller
        port map(
            clk_i       => CLOCK_50,
            rst_i       => rst_active_1,
            fill_done_i => fill_done,
            fill_o      => fill
        );

    -- Index register
    process(CLOCK_50, rst_active_1) begin
        if(rst_active_1 = '1') then
            index_r <= to_unsigned(0, index_r'length);
        elsif(rising_edge(CLOCK_50)) then
            if(fill = '1') then
                index_r <= index_r + to_unsigned(1, index_r'length);
            else
                index_r <= to_unsigned(0, index_r'length);
            end if;
        end if;
    end process;

    fill_done <= '1' when (index_r = 255) else '0';

    wren    <= fill;
    address <= std_logic_vector(index_r);
    data    <= address;

end rtl;


