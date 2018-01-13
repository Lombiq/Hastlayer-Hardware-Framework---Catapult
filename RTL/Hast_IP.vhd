library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
		
package SimpleMemory is
	--Conversion functions for VHDL
	procedure SimpleMemoryWriteUInt32(variable Data: in integer; signal DataOut : out std_logic_vector);
	procedure SimpleMemoryReadUInt32(signal DataIn : in std_logic_vector; signal Data: out integer);
		
	procedure SimpleMemoryWriteBoolean(signal Data: in std_logic; signal DataOut : out std_logic_vector);
	procedure SimpleMemoryReadBoolean(signal DataIn : in std_logic_vector; variable Data: out boolean);
		
	procedure SimpleMemoryWrite4Bytes(variable Data: in integer; signal DataOut : out std_logic_vector; signal CellIndex : out std_logic_vector);
	procedure SimpleMemoryRead4Bytes(signal DataIn : in std_logic_vector; signal CellIndex : out std_logic_vector; variable Data: out integer);
		
	procedure SimpleMemoryWriteInt32(variable Data: in integer; signal DataOut : out std_logic_vector; signal CellIndex : out std_logic_vector);
	procedure SimpleMemoryReadInt32(signal DataIn : in std_logic_vector; signal CellIndex : out std_logic_vector; variable Data: out integer);
		
	procedure SimpleMemoryWriteChar(variable Data: in character; signal DataOut : out std_logic_vector; signal CellIndex : out std_logic_vector);
	procedure SimpleMemoryReadChar(signal DataIn : in std_logic_vector; signal CellIndex : out std_logic_vector; variable Data: out character);
end SimpleMemory;
		
	package body SimpleMemory is
		
	--procedure to write uint32 to memory
	procedure SimpleMemoryWriteUInt32(variable Data: in integer; signal DataOut : out std_logic_vector) is
	begin
		DataOut      <= std_logic_vector(to_signed(Data,32));
	end SimpleMemoryWriteUInt32;
	
	--procedure to read uint32 from memory
	procedure SimpleMemoryReadUInt32(signal DataIn : in std_logic_vector; signal Data: out integer) is
	begin
		Data        <= to_integer(unsigned(DataIn));
		return;
	end SimpleMemoryReadUInt32;
		
	--procedure to write boolean to memory
	procedure SimpleMemoryWriteBoolean(signal Data: in std_logic; signal DataOut : out std_logic_vector) is 
	begin
		case Data is
			when '0' => DataOut <= X"00000000";
			when '1' => DataOut <= X"11111111";
			when others => DataOut <= X"00000000";
		end case;
		return;
	end SimpleMemoryWriteBoolean;
		
	--procedure to read boolean from memory
	procedure SimpleMemoryReadBoolean(signal DataIn : in std_logic_vector; variable Data: out boolean) is 
	begin
		if (DataIn = X"00000000") then  -- Must use if then else structure instead of case becuse of "case is not a local static expression" error
			Data := FALSE;
		elsif (DataIn = X"11111111") then
			Data := TRUE;
		end if;
		--CellIndex <= std_logic_vector(to_unsigned(CellIndexIn,32));--CellIndex'length));
	end SimpleMemoryReadBoolean;
	--	
	--procedure to write 4 bytes to memory
	procedure SimpleMemoryWrite4Bytes(variable Data: in integer; signal DataOut : out std_logic_vector; signal CellIndex : out std_logic_vector) is
	begin
		--CellIndex <= std_logic_vector(to_unsigned(CellIndexIn,32)); --CellIndex'length));
	end SimpleMemoryWrite4Bytes;
		
	--procedure to read 4 bytes from memory
	procedure SimpleMemoryRead4Bytes(signal DataIn : in std_logic_vector; signal CellIndex : out std_logic_vector; variable Data: out integer) is 
	begin
		--CellIndex <= std_logic_vector(to_unsigned(CellIndexIn,32)); --CellIndex'length));
	end SimpleMemoryRead4Bytes;
		
	--procedure to write int32 to memory
	procedure SimpleMemoryWriteInt32(variable Data: in integer; signal DataOut : out std_logic_vector; signal CellIndex : out std_logic_vector) is
	begin
		DataOut      <= std_logic_vector(to_signed(Data,32));--DataOut'length));
		--CellIndex <= std_logic_vector(to_unsigned(CellIndexIn,32));--CellIndex'length));
	end SimpleMemoryWriteInt32;
		
	--procedure to read int32 from memory
	procedure SimpleMemoryReadInt32(signal DataIn : in std_logic_vector; signal CellIndex : out std_logic_vector; variable Data: out integer) is
	begin
		Data        := to_integer(signed(DataIn));
		--CellIndex <= std_logic_vector(to_unsigned(CellIndexIn,32));--CellIndex'length));
	end SimpleMemoryReadInt32;
		
	--procedure to write character to memory
	procedure SimpleMemoryWriteChar(variable Data: in character; signal DataOut : out std_logic_vector; signal CellIndex : out std_logic_vector) is
		variable Int : integer;
	begin
		case Data is
			when '0' => Int :=  0;
			when '1' => Int :=  1;
			when '2' => Int :=  2;
			when '3' => Int :=  3;
			when '4' => Int :=  4;
			when '5' => Int :=  5;
			when '6' => Int :=  6;
			when '7' => Int :=  7;
			when '8' => Int :=  8;
			when '9' => Int :=  9;
			when 'A' => Int := 10;
			when 'B' => Int := 11;
			when 'C' => Int := 12;
			when 'D' => Int := 13;
			when 'E' => Int := 14;
			when 'F' => Int := 15;
			when 'G' => Int := 16;
			when 'H' => Int := 17;
			when 'I' => Int := 18;
			when 'J' => Int := 19;
			when 'K' => Int := 20;
			when 'L' => Int := 21;
			when 'M' => Int := 22;
			when 'N' => Int := 23;
			when 'O' => Int := 24;
			when 'P' => Int := 25;
			when 'Q' => Int := 26;
			when 'R' => Int := 27;
			when 'S' => Int := 28;
			when 'T' => Int := 29;
			when 'U' => Int := 30;
			when 'V' => Int := 31;
			when 'W' => Int := 32;
			when 'X' => Int := 33;
			when 'Y' => Int := 34;
			when 'Z' => Int := 35;
			when others => Int := 0;
		end case;
			
		DataOut      <= std_logic_vector(to_signed(Int,32));--DataOut'length));
		--CellIndex <= std_logic_vector(to_unsigned(CellIndexIn,32));--CellIndex'length));
	end SimpleMemoryWriteChar;
	
	--procedure to read character from memory
	procedure SimpleMemoryReadChar(signal DataIn : in std_logic_vector; signal CellIndex : out std_logic_vector; variable Data: out character) is
		variable Charact : character;
		variable Int     : integer;
	begin
		Int := to_integer(unsigned(DataIn));
		case Int is
			when  0 => Charact := '0';
			when  1 => Charact := '1';
			when  2 => Charact := '2';
			when  3 => Charact := '3';
			when  4 => Charact := '4';
			when  5 => Charact := '5';
			when  6 => Charact := '6';
			when  7 => Charact := '7';
			when  8 => Charact := '8';
			when  9 => Charact := '9';
			when 10 => Charact := 'A';
			when 11 => Charact := 'B';
			when 12 => Charact := 'C';
			when 13 => Charact := 'D';
			when 14 => Charact := 'E';
			when 15 => Charact := 'F';
			when 16 => Charact := 'G';
			when 17 => Charact := 'H';
			when 18 => Charact := 'I';
			when 19 => Charact := 'J';
			when 20 => Charact := 'K';
			when 21 => Charact := 'L';
			when 22 => Charact := 'M';
			when 23 => Charact := 'N';
			when 24 => Charact := 'O';
			when 25 => Charact := 'P';
			when 26 => Charact := 'Q';
			when 27 => Charact := 'R';
			when 28 => Charact := 'S';
			when 29 => Charact := 'T';
			when 30 => Charact := 'U';
			when 31 => Charact := 'V';
			when 32 => Charact := 'W';
			when 33 => Charact := 'X';
			when 34 => Charact := 'Y';
			when 35 => Charact := 'Z';
			when others => Charact := '?';
		end case;
		
		Data        := Charact;
		--CellIndex <= std_logic_vector(to_unsigned(CellIndexIn,32));--CellIndex'length));
	end SimpleMemoryReadChar;
		
