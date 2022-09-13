library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all;
use work.rf_constants.all;
use IEEE.numeric_std.all;
use WORK.all;

-- N,F are power of 2

entity RF_CU is
  port (CLK       : in  std_logic;
        RESET     : in  std_logic;
        CALL      : in  std_logic;
        RET       : in  std_logic;
        RD_CU     : out std_logic;
        WR_CU     : out std_logic;
        SPILL     : out std_logic;
        FILL      : out std_logic;
        RF_ENABLE : out std_logic;
        RST_RF    : out std_logic;

        --Counters signals: inputs
        CNT_SWP, CNT_CWP, CNT_SAVE, CNT_REST, CNT_SPILL_FILL : out std_logic;  --Enables
        RST_SWP, RST_CWP, RST_REST, RST_SPILL_FILL           : out std_logic;  --Resets
        UP_DWN_SWP, UP_DWN_CWP, UP_DWN_SAVE, UP_DWN_REST     : out std_logic;  --up/down
        LD_SAVE                                              : out std_logic;  -- Load

        --Counters signals: outputs
        CANSAVE, CANRESTORE, END_SF : in std_logic;

        --Mux
        SEL_WP, CPU_WORK : out std_logic);
end RF_CU;

architecture BEHAVIOR of RF_CU is

  type State_type is (reset_state, work_state, call_state1, call_state2, return_state1, return_state2, fill_state, spill_state, swp_fill_update_state
, swp_spill_update_state);
  signal current_state, next_state : State_type;




begin

------------------ NEXT STATE GENERATION NETWORK ----------------------------------
  FSM_next_state_gen : process (CALL, RET, RESET, END_SF, CANSAVE, CANRESTORE, current_state)
  begin
    --if (CLK'event and CLK = '1') then

      -- Synchronous reset
      if(RESET = '1') then next_state <= reset_state;

      else
        
        case current_state is
          when reset_state =>
            next_state <= work_state;

          when work_state =>
            if(CALL = '0') then
              if(RET = '0') then next_state           <= work_state;
              elsif(CANRESTORE = '0') then next_state <= return_state2;
              else next_state                         <= return_state1;
              end if;

            else
              if(CANSAVE = '0') then next_state <= call_state2;
              else next_state                   <= call_state1;
              end if;

            end if;

          when call_state1 => next_state <= work_state;

          when call_state2 => next_state <= spill_state;

          when return_state1 => next_state <= work_state;

          when return_state2 => next_state <= fill_state;

          when spill_state =>
            if(END_SF = '0') then next_state <= spill_state;
            else next_state                  <= swp_spill_update_state;
            end if;

          when fill_state =>
            if(END_SF = '0') then next_state <= fill_state;
            else next_state                  <= swp_fill_update_state;
            end if;

          when swp_fill_update_state => next_state <= work_state;

          when swp_spill_update_state => next_state <= work_state;

          when others => next_state <= reset_state;

        end case;
      end if;

    --end if;
    
  end process;

  ----------------------------- STATE UPDATING ----------------------------------
  FSM_State_transition : process(CLK)
  begin
    if(CLK'event and CLK = '1') then
      current_state <= next_state;
    end if;
  end process;

  ----------------------------- OUTPUT GENERATION ----------------------------------  
  FSM_outputs : process(current_state)
  begin

    --Default values
    CNT_SWP    <= '0'; CNT_CWP <= '0'; CNT_SAVE <= '0'; CNT_REST <= '0'; CNT_SPILL_FILL <= '0';  --Enables  
    RST_SWP    <= '1'; RST_CWP <= '1'; RST_REST <= '1'; RST_SPILL_FILL <= '1';  --Resets
    UP_DWN_SWP <= '1'; UP_DWN_CWP <= '1'; UP_DWN_SAVE <= '1'; UP_DWN_REST <= '1';  --up/down
    LD_SAVE    <= '0';                  -- Load

    --Mux
    SEL_WP <= '0'; CPU_WORK <= '0';

    RD_CU <= '0'; WR_CU <= '0'; SPILL <= '0'; FILL <= '0'; RF_ENABLE <= '0'; RST_RF <= '0';

    case(current_state) is

      when reset_state =>
    RST_RF         <= '1';
    RST_CWP        <= '0';
    RST_SWP        <= '0';
    RST_REST       <= '0';
    LD_SAVE        <= '1';
    RST_SPILL_FILL <= '0';

    when work_state =>
    CPU_WORK <= '1';

    when call_state1 =>
    CNT_CWP      <= '1';
    UP_DWN_SAVE <= '0';
    CNT_SAVE     <= '1';
    CNT_REST     <= '1';
    CPU_WORK <= '1';

    when call_state2 =>
    SPILL          <= '1';
    CNT_CWP        <= '1';
    RST_SPILL_FILL <= '1';
    SEL_WP         <= '1';
    CPU_WORK <= '1';

    when spill_state =>
    SPILL          <= '1';
    CNT_SPILL_FILL <= '1';
    RD_CU          <= '1';
    RF_ENABLE      <= '1';
    SEL_WP         <= '1';

    when return_state1 =>
    UP_DWN_CWP  <= '0';
    CNT_CWP      <= '1';
    CNT_SAVE     <= '1';
    UP_DWN_REST <= '0';
    CNT_REST     <= '1';
    CPU_WORK <= '1';


    when return_state2 =>
    FILL           <= '1';
    UP_DWN_CWP    <= '0';
    CNT_CWP        <= '1';
    RST_SPILL_FILL <= '0';
    CPU_WORK <= '1';

    when fill_state =>
    FILL           <= '1';
    CNT_SPILL_FILL <= '1';
    WR_CU          <= '1';
    RF_ENABLE      <= '1';

    when swp_spill_update_state =>
    SEL_WP  <= '1';
    CNT_SWP <= '1';


    when swp_fill_update_state =>
    UP_DWN_SWP <= '0';
    CNT_SWP     <= '1';

  end case;
  
end process;

end BEHAVIOR;








