library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ic_lcd_driver is
    port(
		  print_i:	  in std_logic;
		  data_i:     in std_logic_vector(7 downto 0);
		  print_done_o : out std_logic;
		--  clear_done_o will need to add to begin reading address since it begins during the INIT state of LCD
        lcd_en:     out std_logic;
        lcd_data:   out std_logic_vector(7 downto 0);
        lcd_rs:     out std_logic;
        lcd_rw:     out std_logic;
        lcd_on:     out std_logic;
        lcd_blon:   out std_logic;

        CLOCK_50:   in std_logic
    );
end entity;

architecture structure of ic_lcd_driver is


    type macro_state_t is (
        RESET,
        INIT,
        PRINT,
        NEW_LINE,
        CLEAR
    );

        
    -- Macro State
    signal curr_macro_state: macro_state_t := RESET;
    signal next_macro_state: macro_state_t;

        
    -- INIT macro State
    -- Sends initialization commands
    constant    INIT_NUM_INSTRS: unsigned(2 downto 0) := to_unsigned(5, 3);
	 
    type        init_instr_arr_t is array (0 to to_integer(INIT_NUM_INSTRS) - 1) of std_logic_vector(7 downto 0);
	 
    constant    INIT_INSTR_ARR: init_instr_arr_t := (
        0 => "00111000", -- 0x38
        1 => "00001100", -- 0x0C
        2 => "00000001", -- 0x01
        3 => "00000110", -- 0x06
        4 => "10000000"  -- 0x80
    );
	 
    signal  init_done:              std_logic;
    signal  init_instr_idx:         unsigned(2 downto 0) := to_unsigned(0, 3);
    signal  next_init_instr_idx:    unsigned(2 downto 0);
    signal  lcd_init_data:          std_logic_vector(7 downto 0);


    -- PRINT macro state
    -- Prints the 5 characters in the order specified by signal dir
    constant    NUM_CHARS: unsigned(2 downto 0) := to_unsigned(5, 3);
    type        char_arr_t is array (0 to to_integer(NUM_CHARS) - 1) of std_logic_vector(7 downto 0);
    constant    CHAR_ARR: char_arr_t := (
        0 => "01001001",    -- I
        1 => "01000001",    -- A
        2 => "01001110",    -- N
        3 => "01000011",    -- C
        4 => "01010010"     -- R
    );
    signal  char_idx:           unsigned(7 downto 0) := to_unsigned(0, 8);
    signal  next_char_idx:      unsigned(7 downto 0);
    signal  cursor_x:           unsigned(3 downto 0) := to_unsigned(0, 4); -- 0 to 15
    signal  next_cursor_x:      unsigned(3 downto 0);
    signal  cursor_y:           std_logic := '0';
    signal  next_cursor_y:      std_logic;



    -- NEW_LINE macro state
    -- Sets the cursor position to 0 on the second line
    -- Only 1 cycle so no done signal needed
    constant    NEW_LINE_CMD:       std_logic_vector(7 downto 0) := "11000000";
    signal      lcd_new_line_data:  std_logic_vector(7 downto 0);


    -- CLEAR macro state
    -- Clears the display and sets the cursor position to 0 on the first line
    -- Uses initialization instructions 2 and 4
    signal lcd_clear_data:          std_logic_vector(7 downto 0);
    signal clear_instr_idx:         std_logic; -- Only 2 instructions, so binary index
    signal next_clear_instr_idx:    std_logic;
    signal clear_done:              std_logic;


begin


    -- LCD Port logic
    lcd_en      <= CLOCK_50;
    lcd_rw      <= '0';
    lcd_on      <= '1';
    lcd_blon    <= '1';
    lcd_rs      <= '1' when curr_macro_state = PRINT else '0'; -- can use lcd_rs to skip init and row change when reading q
    lcd_data    <=  lcd_init_data       when curr_macro_state = INIT else
                    data_i              when curr_macro_state = PRINT else -- need to change
                    lcd_new_line_data   when curr_macro_state = NEW_LINE else
						  "00000000";
                


    -- Macro state control
    process(CLOCK_50) begin
        if(rising_edge(CLOCK_50)) then
            curr_macro_state <= next_macro_state;
        end if;
    end process;

    process(curr_macro_state, init_done, clear_done, print_i, cursor_x, cursor_y) begin
        case curr_macro_state is
            when RESET =>
					 print_done_o <= '0';
					 if(print_i = '1') then
						  next_macro_state <= INIT;
					 else
						  next_macro_state <= RESET;
					 end if;

            when INIT =>
					 print_done_o <= '0';
                if(init_done = '1') then
                    next_macro_state <= PRINT;
                else
                    next_macro_state <= INIT;
                end if;

            when PRINT =>
					 print_done_o <= '0';
                if(cursor_x = 15) then
                    if(cursor_y = '0') then
                        next_macro_state <= NEW_LINE;
                    else
                        next_macro_state <= CLEAR;
                    end if;
                else
                    next_macro_state <= PRINT;
                end if;

            when NEW_LINE =>
					print_done_o <= '0';
					next_macro_state <= PRINT;
                    
            when CLEAR =>
					print_done_o <= '1';
               next_macro_state <= CLEAR;
					
        end case;
    end process;


    -- INIT state control
    process(CLOCK_50) begin
        if(rising_edge(CLOCK_50)) then
            init_instr_idx <= next_init_instr_idx;
        end if;
    end process;

    next_init_instr_idx <=   init_instr_idx + to_unsigned(1, 3) when
                                (curr_macro_state = INIT) and (init_instr_idx < (INIT_NUM_INSTRS - 1))
                                else
                            init_instr_idx;

    init_done       <= '1' when (init_instr_idx = (INIT_NUM_INSTRS - 1)) else '0';
    lcd_init_data   <= INIT_INSTR_ARR(to_integer(init_instr_idx));


    -- PRINT state control
    process(CLOCK_50) begin
        if(rising_edge(CLOCK_50)) then
            cursor_y <= next_cursor_y;
            cursor_x <= next_cursor_x;
        end if;
    end process;


    next_cursor_y <=    not cursor_y when 
                            (curr_macro_state = PRINT) and (cursor_x = 15)
                            else
                        cursor_y;

    next_cursor_x <=    cursor_x + to_unsigned(1, 4) when
                            (curr_macro_state = PRINT) and (cursor_x < 15)
                            else
                        to_unsigned(0, 4) when
                            (curr_macro_state = PRINT) and (cursor_x >= 15)
                            else
                        cursor_x;

	

    -- NEW_LINE state control
    lcd_new_line_data <= NEW_LINE_CMD;


end architecture;