end SimpleMemory;

-- Hast_IP, logic generated from the input .NET assemblies starts here.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.SimpleMemory.all;
		
entity Hast_IP is
	port(
		\Clock\          : in  std_logic;
		\Reset\          : in  std_logic;
		\MemberId\       : in  integer;
		\DataIn\         : in  std_logic_vector(511 downto 0);  --\DataIn\ port's datawidth is now 512 bit
		\DataOut\        : out std_logic_vector(511 downto 0);  --\DataOut\ port's datawidth is now 512 bit
		\ReadEnable\     : out boolean;
		\WriteEnable\    : out boolean;
		\StartCellIndex\ : out integer;  --\CellIndex\ renamed to \StartCellIndex\
		\Started\        : in  boolean;
		\Finished\       : out boolean;
		\ReadsDone\      : in  boolean;
		\WritesDone\     : in  boolean
		);
end Hast_IP;
		                                                                                                  
architecture Imp of Hast_IP is                                                                                
		
		
	signal \number.param\                  : integer;
	signal IsPrimenum_number_param         : integer;
	signal ArePrimenums_number_param       : integer;
		                                   
	signal \number.iter\                   : integer;
		
	signal \result\                        : std_logic;
	signal \result_0\                      : std_logic;
	signal \result_1\                      : std_logic;
	signal \result_2\                      : std_logic;
		
	signal \PrimeCalcDataOut_0\            : std_logic;
	signal \PrimeCalcDataOut_1\            : std_logic;
	signal \PrimeCalcDataOut_2\            : std_logic;
		
	signal \Primecalc_result_0\            : std_logic;
	signal \Primecalc_result_1\            : std_logic;
	signal \Primecalc_result_2\            : std_logic;
		
	signal \num_incr\                      : integer;
	signal \num_incr_sum\                  : integer;
		                                                          
	signal StartPrimeCalculator_0          : std_logic;
	signal StartPrimeCalculator_1          : std_logic;
	signal StartPrimeCalculator_2          : std_logic;
		                                   
	signal Primecalc_Finished_0            : std_logic;
	signal Primecalc_Finished_1            : std_logic;
	signal Primecalc_Finished_2            : std_logic;
		
	--ISPRIMENUM SIGNALS
	signal IsPrimenum_ReadEna              : boolean;
	signal IsPrimenum_ReadAddr             : integer;
	signal IsPrimenum_WriteEna             : boolean;
	signal IsPrimenum_WriteAddr            : integer;
	signal IsPrimenum_DataOut              : std_logic_vector(511 downto 0);
	signal IsPrimenum_Finish               : boolean;
	signal IsPrimenum_StartPrimeCalc_0     : std_logic;
	signal IsPrimenum_StartPrimeCalc_1     : std_logic;
	signal IsPrimenum_StartPrimeCalc_2     : std_logic;
		
	signal IsPrimenum_Primecalc_instance   : std_logic_vector(7 downto 0);
	signal IsPrimenum_FinishedPrimecalc    : std_logic;
		
	--AREPRIMENUMS SIGNALS
	signal ArePrimenums_ReadEna            : boolean;
	signal ArePrimenums_ReadAddr           : integer;
	signal ArePrimenums_Read_IntAddr       : integer;
	signal ArePrimenums_WriteEna           : boolean;
	signal ArePrimenums_WriteAddr          : integer;
	--signal ArePrimenums_Write_IntAddr      : integer;
	signal ArePrimenums_DataOut            : std_logic_vector(511 downto 0);
	signal ArePrimenums_Finish             : boolean;
	signal ArePrimenums_StartPrimeCalc_0   : std_logic;   
	signal ArePrimenums_StartPrimeCalc_1   : std_logic; 
	signal ArePrimenums_StartPrimeCalc_2   : std_logic; 
		
	signal ArePrimenums_Primecalc_instance : std_logic_vector(7 downto 0);
	signal ArePrimenums_FinishedPrimecalc  : std_logic;
		
	signal \PC0_num2\            : integer range -1048576 to 1048575;
	signal \PC0_num\             : integer range -1048576 to 1048575;
	signal \PC0_number\          : integer range -1048576 to 1048575;
	signal \PC0_PrimeCalcDataIn\ : integer;
	signal \PC0_op\              : integer range -1048576 to 1048575;
		  
	signal First_slot_finished   : std_logic; 
	signal alma : std_logic_vector(2 downto 0);
		
	--SM_Primecalc_0 state machine states
	type SM_Primecalculator_0 is (
					ST000_Primecalculator_0,
					ST001_Primecalculator_0,
					ST002_Primecalculator_0,
					ST002a_Primecalculator_0,
					ST002b_Primecalculator_0,
					ST002c_Primecalculator_0,
					ST003_Primecalculator_0,
					ST003d0_Primecalculator_0,
					ST003d1_Primecalculator_0,
					ST003d2_Primecalculator_0,
					ST003d3_Primecalculator_0,
					ST004_Primecalculator_0,
					ST005_Primecalculator_0,
					ST006_Primecalculator_0,
					ST006y_Primecalculator_0,
					ST007_Primecalculator_0,
					ST008_Primecalculator_0,
					ST009_Primecalculator_0
					); 
	signal state_SM_Primecalculator_0 : SM_Primecalculator_0; 
		
	--SM_Primecalc_1 state machine states
	type SM_Primecalculator_1 is (
					ST000_Primecalculator_1,
					ST001_Primecalculator_1,
					ST002_Primecalculator_1,
					ST003_Primecalculator_1,
					ST004_Primecalculator_1,
					ST005_Primecalculator_1,
					ST006_Primecalculator_1,
					ST007_Primecalculator_1,
					ST008_Primecalculator_1,
					ST009_Primecalculator_1
					); 
	signal state_SM_Primecalculator_1 : SM_Primecalculator_1; 
		
	--SM_Primecalc_2 state machine states
	type SM_Primecalculator_2 is (
					ST000_Primecalculator_2,
					ST001_Primecalculator_2,
					ST002_Primecalculator_2,
					ST003_Primecalculator_2,
					ST004_Primecalculator_2,
					ST005_Primecalculator_2,
					ST006_Primecalculator_2,
					ST007_Primecalculator_2,
					ST008_Primecalculator_2,
					ST009_Primecalculator_2
					); 
	signal state_SM_Primecalculator_2 : SM_Primecalculator_2; 
		  
	--SM_IsPrimeNumber state machine states
	type SM_IsPrimeNumber is (
					ST000_IsPrimeNumber,
					ST001_IsPrimeNumber,
					ST002a_IsPrimeNumber,
					ST002b_IsPrimeNumber,
					ST002c_IsPrimeNumber,
					ST002d_IsPrimeNumber,
					ST002e_IsPrimeNumber,
					ST002f_IsPrimeNumber,
					ST003_IsPrimeNumber,
					ST004_IsPrimeNumber
					); 
	signal state_SM_IsPrimeNumber : SM_IsPrimeNumber; 
		
	--SM_ArePrimeNumbers state machine states
	type SM_ArePrimeNumbers is (
					ST000_ArePrimeNumbers,
					ST001_ArePrimeNumbers,
					ST002_ArePrimeNumbers,
					ST003_ArePrimeNumbers,
					ST004_ArePrimeNumbers,
					ST005a_ArePrimeNumbers,
					ST005b_ArePrimeNumbers,
					ST005c_ArePrimeNumbers,
					ST005d_ArePrimeNumbers,
					ST005e_ArePrimeNumbers,
					ST005f_ArePrimeNumbers,
					ST006_ArePrimeNumbers,  
					ST007_ArePrimeNumbers,
					ST007x_ArePrimeNumbers,
					ST008_ArePrimeNumbers,
					ST008x_ArePrimeNumbers, 
					ST009_ArePrimeNumbers
					); 
	signal state_SM_ArePrimeNumbers : SM_ArePrimeNumbers; 
		
		
