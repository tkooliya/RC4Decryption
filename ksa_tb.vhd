library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ksa_tb is

end ksa_tb;

architecture stimulus of ksa_tb is

	component ksa is
        port(
            CLOCK_50    : in  std_logic;  -- Clock pin
            KEY         : in  std_logic_vector(3 downto 0); -- push button switches
            SW          : in  std_logic_vector(17 downto 0); -- slider switches
            LEDG        : out std_logic_vector(7 downto 0); -- green lights
            LEDR        : out std_logic_vector(17 downto 0); -- red lights
				
			  lcd_rw : out std_logic;
			  lcd_en : out std_logic;
			  lcd_rs : out std_logic;
			  lcd_on : out std_logic;
			  lcd_blon : out std_logic;
			  lcd_data : out std_logic_vector(7 downto 0)
        );
	end component;
	
	signal clk  : std_logic := '1';
	signal KEY  : std_logic_vector(3 downto 0) := "0000";
	signal SW   : std_logic_vector(17 downto 0);
	signal LEDG : std_logic_vector(7 downto 0);
	signal LEDR : std_logic_vector(17 downto 0);
	signal lcd_rw : std_logic;
	signal lcd_en : std_logic;
	signal lcd_rs : std_logic;
	signal lcd_on : std_logic;
	signal lcd_blon : std_logic;
	signal lcd_data : std_logic_vector(7 downto 0);
	
begin
 
	DUT : ksa
        port map(
            CLOCK_50 => clk,
            KEY => KEY,
            SW => SW,
            LEDG => LEDG,
            LEDR => LEDR,
				lcd_rw => lcd_rw,
				lcd_en => lcd_en,
				lcd_rs => lcd_rs,
				lcd_on => lcd_on,
				lcd_blon => lcd_blon,
				lcd_data => lcd_data
        );

    clk <= not clk after 5 ns;

    process begin
        KEY(3) <= '0';

        wait for 10 ns;

        KEY(3) <= '1';

        SW <= "110101111100111100"; -- Message 1

        wait;
    end process;
	
end stimulus;


