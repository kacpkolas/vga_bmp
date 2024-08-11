----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.05.2024 21:51:54
-- Design Name: 
-- Module Name: tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb is
--  Port ( );
end tb;

architecture Behavioral of tb is
component top is
    Port ( clk_i : in STD_LOGIC;
           red_o : out STD_LOGIC_VECTOR (3 downto 0):="0000";
           green_o : out STD_LOGIC_VECTOR (3 downto 0):="0000";
           blue_o : out STD_LOGIC_VECTOR (3 downto 0):="0000";
           hsync_o : out STD_LOGIC:='0';
           vsync_o : out STD_LOGIC:='0';
           sw5_i : in STD_LOGIC:='1';
           sw6_i : in STD_LOGIC:='0';
           sw7_i : in STD_LOGIC:='1';
           btn_i : in STD_LOGIC_VECTOR (3 downto 0):="0000");
end  component top;
signal clk_i : std_logic:='0';
signal red_o : std_logic_vector(3 downto 0);
signal green_o : std_logic_vector(3 downto 0);
signal blue_o : std_logic_vector(3 downto 0);
signal hsync_o: std_logic:='0';
signal vsync_o: std_logic:='0';
signal sw5_i : std_logic:='1';
signal sw6_i : std_logic:='0';
signal sw7_i : std_logic:='1';
signal btn_i : std_logic_vector(3 downto 0):="0000";

begin

dut: top port map(
clk_i=>clk_i,
red_o => red_o,
green_o => green_o,
blue_o => blue_o,
hsync_o => hsync_o,
vsync_o => vsync_o,
sw5_i => sw5_i,
sw6_i => sw6_i,
sw7_i => sw7_i,
btn_i => btn_i

);

clk_i <= not clk_i after 5ns;
process
begin

wait;
end process;


end Behavioral;