--: Original PrimeCalc:
--------------------------

-- This is the original version of the PrimeCalc procedure. Now it is deprecated, as its function is now implemented with SM_Primecalculator_x State machine.

		
	--procedure \PrimeCalc\(Signal \Clock\ : In  std_logic; Signal \Reset\ : In std_logic; Variable \PrimeCalcDataIn\ : In natural; Variable \PrimeCalcDataOut\ : Out boolean) is
	--	Variable \number\ : natural;
	--	Variable \num\    : natural;
	--	Variable \num2\   : natural;
	--	Variable \result\ : boolean;
	--begin
	--	\number\     := \PrimeCalcDataIn\;--\number.param\;
	--	\num\        := \number\ / 2;
	--	\num2\       := 2;
	--	\PrimeCalcDataOut\ := \result\;
	--	while \num2\ <= \num\ loop
	--		if (\number\ mod \num2\ = 0) then
	--			\result\ := False;
	--			\PrimeCalcDataOut\ := \result\;
	--			return;
	--		end if; 
	--		\num2\ := \num2\ + 1;
	--	end loop;
	--	\result\ := True;
	--	\PrimeCalcDataOut\ := \result\;
	--	return;
	--end procedure;
		
begin
		
	------------------------------------
	-- SM_Primecalculator_0 STATE MACHINE --
	------------------------------------
	-- @Andris:
	-- http://stackoverflow.com/questions/21653831/vhdl-variable-vs-signal-behaviour-in-queue
	-- http://www.sigasi.com/content/vhdls-crown-jewel
		  
	STM_Primecalculator_0: process (\Clock\)
	begin
		if (rising_edge(\Clock\)) then
			if \Reset\ = '1' then
				state_SM_Primecalculator_0 <= ST000_Primecalculator_0;
				\PC0_num2\ <= 0;
				\PC0_num\  <= 0;
				\PC0_number\ <= 0;
				\PC0_PrimeCalcDataIn\ <= 0;
			else
				case (state_SM_Primecalculator_0) is
					
					when ST000_Primecalculator_0 =>
						Primecalc_Finished_0 <= '0';
						if StartPrimeCalculator_0 = '1' then
							state_SM_Primecalculator_0 <= ST001_Primecalculator_0;
						end if; 
						
					when ST001_Primecalculator_0 =>
						\PC0_PrimeCalcDataIn\ <= \number.param\;
						state_SM_Primecalculator_0 <= ST002a_Primecalculator_0;
						
					when ST002a_Primecalculator_0 =>
						\PC0_number\ <= \PC0_PrimeCalcDataIn\;
						state_SM_Primecalculator_0 <= ST002b_Primecalculator_0;
					
					when ST002b_Primecalculator_0 =>
						\PC0_num2\ <= 2;  
						state_SM_Primecalculator_0 <= ST002c_Primecalculator_0;
						
					when ST002c_Primecalculator_0 =>
						\PrimeCalcDataOut_0\ <= \Primecalc_result_0\;
						state_SM_Primecalculator_0 <= ST003_Primecalculator_0;
						
					when ST003_Primecalculator_0 =>
						\PC0_num\    <= \PC0_number\ / 2;
						state_SM_Primecalculator_0 <= ST003d0_Primecalculator_0;
						
					when ST003d0_Primecalculator_0 =>
						\PC0_op\ <= \PC0_number\ / \PC0_num2\;
						state_SM_Primecalculator_0 <= ST003d1_Primecalculator_0;
						
					when ST003d1_Primecalculator_0 =>
						\PC0_op\ <= \PC0_op\ * \PC0_num2\;
						state_SM_Primecalculator_0 <= ST003d2_Primecalculator_0;
						
					when ST003d2_Primecalculator_0 =>
						\PC0_op\ <= \PC0_number\ - \PC0_op\;
						state_SM_Primecalculator_0 <= ST003d3_Primecalculator_0;
						
					when ST003d3_Primecalculator_0 =>
						if (not (\PC0_op\ /= 0)) then
							state_SM_Primecalculator_0 <= ST004_Primecalculator_0;
						else
							state_SM_Primecalculator_0 <= ST006_Primecalculator_0;
						end if;
						
					--when ST003x_Primecalculator_0 =>
					--	if (not (\PC0_number\ mod \PC0_num2\ /= 0)) then
					--		state_SM_Primecalculator_0 <= ST004_Primecalculator_0;
					--	else
					--		state_SM_Primecalculator_0 <= ST006_Primecalculator_0;
					--	end if;
						
					when ST004_Primecalculator_0 =>
						\Primecalc_result_0\ <= '0';
						state_SM_Primecalculator_0 <= ST005_Primecalculator_0;
						
					when ST005_Primecalculator_0 =>
						\PrimeCalcDataOut_0\ <= \Primecalc_result_0\;
						state_SM_Primecalculator_0 <= ST008_Primecalculator_0;
						
					when ST006_Primecalculator_0 =>
						\PC0_num2\ <= \PC0_num2\ + 1;
						state_SM_Primecalculator_0 <= ST006y_Primecalculator_0;
					
					when ST006y_Primecalculator_0 =>
						if \PC0_num2\ <= \PC0_num\ then
							state_SM_Primecalculator_0 <= ST003_Primecalculator_0;
						else 
							state_SM_Primecalculator_0 <= ST007_Primecalculator_0;
						end if;
						
					when ST007_Primecalculator_0 =>
						\Primecalc_result_0\ <= '1';
						state_SM_Primecalculator_0 <= ST005_Primecalculator_0;
						
					when ST008_Primecalculator_0 =>
						\result_0\ <= \PrimeCalcDataOut_0\;
						state_SM_Primecalculator_0 <= ST009_Primecalculator_0;  
						
					when ST009_Primecalculator_0 =>  
						Primecalc_Finished_0 <= '1';                              
						state_SM_Primecalculator_0 <= ST000_Primecalculator_0;  
						     
					when others => null;  
					                                     
				end case;
			end if;
		end if;                                                      
	end process;                                                       
	----------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------
		
		
	------------------------------------
	-- SM_Primecalculator_1 STATE MACHINE --
	------------------------------------
		  
	STM_Primecalculator_1: process (\Clock\)
		variable \num2\            : natural;
		variable \num\             : natural;
		variable \number\          : natural;
		variable \PrimeCalcDataIn\ : integer;
	begin
		if (rising_edge(\Clock\)) then
			if \Reset\ = '1' then
				state_SM_Primecalculator_1 <= ST000_Primecalculator_1;
			else
				case (state_SM_Primecalculator_1) is
					
					when ST000_Primecalculator_1 =>
						Primecalc_Finished_1 <= '0';
						if StartPrimeCalculator_1 = '1' then
							state_SM_Primecalculator_1 <= ST001_Primecalculator_1; 
						end if;
						
					when ST001_Primecalculator_1 =>
						\PrimeCalcDataIn\ := \number.param\;
						state_SM_Primecalculator_1 <= ST002_Primecalculator_1;
						
					when ST002_Primecalculator_1 =>
						\number\ := \PrimeCalcDataIn\;
						\num2\   := 2;  
						\PrimeCalcDataOut_1\ <= \Primecalc_result_1\;
						state_SM_Primecalculator_1 <= ST003_Primecalculator_1;
						
					when ST003_Primecalculator_1 =>
						\num\    := \number\ /2;
						if (not (\number\ mod \num2\ /= 0)) then
							state_SM_Primecalculator_1 <= ST004_Primecalculator_1;
						else
							state_SM_Primecalculator_1 <= ST006_Primecalculator_1;
						end if;
						
					when ST004_Primecalculator_1 =>
						\Primecalc_result_1\ <= '0';
						state_SM_Primecalculator_1 <= ST005_Primecalculator_1;
						
					when ST005_Primecalculator_1 =>
						\PrimeCalcDataOut_1\ <= \Primecalc_result_1\;
						state_SM_Primecalculator_1 <= ST008_Primecalculator_1;
						
					when ST006_Primecalculator_1 =>
						\num2\ := \num2\ + 1;
						if \num2\ <= \num\ then
							state_SM_Primecalculator_1 <= ST003_Primecalculator_1;
						else 
							state_SM_Primecalculator_1 <= ST007_Primecalculator_1;
						end if;
						
					when ST007_Primecalculator_1 =>
						\Primecalc_result_1\ <= '1';
						state_SM_Primecalculator_1 <= ST005_Primecalculator_1;
						
					when ST008_Primecalculator_1 =>
						\result_1\ <= \PrimeCalcDataOut_1\;
						state_SM_Primecalculator_1 <= ST009_Primecalculator_1;  
						
					when ST009_Primecalculator_1 =>  
						Primecalc_Finished_1 <= '1';                             
						state_SM_Primecalculator_1 <= ST000_Primecalculator_1;   
						     
					when others => null;         
					                              
				end case; 
			end if;  
		end if;                                                   
	end process;                                                       
		
	----------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------
		
	------------------------------------
	-- SM_Primecalculator_2 STATE MACHINE --
	------------------------------------
		  
	STM_Primecalculator_2: process (\Clock\)
		variable \num2\            : natural;
		variable \num\             : natural;
		variable \number\          : natural;
		variable \PrimeCalcDataIn\ : integer;
	begin
		if (rising_edge(\Clock\)) then
			if \Reset\ = '1' then
				state_SM_Primecalculator_2 <= ST000_Primecalculator_2;
			else
				case (state_SM_Primecalculator_2) is
					
					when ST000_Primecalculator_2 =>
						Primecalc_Finished_2 <= '0';
						if StartPrimeCalculator_2 = '1' then
							state_SM_Primecalculator_2 <= ST001_Primecalculator_2; 
						end if;
						
					when ST001_Primecalculator_2 =>
						\PrimeCalcDataIn\ := \number.param\;
						state_SM_Primecalculator_2 <= ST002_Primecalculator_2;
						
					when ST002_Primecalculator_2 =>
						\number\ := \PrimeCalcDataIn\;
						\num2\   := 2;  
						\PrimeCalcDataOut_2\ <= \Primecalc_result_2\;
						state_SM_Primecalculator_2 <= ST003_Primecalculator_2;
						
					when ST003_Primecalculator_2 =>
						\num\    := \number\ /2;
						if (not (\number\ mod \num2\ /= 0)) then
							state_SM_Primecalculator_2 <= ST004_Primecalculator_2;
						else
							state_SM_Primecalculator_2 <= ST006_Primecalculator_2;
						end if;
						
					when ST004_Primecalculator_2 =>
						\Primecalc_result_2\ <= '0';
						state_SM_Primecalculator_2 <= ST005_Primecalculator_2;
						
					when ST005_Primecalculator_2 =>
						\PrimeCalcDataOut_2\ <= \Primecalc_result_2\;
						state_SM_Primecalculator_2 <= ST008_Primecalculator_2;
						
					when ST006_Primecalculator_2 =>
						\num2\ := \num2\ + 1;
						if \num2\ <= \num\ then
							state_SM_Primecalculator_2 <= ST003_Primecalculator_2;
						else 
							state_SM_Primecalculator_2 <= ST007_Primecalculator_2;
						end if;
						
					when ST007_Primecalculator_2 =>
						\Primecalc_result_2\ <= '1';
						state_SM_Primecalculator_2 <= ST005_Primecalculator_2;
						
					when ST008_Primecalculator_2 =>
						\result_2\ <= \PrimeCalcDataOut_2\;
						state_SM_Primecalculator_2 <= ST009_Primecalculator_2;  
						
					when ST009_Primecalculator_2 =>    
						Primecalc_Finished_2 <= '1';                           
						state_SM_Primecalculator_2 <= ST000_Primecalculator_2; 
						       
					when others => null;    
					                                   
				end case; 
			end if;
		end if;                                                     
	end process;                                                       
		
	----------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------
		
	------------------------------------
	-- SM_IsPrimeNumber STATE MACHINE --
	------------------------------------
		  
	STM_IsPrimeNumber: process (\Clock\)
	begin
		if (rising_edge(\Clock\)) then
			if \Reset\ = '1' then
				state_SM_IsPrimeNumber <= ST000_IsPrimeNumber;
				IsPrimenum_Finish             <= false;
				IsPrimenum_WriteEna           <= false;
				IsPrimenum_WriteAddr          <= 0;
				IsPrimenum_ReadEna            <= false;
				IsPrimenum_ReadAddr           <= 0;
				IsPrimenum_StartPrimeCalc_0   <= '0';
				IsPrimenum_StartPrimeCalc_1   <= '0';
				IsPrimenum_StartPrimeCalc_2   <= '0';
				IsPrimenum_DataOut            <= X"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
				IsPrimenum_number_param       <= 0;
				IsPrimenum_Primecalc_instance <= x"00";
			else
				case (state_SM_IsPrimeNumber) is
						
					when ST000_IsPrimeNumber =>
						IsPrimenum_WriteEna         <= false;
						IsPrimenum_StartPrimeCalc_0 <= '0';
						IsPrimenum_StartPrimeCalc_1 <= '0';
						IsPrimenum_StartPrimeCalc_2 <= '0';
						if \MemberId\ = 1 and \Started\ = true and IsPrimenum_Finish = false then
								state_SM_IsPrimeNumber <= ST001_IsPrimeNumber;
								IsPrimenum_ReadEna <= true;
								IsPrimenum_ReadAddr <= 0;
								IsPrimenum_Finish  <= false;
						else 
								IsPrimenum_ReadEna  <= false;
						end if;
						
					--@Andris: removed dummy cycle
						
					when ST001_IsPrimeNumber => 
						SimpleMemoryReadUInt32(\DataIn\(95 downto 64), IsPrimenum_number_param);  
						IsPrimenum_DataOut <= \DataIn\; 
						if \ReadsDone\ = true then --Wait until \ReadsDone\
							IsPrimenum_ReadEna <= false;
							if state_SM_Primecalculator_0 = ST000_Primecalculator_0 then
								state_SM_IsPrimeNumber <= ST002a_IsPrimeNumber;
							elsif (state_SM_Primecalculator_1 = ST000_Primecalculator_1) then
								state_SM_IsPrimeNumber <= ST002c_IsPrimeNumber;
							elsif (state_SM_Primecalculator_2 = ST000_Primecalculator_2) then
								state_SM_IsPrimeNumber <= ST002e_IsPrimeNumber;
							end if;
						end if;
						                                                                                                               
					when ST002a_IsPrimeNumber =>
						IsPrimenum_StartPrimeCalc_0 <= '1';  
						IsPrimenum_Primecalc_instance <= x"00";
						state_SM_IsPrimeNumber <= ST002b_IsPrimeNumber;
						
					when ST002b_IsPrimeNumber =>
						IsPrimenum_StartPrimeCalc_0 <= '0'; 
						if IsPrimenum_FinishedPrimecalc = '1' then
							state_SM_IsPrimeNumber <= ST003_IsPrimeNumber;
						end if;
						
					when ST002c_IsPrimeNumber =>
						IsPrimenum_StartPrimeCalc_1 <= '1';  
						IsPrimenum_Primecalc_instance <= x"01";
						state_SM_IsPrimeNumber <= ST002d_IsPrimeNumber;
						
					when ST002d_IsPrimeNumber =>
						IsPrimenum_StartPrimeCalc_1 <= '0';
						if IsPrimenum_FinishedPrimecalc = '1' then
							state_SM_IsPrimeNumber <= ST003_IsPrimeNumber;
						end if;
						
					when ST002e_IsPrimeNumber =>
						IsPrimenum_StartPrimeCalc_2 <= '1';  
						IsPrimenum_Primecalc_instance <= x"02";
						state_SM_IsPrimeNumber <= ST002f_IsPrimeNumber;
						
					when ST002f_IsPrimeNumber =>
						IsPrimenum_StartPrimeCalc_2 <= '0';
						if IsPrimenum_FinishedPrimecalc = '1' then
							state_SM_IsPrimeNumber <= ST003_IsPrimeNumber;
						end if;
						
					when ST003_IsPrimeNumber =>
						SimpleMemoryWriteBoolean(\result\, IsPrimenum_DataOut(95 downto 64));
						IsPrimenum_WriteAddr <= 0;
						IsPrimenum_WriteEna <= true;
						state_SM_IsPrimeNumber <= ST004_IsPrimeNumber;
						
					--@Andris: removed dummy cycle 
						
					when ST004_IsPrimeNumber =>
						if \WritesDone\ = true then --Wait until \WritesDone\
							IsPrimenum_Finish   <= true;
							IsPrimenum_WriteEna <= false;
						end if;
						
						if \Started\ = false then -- Wait for Started to be pulled back to 0
							state_SM_IsPrimeNumber <= ST000_IsPrimeNumber;
							IsPrimenum_Finish  <= false;
						end if;
						                 
					when others => null;   
						                                    
				end case;     
			end if;
		end if;                                                 
	end process;                                                       
		
	----------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------
		
	--------------------------------------
	-- SM_ArePrimeNumbers STATE MACHINE --
	--------------------------------------
		  
	STM_ArePrimeNumbers: process (\Clock\)
		variable NumOfElements : integer;
	begin
		if (rising_edge(\Clock\)) then
			if \Reset\ = '1' then
				state_SM_ArePrimeNumbers <= ST000_ArePrimeNumbers;
				ArePrimenums_Finish             <= false;
				ArePrimenums_WriteEna           <= false; 
				ArePrimenums_WriteAddr          <= 0;
				ArePrimenums_ReadEna            <= false;
				ArePrimenums_ReadAddr           <= 0;
				ArePrimenums_StartPrimeCalc_0   <= '0';
				ArePrimenums_StartPrimeCalc_1   <= '0';
				ArePrimenums_StartPrimeCalc_2   <= '0';
				\num_incr\                      <= 0;
				\num_incr_sum\                  <= 0;
				\number.iter\                   <= 0;
				ArePrimenums_DataOut            <= X"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
				ArePrimenums_number_param       <= 0;
				ArePrimenums_Primecalc_instance <= x"00";
				First_slot_finished             <= '0';
			else
				case (state_SM_ArePrimeNumbers) is
					when ST000_ArePrimeNumbers =>
						ArePrimenums_WriteEna         <= false;
						ArePrimenums_StartPrimeCalc_0 <= '0';
						ArePrimenums_StartPrimeCalc_1 <= '0';
						ArePrimenums_StartPrimeCalc_2 <= '0';
						\num_incr\ <= 0;
						\num_incr_sum\ <= 0;
						if \MemberId\ = 2 and \Started\ = true and ArePrimenums_Finish = false then
								\num_incr_sum\ <= \num_incr_sum\ + 1;
								state_SM_ArePrimeNumbers <= ST001_ArePrimeNumbers;
								ArePrimenums_ReadEna  <= true;
								ArePrimenums_ReadAddr <= 0;
								ArePrimenums_Finish   <= false;
						else 
								ArePrimenums_ReadEna  <= false;
						end if;
						
					--@Andris: removed dummy cycle
						
					when ST001_ArePrimeNumbers =>
						SimpleMemoryReadUInt32(\DataIn\(63 downto 32), \number.iter\);
						if \ReadsDone\ = true then --Wait until \ReadsDone\
							ArePrimenums_ReadEna <= false;
							\num_incr_sum\ <= \num_incr_sum\ + 1;
							state_SM_ArePrimeNumbers <= ST002_ArePrimeNumbers;
						end if;
						
					when ST002_ArePrimeNumbers =>
						NumOfElements            :=  \number.iter\;
						state_SM_ArePrimeNumbers <= ST003_ArePrimeNumbers; 
						ArePrimenums_DataOut  <= \DataIn\;
						
					when ST003_ArePrimeNumbers =>  
						if (ArePrimenums_Read_IntAddr <= 15 and First_slot_finished = '0') then  
							ArePrimenums_Read_IntAddr <= 2 + 1 + \num_incr\;
							ArePrimenums_ReadEna  <= false;
							state_SM_ArePrimeNumbers <= ST004_ArePrimeNumbers;
						elsif (ArePrimenums_Read_IntAddr <= 15 and First_slot_finished = '1') then
							ArePrimenums_Read_IntAddr <= \num_incr\;
							ArePrimenums_ReadEna <= false;
							state_SM_ArePrimeNumbers <= ST004_ArePrimeNumbers;
						else
							\num_incr\ <= 0;
							ArePrimenums_ReadAddr <= ArePrimenums_ReadAddr + 64;
							ArePrimenums_Read_IntAddr <= 0;
							ArePrimenums_ReadEna  <= true;
							First_slot_finished <= '1';
							state_SM_ArePrimeNumbers <= ST004_ArePrimeNumbers;
						end if;
						
					when ST004_ArePrimeNumbers =>
						if \ReadsDone\ = true then --Wait until \ReadsDone\
							if First_slot_finished = '0' then
								
								--This format works in Vivado and iSim, but not in Altera-Modelsim, however Quartus can synthesize it. Using the function's content instead of it in the following lines
								---------------
								--SimpleMemoryReadUInt32(\DataIn\((3 + \num_incr\) * 32 - 1 downto (2 + \num_incr\) * 32), ArePrimenums_number_param);
								ArePrimenums_number_param <= to_integer(unsigned(\DataIn\((3 + \num_incr\) * 32 - 1 downto (2 + \num_incr\) * 32)));
								---------------
								
							elsif First_slot_finished = '1' then
								
								--This format works in Vivado and iSim, but not in Altera-Modelsim, however Quartus can synthesize it. Using the function's content instead of it in the following lines
								---------------                                                                                                                                                         
								--SimpleMemoryReadUInt32(\DataIn\((1 + \num_incr\) * 32 - 1 downto \num_incr\ * 32), ArePrimenums_number_param);
								ArePrimenums_number_param <= to_integer(unsigned(\DataIn\((1 + \num_incr\) * 32 - 1 downto \num_incr\ * 32)));
								---------------
								
							end if;
							ArePrimenums_ReadEna <= false;
							if state_SM_Primecalculator_0 = ST000_Primecalculator_0 then
								state_SM_ArePrimeNumbers <= ST005a_ArePrimeNumbers;
							elsif (state_SM_Primecalculator_1 = ST000_Primecalculator_1) then
								state_SM_ArePrimeNumbers <= ST005c_ArePrimeNumbers;
							elsif (state_SM_Primecalculator_2 = ST000_Primecalculator_2) then
								state_SM_ArePrimeNumbers <= ST005e_ArePrimeNumbers;
							end if;  
						end if;    
						
					when ST005a_ArePrimeNumbers =>
						ArePrimenums_StartPrimeCalc_0   <= '1';  
						ArePrimenums_Primecalc_instance <= x"00";
						state_SM_ArePrimeNumbers   <= ST005b_ArePrimeNumbers;
						
					when ST005b_ArePrimeNumbers =>
						ArePrimenums_StartPrimeCalc_0 <= '0';
						if ArePrimenums_FinishedPrimecalc = '1' then
							if NumOfElements < 16 then
								state_SM_ArePrimeNumbers <= ST006_ArePrimeNumbers;
							elsif ((NumOfElements > 16) and (First_slot_finished = '0')) then
								state_SM_ArePrimeNumbers <= ST007_ArePrimeNumbers;
							elsif ((NumOfElements > 16) and (First_slot_finished = '1')) then
								state_SM_ArePrimeNumbers <= ST008_ArePrimeNumbers;
							end if;
						end if;
						
					when ST005c_ArePrimeNumbers =>
						ArePrimenums_StartPrimeCalc_1   <= '1'; 
						ArePrimenums_Primecalc_instance <= x"01";
						state_SM_ArePrimeNumbers <= ST005d_ArePrimeNumbers;
						
					when ST005d_ArePrimeNumbers =>
						ArePrimenums_StartPrimeCalc_1 <= '0';
						if ArePrimenums_FinishedPrimecalc = '1' then
							state_SM_ArePrimeNumbers <= ST006_ArePrimeNumbers;
						end if;
						
					when ST005e_ArePrimeNumbers =>
						ArePrimenums_StartPrimeCalc_2   <= '1'; 
						ArePrimenums_Primecalc_instance <= x"02";
						state_SM_ArePrimeNumbers <= ST005f_ArePrimeNumbers;
						
					when ST005f_ArePrimeNumbers =>
						ArePrimenums_StartPrimeCalc_2   <= '0';
						if ArePrimenums_FinishedPrimecalc = '1' then
							state_SM_ArePrimeNumbers <= ST006_ArePrimeNumbers;
						end if;
						
					when ST006_ArePrimeNumbers =>  
					--When we want to process less than one memory slot of data (512 bits)      
						if (\num_incr\ < NumOfElements) then
							--This format works in Vivado and iSim, but not in Altera-Modelsim, however Quartus can synthesize it. Using the function's content instead of it in the following lines
							---------------                                                                                                                                                         
							--SimpleMemoryWriteBoolean(\result\, ArePrimenums_DataOut((3 + \num_incr\) * 32 - 1 downto (2 + \num_incr\) * 32));                                                     
							case \result\ is                                                                                                                                                        
								when '0'    => ArePrimenums_DataOut((3 + \num_incr\) * 32 - 1 downto (2 + \num_incr\) * 32) <= X"00000000";                                                               
								when '1'    => ArePrimenums_DataOut((3 + \num_incr\) * 32 - 1 downto (2 + \num_incr\) * 32) <= X"11111111";                                                               
								when others => ArePrimenums_DataOut((3 + \num_incr\) * 32 - 1 downto (2 + \num_incr\) * 32) <= X"00000000";                                                            
							end case;                                                                                                                                                               
							--------------                                                                                                                                                          
							\num_incr\               <= \num_incr\ + 1;                                                                                                                                           
							--\num_incr_sum\           <= \num_incr_sum\ + 1;                                                                                                                                   
							ArePrimenums_WriteEna    <= false;                   
							state_SM_ArePrimeNumbers <= ST003_ArePrimeNumbers;
						elsif (\num_incr\ = NumOfElements) then
							ArePrimenums_WriteEna <= true;  
							if \WritesDone\ = true then                        
								ArePrimenums_WriteEna <= false;                   
								state_SM_ArePrimeNumbers <= ST009_ArePrimeNumbers;                                    
							end if;                                                                  
						end if;
						
					when ST007_ArePrimeNumbers => 
					--When we want to process more than one memory slot of data (512 bits), and this is the first slot
						if (\num_incr_sum\ < 15) then
							--This format works in Vivado and iSim, but not in Altera-Modelsim, however Quartus can synthesize it. Using the function's content instead of it in the following lines
							---------------                                                                                                                                                         
							--SimpleMemoryWriteBoolean(\result\, ArePrimenums_DataOut((3 + \num_incr\) * 32 - 1 downto (2 + \num_incr\) * 32));                                                     
							case \result\ is                                                                                                                                                        
								when '0'    => ArePrimenums_DataOut((3 + \num_incr\) * 32 - 1 downto (2 + \num_incr\) * 32) <= X"00000000";                                                               
								when '1'    => ArePrimenums_DataOut((3 + \num_incr\) * 32 - 1 downto (2 + \num_incr\) * 32) <= X"11111111";                                                               
								when others => ArePrimenums_DataOut((3 + \num_incr\) * 32 - 1 downto (2 + \num_incr\) * 32) <= X"00000000";                                                            
							end case;                                                                                                                                                               
							--------------                                                                                                                                                          
							\num_incr\               <= \num_incr\ + 1;                                                                                                                                           
							\num_incr_sum\           <= \num_incr_sum\ + 1;                                                                                                                                   
							ArePrimenums_WriteEna    <= false;                
							state_SM_ArePrimeNumbers <= ST003_ArePrimeNumbers;
							
						elsif (\num_incr_sum\ = 15) then
							case \result\ is                                                                                                                                                        
								when '0'    => ArePrimenums_DataOut((3 + \num_incr\) * 32 - 1 downto (2 + \num_incr\) * 32) <= X"00000000";                                                               
								when '1'    => ArePrimenums_DataOut((3 + \num_incr\) * 32 - 1 downto (2 + \num_incr\) * 32) <= X"11111111";                                                               
								when others => ArePrimenums_DataOut((3 + \num_incr\) * 32 - 1 downto (2 + \num_incr\) * 32) <= X"00000000";                                                            
							end case;                                                                                                                                                               
							--------------                                                                                                                                                          
							\num_incr\               <= \num_incr\ + 1;                                                                                                                                           
							\num_incr_sum\           <= \num_incr_sum\ + 1;
							
							--ArePrimenums_WriteAddr   <= ArePrimenums_WriteAddr + 64;
							ArePrimenums_WriteEna    <= true;  
							--if \WritesDone\ = true then                           
							--	ArePrimenums_WriteEna <= false;                      
								state_SM_ArePrimeNumbers <= ST007x_ArePrimeNumbers; --ST003_ArePrimeNumbers;                         
							--end if;                                               
						end if;
							
					when ST007x_ArePrimeNumbers =>
						if \WritesDone\ = true then                           
							ArePrimenums_WriteEna <= false;    
							ArePrimenums_WriteAddr <= ArePrimenums_WriteAddr + 64;                  
							state_SM_ArePrimeNumbers <= ST003_ArePrimeNumbers;                         
						end if;   
							
					when ST008_ArePrimeNumbers =>
					--When we want to process more than one memory slot of data (512 bits), and this is not the first slot
					--if ((\num_incr\ < 16) and (\num_incr\ < NumOfElements - 14)) then
					if ((\num_incr\ < 15) and (\num_incr_sum\ < NumOfElements +2)) then
						--This format works in Vivado and iSim, but not in Altera-Modelsim, however Quartus can synthesize it. Using the function's content instead of it in the following lines
						---------------                                                                                                                                                         
						--SimpleMemoryWriteBoolean(\result\, ArePrimenums_DataOut((1 + \num_incr\) * 32 - 1 downto (\num_incr\) * 32));                                                         
						case \result\ is                                                                                                                                                        
							when '0' => ArePrimenums_DataOut((1 + \num_incr\) * 32 - 1 downto (\num_incr\) * 32) <= X"00000000";                                                                   
							when '1' => ArePrimenums_DataOut((1 + \num_incr\) * 32 - 1 downto (\num_incr\) * 32) <= X"11111111";                                                                   
							when others => ArePrimenums_DataOut((1 + \num_incr\) * 32 - 1 downto (\num_incr\) * 32) <= X"00000000";                                                                
						end case;                                                                                                                                                               
						-------------- 
						\num_incr\               <= \num_incr\ + 1;       
						\num_incr_sum\           <= \num_incr_sum\ + 1;   
						ArePrimenums_WriteEna    <= false;                
						state_SM_ArePrimeNumbers <= ST003_ArePrimeNumbers; 
						alma <= "001";
					elsif ((\num_incr\ = 15) and (\num_incr_sum\ < NumOfElements +2)) then    
						ArePrimenums_WriteAddr <= ArePrimenums_WriteAddr + 64;
						ArePrimenums_WriteEna <= true;    
						alma <= "010";
						if \WritesDone\ = true then  
							ArePrimenums_WriteEna <= false;                    
							state_SM_ArePrimeNumbers <= ST003_ArePrimeNumbers; 
						end if;
					elsif (\num_incr_sum\ = NumOfElements +2) then    
					alma <= "011";
						ArePrimenums_DataOut(511 downto (NumOfElements - 14) * 32) <= \DataIn\(511 downto (NumOfElements -14) * 32);                                                                                                           
						--ArePrimenums_WriteAddr <= ArePrimenums_WriteAddr + 64;
						ArePrimenums_WriteEna <= true; 
						--if \WritesDone\ = true then  
						--	ArePrimenums_WriteEna <= false;                    
							state_SM_ArePrimeNumbers <= ST008x_ArePrimeNumbers; --ST009_ArePrimeNumbers; 
						--end if;  
					end if; 
					
					when ST008x_ArePrimeNumbers =>
						if \WritesDone\ = true then  
							ArePrimenums_WriteEna <= false; 
							ArePrimenums_WriteAddr <= ArePrimenums_WriteAddr + 64;                                                                                                                                            
							state_SM_ArePrimeNumbers <= ST009_ArePrimeNumbers;
						end if; 
						
					when ST009_ArePrimeNumbers =>
						ArePrimenums_Finish   <= true;
						if \Started\ = false then -- Wait for Started to be pulled back to 0
							state_SM_ArePrimeNumbers <= ST000_ArePrimeNumbers;
							ArePrimenums_Finish   <= false;
						end if;
						   
					when others => null;   
					                                    
				end case; 
			end if;    
		end if;                                          
	end process;                                                      
		
		
