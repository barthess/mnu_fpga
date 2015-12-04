
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

--***********************************Entity Declaration*******************************
entity MGT_USRCLK_SOURCE_PLL is
generic
(
    MULT                : integer           := 2;
    DIVIDE              : integer           := 2;    
    FEEDBACK            : string            := "CLKFBOUT";    
    CLK_PERIOD          : real              := 6.26;    
    OUT0_DIVIDE         : integer           := 2;
    OUT1_DIVIDE         : integer           := 2;
    OUT2_DIVIDE         : integer           := 2;
    OUT3_DIVIDE         : integer           := 2  
);
port
( 
    CLK0_OUT           : out std_logic;
    CLK1_OUT           : out std_logic;
    CLK2_OUT           : out std_logic;
    CLK3_OUT           : out std_logic;
    CLK_IN             : in  std_logic;
    CLKFB_IN           : in  std_logic;
    CLKFB_OUT          : out std_logic;
    PLL_LOCKED_OUT     : out std_logic;
    PLL_RESET_IN       : in  std_logic
);


end MGT_USRCLK_SOURCE_PLL;

architecture RTL of MGT_USRCLK_SOURCE_PLL is
--*********************************Wire Declarations**********************************

    signal   tied_to_ground_vec_i :   std_logic_vector(15 downto 0);
    signal   tied_to_ground_i     :   std_logic;
    signal   tied_to_vcc_i        :   std_logic;
    signal   clkout0_i            :   std_logic;
    signal   clkout1_i            :   std_logic;
    signal   clkout2_i            :   std_logic;
    signal   clkout3_i            :   std_logic;    

begin

--*********************************** Beginning of Code *******************************

    -- Instantiate a PLL module to divide the reference clock. Uses internal feedback
    -- for improved jitter performance, and to avoid consuming an additional BUFG
    pll_adv_i  : PLL_BASE
    generic map
    (
         CLKFBOUT_MULT   =>  MULT,
         DIVCLK_DIVIDE   =>  DIVIDE,
         CLK_FEEDBACK    =>  FEEDBACK,
         CLKFBOUT_PHASE  =>  0.0,
         COMPENSATION    =>  "SYSTEM_SYNCHRONOUS", 
         CLKIN_PERIOD   =>  CLK_PERIOD,
         CLKOUT0_DIVIDE  =>  OUT0_DIVIDE,
         CLKOUT0_PHASE   =>  0.0,
         CLKOUT1_DIVIDE  =>  OUT1_DIVIDE,
         CLKOUT1_PHASE   =>  0.0,
         CLKOUT2_DIVIDE  =>  OUT2_DIVIDE,
         CLKOUT2_PHASE   =>  0.0,
         CLKOUT3_DIVIDE  =>  OUT3_DIVIDE,
         CLKOUT3_PHASE   =>  0.0         
    )
    port map
    (
         CLKIN          =>  CLK_IN,
         CLKFBIN         =>  CLKFB_IN,
         CLKOUT0         =>  clkout0_i,
         CLKOUT1         =>  clkout1_i,
         CLKOUT2         =>  clkout2_i,
         CLKOUT3         =>  clkout3_i,
         CLKOUT4         =>  open,
         CLKOUT5         =>  open,
         CLKFBOUT        =>  CLKFB_OUT,
         LOCKED          =>  PLL_LOCKED_OUT,
         RST             =>  PLL_RESET_IN
    );
    
    
    clkout0_bufg_i  :  BUFG   
    port map
    (
        O      =>    CLK0_OUT, 
        I      =>    clkout0_i
    );   

end RTL;
 
