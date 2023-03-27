library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ksa_tb is

end ksa_tb;

architecture stimulus of ksa_tb is

	component ksa is
   port(CLOCK_50 : in  std_logic;  -- Clock pin
       KEY : in  std_logic_vector(3 downto 0);  -- push button switches
       SW : in  std_logic_vector(15 downto 0);  -- slider switches
		 LEDG : out std_logic_vector(7 downto 0);  -- green lights
		 LEDR : out std_logic_vector(17 downto 0));  -- red lights
	end component;
	
	
	
	
	signal clk : std_logic := '0';
	signal KEY : std_logic_vector(3 downto 0);
	signal SW :  std_logic_vector(15 downto 0);  -- slider switches
	signal LEDG : std_logic_vector(7 downto 0);  -- green lights
	signal LEDR : std_logic_vector(17 downto 0);  -- red lights

	
begin
 
	DUT: ksa port map(CLOCK_50 => clk, KEY => KEY, SW => SW, LEDG => LEDG, LEDR => LEDR);
   clk <= not clk after 20ns;
	
end stimulus;