-- Signal assignments:
--------------------------
		
	\number.param\                 <= IsPrimenum_number_param      when \MemberId\ = 1 else ArePrimenums_number_param;
		
-- These go to the outpit ports of Hast_IP.vhd.
		
	\ReadEnable\                   <= IsPrimenum_ReadEna           when \MemberId\ = 1 else ArePrimenums_ReadEna; 
	\WriteEnable\                  <= IsPrimenum_WriteEna          when \MemberId\ = 1 else ArePrimenums_WriteEna;
		
-- \StartCellIndex\ will set Hast_IP_Read_Addr_out in case of \ReadEnable\ = '1' or Hast_IP_Write_Addr_out in case of \WriteEnable\ = '1'. This has been made in the Hast_ip_wrapper.vhd,
-- in the Read_Write_Address_Choice process.  
		
	\StartCellIndex\            <= IsPrimenum_ReadAddr          when \MemberId\ = 1 and IsPrimenum_ReadEna    = true else
								   IsPrimenum_WriteAddr         when \MemberId\ = 1 and IsPrimenum_WriteEna   = true else
								   ArePrimenums_ReadAddr        when \MemberId\ = 2 and ArePrimenums_ReadEna  = true else
								   ArePrimenums_WriteAddr       when \MemberId\ = 2 and ArePrimenums_WriteEna = true; 
	--\StartCellIndex\          <= IsPrimenum_WriteAddr         when \MemberId\ = 1 else ArePrimenums_WriteAddr;
		
