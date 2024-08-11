----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.05.2024 17:44:41
-- Design Name: 
-- Module Name: top - Behavioral
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
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    Port ( clk_i : in STD_LOGIC;
           red_o : out STD_LOGIC_VECTOR (3 downto 0):="0000";
           green_o : out STD_LOGIC_VECTOR (3 downto 0):="0000";
           blue_o : out STD_LOGIC_VECTOR (3 downto 0):="0000";
           hsync_o : out STD_LOGIC;
           vsync_o : out STD_LOGIC;
           sw5_i : in STD_LOGIC;
           sw6_i : in STD_LOGIC;
           sw7_i : in STD_LOGIC;
           btn_i : in STD_LOGIC_VECTOR (3 downto 0));
end top;

architecture Behavioral of top is --ILOSC ADRESOW - (54+4*16)+(256*96)/2 , OMINAC 118 ADRESOW
signal red : std_logic:='0';  --adresy od 0 do 12405
signal blue : std_logic:='0';  --proba implementacji maszyny stanow z wyjsciem synchronicznym [maszyny stanów (6)]
signal green : std_logic:='0';
signal addra : std_logic_vector(13 downto 0):="00000001110101";
signal douta : std_logic_vector(7 downto 0);


signal dataBuffer: std_logic_vector(5 downto 0);
signal divided_freq: std_logic:='0';
signal WorkFlow: std_logic_vector(1 downto 0):="00"; --MSB horizontal, LSB vertical, 1 - image, 0 - frame --pozbyc sie
signal addraAdd: std_logic_vector(13 downto 0):="00000001110110";


type StateType is (idle, ProcFrame, ProcImage);
signal current_state: StateType:=idle;
signal next_state : StateType:=idle; --pozbyc sie

component vga_bitmap
port (
clka: IN std_logic;
addra: IN std_logic_VECTOR(13 downto 0);
douta: OUT std_logic_VECTOR(7 downto 0));
end component;



begin

bitmapa : vga_bitmap 
port map (
clka => clk_i,
addra => addra,
douta => douta);
    divider: process(clk_i)
    variable N: INTEGER:=4;
    variable counter: INTEGER:=0;
    begin
    if rising_edge(clk_i) then  
    if counter=N/2-1 then
    counter:=0;
    divided_freq <= not divided_freq;
    else 
    counter:=counter+1;
    end if;
    end if;
    end process;


seq: process(divided_freq)


variable horCounter : INTEGER:=0;
variable verCounter: INTEGER:=0;
variable verSetFrame: boolean:=false;
variable horSetFrame: boolean:=false;
variable bufferCounter: INTEGER RANGE 0 to 2:=0; 
variable imageLineCounter: INTEGER:=0;
variable verShift: INTEGER:=0;
variable horShift: INTEGER:=0;
variable delayShift: INTEGER:=0;

constant horCountLimit : INTEGER:= 800;
constant horSync_Off : INTEGER:= 112;
constant horSync_On : INTEGER:=16;
constant horVisibleArea: INTEGER:=160;
constant horFrameArea: INTEGER:=410; --poprawic, nie wszystko ma byc w ramce
constant horImageStart: INTEGER:=432;
constant horImageStop: INTEGER:=528; 
constant horShiftLimit: INTEGER:=160;




constant verCountLimit : INTEGER:=525;
constant verSync_Off: INTEGER:=12;
constant verSync_On: INTEGER:=10;
constant vervisibleArea: INTEGER:=45;
constant verFrameArea: INTEGER:=45;
constant verImageStart: INTEGER:=100;
constant verImageStop: INTEGER:=196;
constant verShiftLimit: INTEGER:=45;