-- These go to the output ports of Hast_IP.vhd.
		
	\DataOut\                      <= IsPrimenum_DataOut           when \MemberId\ = 1 else ArePrimenums_DataOut;
	\Finished\                     <= IsPrimenum_Finish            when \MemberId\ = 1 else ArePrimenums_Finish;
		
-- StartPrimeCalculator_0 is controlled by the other State Machines' states (SM_IsPrimeNumber or SM_ArePrimeNumbers based on \MemberId\). 
-- As there are 3 SM_Primecalculator_x State Machines, we have to use separate StartPrimeCalculator_x signals (If we used the same signal, Vivado would throw an error message which says "multiple driven signal...")
-- The SM_IsPrimeNumber and SM_ArePrimeNumbers State machines also have to set different signals, othervise it leads to an error. 
-- So IsPrimenum_StartPrimeCalc_x are set by SM_IsPrimeNumber states, and ArePrimenums_StartPrimeCalc_x are set by SM_ArePrimeNumbers State Machine.
		
	StartPrimeCalculator_0         <= IsPrimenum_StartPrimeCalc_0  when \MemberId\ = 1 else ArePrimenums_StartPrimeCalc_0;
	StartPrimeCalculator_1         <= IsPrimenum_StartPrimeCalc_1  when \MemberId\ = 1 else ArePrimenums_StartPrimeCalc_1;
	StartPrimeCalculator_2         <= IsPrimenum_StartPrimeCalc_2  when \MemberId\ = 1 else ArePrimenums_StartPrimeCalc_2;
		
-- Primecalc_Finished_x signs that the SM_Primecalculator_x finished with its operation. This is needed for the SM_IsPrimeNumber and SM_ArePrimeNumbers 
-- State Machines (based on MethodID) to go to the next state. 
-- As there are multiple "instances" of SM_Primecalculator_x, and both SM_IsPrimeNumber or SM_ArePrimeNumbers can "start" them, we have to know which instance runs (IsPrimenum_Primecalc_instance), and when it finished (Primecalc_Finished_0)
		
	IsPrimenum_FinishedPrimecalc   <= Primecalc_Finished_0 when \MemberId\ = 1 and IsPrimenum_Primecalc_instance = x"00" else
									  Primecalc_Finished_1 when \MemberId\ = 1 and IsPrimenum_Primecalc_instance = x"01" else
									  Primecalc_Finished_2 when \MemberId\ = 1 and IsPrimenum_Primecalc_instance = x"02" else '0';
		
	ArePrimenums_FinishedPrimecalc <= Primecalc_Finished_0 when \MemberId\ = 2 and ArePrimenums_Primecalc_instance = x"00" else           
									  Primecalc_Finished_1 when \MemberId\ = 2 and ArePrimenums_Primecalc_instance = x"01" else
									  Primecalc_Finished_2 when \MemberId\ = 2 and ArePrimenums_Primecalc_instance = x"02" else '0';
		
-- \result\ comes from one of the three SM_Primecalculator_x State Machines' \result_x\ signal. We run the same SM_Primecalculator_x State Machine when ie. the 
-- IsPrimenum_Primecalc_instance = x"00" or ArePrimenums_Primecalc_instance = x"00", so we have to assign the \result_0\ to \result\.
		  
	\result\                       <= \result_0\ when IsPrimenum_Primecalc_instance = x"00" or ArePrimenums_Primecalc_instance = x"00" else
									  \result_1\ when IsPrimenum_Primecalc_instance = x"01" or ArePrimenums_Primecalc_instance = x"01" else
									  \result_2\ when IsPrimenum_Primecalc_instance = x"02" or ArePrimenums_Primecalc_instance = x"02" else '0'; 
									  
		
end Imp;                                                      
                                                                                      
                                                              
                                  