begin
if rising_edge(divided_freq) then
    horCounter:=horCounter+1;
        if horCounter=horSync_On then --hsync on - 16tick (front porch)
        hsync_o<='1';
        end if;
        if horCounter=horSync_Off then --hsync off - 112tick (sync pulse)
        hsync_o<='0';
        end if;
        if horCounter=horvisiblearea then
        current_state <= idle;
        end if;
        if horCounter=horFrameArea+horShift then -- visible area check - 160tick
        horSetFrame:=true;
        end if;
        if horCounter=horCountLimit then --end of line - 800tick
        horCounter:=0;
        current_state<=idle;
        verCounter:=verCounter+1;
        horSetFrame:=false;
        verSetFrame:=false;
        end if;
        if horCounter=horImageStart+horShift then
        WorkFlow(1)<= '1';
        end if;
        if horCounter=horImageStop+horShift then
        WorkFlow(1)<='0';
        end if;
        
        
        if verCounter=verSync_On then --vsync on - 10 tick
        vsync_o<='1';
        end if;
        if verCounter=verSync_Off then -- vsync off - 12 tick
        vsync_o<='0';
        end if;
        if vercounter=verVisibleArea then
        current_state<=idle;
        end if;
        if verCounter=verFrameArea+verShift then  -- visible area check - 45tick
        verSetFrame:=true;
        end if;
        if verCounter=verCountLimit then --
        verCounter:=0;
        addra<="00000001110101";
        end if;
        if verCounter=verImageStart+verShift then
        WorkFlow(0)<='1';
        end if;
        if verCounter=verImageStop+verShift then
        WorkFlow(0)<='0';
        end if;
        
         --ustawianie rysowania ramki 
        
      
        
        
      
      
case current_state is 
       when ProcFrame =>
                red<=sw5_i;
                green<=sw6_i;
                blue<=sw7_i;
                if WorkFlow = "11" then
                current_state<=ProcImage;
                end if;
                if (horCounter>(horImageStop+(horImageStart-horFrameArea))) and (verCounter>(verImageStop+(verImageStart-verFrameArea))) then --gdy trafimy poza ramke 
                current_state<=idle;
                end if; 
      when ProcImage=>
            
            if addra="11000001110110" then
            addra<="00000001110101";
            end if;
            
            horSetFrame:=false;
           verSetFrame:=false;
           imageLineCounter:=imageLineCounter+1;
                    if bufferCounter=2 then
                        addra<=addraAdd;
                        bufferCounter:=0;
                    end if;
                    if bufferCounter=0 then
           
                            if (addra<"11000001110110" and addra>"00000001110101") and imageLineCounter<97 then 
                            dataBuffer<= douta(7 downto 5) & douta(3 downto 1);
                            WorkFlow<="00";
                            else
                            current_state<=ProcFrame;
                            end if;
                    red<=dataBuffer(5);
                    green<=dataBuffer(4);
                    blue<=dataBuffer(3);
                    end if;
                  if bufferCounter=1 then
                        red<=dataBuffer(2);
                        green<=dataBuffer(1);
                        blue<=dataBuffer(0);
                  end if;
           when idle =>
                red<='0';
                green<='0';
                blue<='0';
                if horSetFrame and verSetFrame then
                current_state <= ProcFrame;
                
                end if;
end case; 

case btn_i is
    when "1000" =>
       delayShift:=delayShift+1;
            if delayShift=20000000 then
                verShift:=verShift+1;
            end if;
    when "0100" =>
        delayShift:=delayShift+1;
            if delayShift= 20000000  then   
                verShift:=verShift-1;
            end if;
    when "0010" =>
         delayShift:=delayShift+1;
            if delayShift=20000000 then
            horShift:=horShift+1;
            end if;
    when "0001" =>
        delayShift:=delayShift+1;
            if delayShift=20000000 then
            horShift:=horShift-1;
            end if;
    when "0000" =>
        delayShift:=0;
    when others =>
        null;
    end case;
 
if abs(horShift)>horShiftLimit then --czy wartosc wychodzi poza granice
horShift:=horShiftLimit;
end if;

if abs(verShift)>verShiftLimit then --czy wartosc wychodzi poza granice
verShift:=verShiftLimit;
end if;
 
    
red_o <= red & red & red & red;
blue_o <= blue & blue & blue & blue;
green_o <= green & green & green & green; 

--current_state<=next_state;
addraAdd<=addra+1;

end if;
end process seq;




--machine_state: process(current_state)

   
--begin
    
  --  case current_state is 
    --    when idle=>
      --  next_state<=ProcFrame;
        --when ProcFrame=>
          --  if WorkFlow = "11" then
            --next_state <= ProcImage;
           -- else
           -- next_state<= ProcFrame;
            --WorkFlow<=
       --when ProcImage =>
            
            
            

--end process;




end Behavioral;
