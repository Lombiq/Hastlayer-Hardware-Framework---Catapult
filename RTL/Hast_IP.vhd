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
		
entity Hast_ip is
	port(
		\Clock\          : in  std_logic;
		\Reset\          : in  std_logic;
		\MemberId\       : in  integer;
		\DataIn\         : in  std_logic_vector(511 downto 0);  --\DataIn\ port's datawidth is now 512 bit
		\DataOut\        : out std_logic_vector(511 downto 0);  --\DataOut\ port's datawidth is now 512 bit
		\ReadEnable\     : out boolean;
		\WriteEnable\    : out boolean;
		\CellIndex\      : out integer; 
		\Started\        : in  boolean;
		\Finished\       : out boolean;
		\ReadsDone\      : in  boolean;
		\WritesDone\     : in  boolean
		);
end Hast_ip;
		                                                                                                  
architecture Imp of Hast_ip is                                                                                
		
	--Member signals
	signal Member_ReadEna       : boolean;
	signal Member_ReadAddr      : integer;
	signal Member_WriteEna      : boolean;
	signal Member_WriteAddr     : integer;
	signal Member_DataOut       : std_logic_vector(511 downto 0);
	signal Member_Finish        : boolean;
	signal Member_number_param  : integer;
		                                   
	signal \number.param\       : integer;
	signal \number.iter\        : integer;
	signal \num_incr\           : integer;
	signal \num_incr_sum\       : integer;
	signal \result\             : std_logic;  
		
	--SM_Member state machine states
	type SM_Member is (
					ST000_Member,
					ST001_Member,
					ST002_Member,
					ST003_Member,
					ST004_Member,
					ST005_Member,  
					ST006_Member,
					ST007_Member,
					ST008_Member,
					ST009_Member,
					ST010_Member,
					ST011_Member, 
					ST012_Member,
					ST013_Member,
					ST014_Member
					); 
	signal state_SM_Member : SM_Member; 
		
begin
		
		
	-----------------------------
	-- SM_Member STATE MACHINE --
	-----------------------------
		  
	STM_Member: process (\Clock\)
		variable NumOfElements : integer;
	begin
		if (rising_edge(\Clock\)) then
			if \Reset\ = '1' then
				state_SM_Member     <= ST000_Member;
				Member_Finish       <= false;
				Member_WriteEna     <= false; 
				Member_WriteAddr    <= 0;
				Member_ReadEna      <= false;
				Member_ReadAddr     <= 0;
				\num_incr\          <= 0;
				\num_incr_sum\      <= 0;
				\number.iter\       <= 0;
				Member_DataOut      <= X"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
				Member_number_param <= 0;
			else
				case (state_SM_Member) is
					when ST000_Member =>
						Member_WriteEna <= false;
						\num_incr\      <= 0;
						\num_incr_sum\  <= 0;
						if \MemberId\ = 1 and \Started\ = true and Member_Finish = false then
								state_SM_Member <= ST001_Member;
								Member_ReadEna  <= true;
								Member_ReadAddr <= 0;
								Member_Finish   <= false;
						else 
								Member_ReadEna  <= false;
						end if;
						
					when ST001_Member =>
						SimpleMemoryReadUInt32(\DataIn\(63 downto 32), \number.iter\);
						if \ReadsDone\ = true then --Wait until \ReadsDone\
							Member_ReadEna  <= false;
							state_SM_Member <= ST002_Member;
						end if;
						
					when ST002_Member =>
						NumOfElements   :=  \number.iter\;
						state_SM_Member <= ST003_Member; 
						Member_DataOut  <= \DataIn\;
						
					when ST003_Member =>  
							\num_incr\ <= 0;
							Member_ReadAddr <= Member_ReadAddr + 64;
							Member_ReadEna  <= true;
							state_SM_Member <= ST004_Member;
						
					when ST004_Member =>
						if \ReadsDone\ = true then --Wait until \ReadsDone\
							--This format works in Vivado and iSim, but not in Altera-Modelsim, however Quartus can synthesize it. Using the function's content instead of it in the following lines
							---------------                                                                                                                                                         
							--SimpleMemoryReadUInt32(\DataIn\((1 + \num_incr\) * 32 - 1 downto \num_incr\ * 32), Member_number_param);
							Member_number_param <= to_integer(unsigned(\DataIn\((1 + \num_incr\) * 32 - 1 downto \num_incr\ * 32)));
							---------------
							Member_ReadEna <= false;
							--When we want to process only 1 slot of data
							if ((\num_incr\ < NumOfElements) and  (NumOfElements < 16)) then
								state_SM_Member <= ST005_Member;
							elsif ((\num_incr\ = NumOfElements) and  (NumOfElements < 16)) then
								state_SM_Member <= ST006_Member;
							--When we want to process more than 1 slot of data
							elsif ((\num_incr\ < 15) and  (\num_incr_sum\ = 0) and (NumOfElements > 16)) then
								state_SM_Member <= ST008_Member;
							elsif ((\num_incr\ = 15) and  (\num_incr_sum\ = 0) and (NumOfElements > 16)) then
								\num_incr_sum\ <= \num_incr_sum\ + 16;
								state_SM_Member <= ST009_Member;
							elsif ((\num_incr\ <15) and (\num_incr_sum\ > 0) and (\num_incr\ + \num_incr_sum\ < NumOfElements) and  (NumOfElements > 16)) then
								state_SM_Member <= ST011_Member;
							elsif ((\num_incr_sum\ > 0) and (\num_incr\ + \num_incr_sum\ = NumOfElements) and  (NumOfElements > 16)) then
								state_SM_Member <= ST012_Member;
							end if;
							
							
						end if;    
						
					when ST005_Member =>  
					--When we want to process less than one memory slot of data (512 bits)      
						--This format works in Vivado and iSim, but not in Altera-Modelsim, however Quartus can synthesize it. Using the function's content instead of it in the following lines
						---------------                                                                                                                                                         
						--SimpleMemoryWriteBoolean(\result\, Member_DataOut((3 + \num_incr\) * 32 - 1 downto (2 + \num_incr\) * 32));                                                                                                                                                                                                          
							Member_DataOut((1 + \num_incr\) * 32 - 1 downto (\num_incr\) * 32) <= x"22222222";                                                                                                                                                                                                                                                                                  
						--------------                                                                                                                                                          
						\num_incr\      <= \num_incr\ + 1;                                                                                                                                                                                                                                                                             
						Member_WriteEna <= false;                   
						state_SM_Member <= ST004_Member;
							
					when ST006_Member =>
						Member_DataOut(511 downto (16 - \num_incr\) * 32) <= \DataIn\(511 downto (16 - \num_incr\) * 32);
						Member_WriteEna  <= true;  
						Member_WriteAddr <= Member_WriteAddr + 64;
						--if \WritesDone\ = true then                       
						--	Member_WriteEna <= false;                   
							state_SM_Member <= ST007_Member;                                    
						--end if;    
						
					when ST007_Member =>
						if \WritesDone\ = true then                       
							Member_WriteEna <= false;                   
							state_SM_Member <= ST014_Member;                                    
						end if;   
						
					when ST008_Member =>
						--This format works in Vivado and iSim, but not in Altera-Modelsim, however Quartus can synthesize it. Using the function's content instead of it in the following lines
						---------------                                                                                                                                                         
						--SimpleMemoryWriteBoolean(\result\, Member_DataOut((3 + \num_incr\) * 32 - 1 downto (2 + \num_incr\) * 32));                                                     
							Member_DataOut((1 + \num_incr\) * 32 - 1 downto (\num_incr\) * 32) <= x"22222222";                                                                            
						--------------                                                                                                                                                          
						\num_incr\      <= \num_incr\ + 1;                                                                                                                             
						Member_WriteEna <= false;                   
						state_SM_Member <= ST004_Member; 
						
					when ST009_Member =>
						Member_WriteEna  <= true;  
						Member_WriteAddr <= Member_WriteAddr + 64;
						Member_DataOut((1 + \num_incr\) * 32 - 1 downto (\num_incr\) * 32) <= x"22222222"; 
						--if \WritesDone\ = true then                       
						--	Member_WriteEna <= false;                   
							state_SM_Member <= ST010_Member;                                    
						--end if;   
						
					when ST010_Member =>
						--Member_WriteEna <= true;  
						--Member_WriteAddr <= Member_WriteAddr + 64;
						--Member_DataOut((1 + \num_incr\) * 32 - 1 downto (\num_incr\) * 32) <= x"22222222"; 
						--\num_incr\ <= 0;
						--\num_incr_sum\ <= \num_incr_sum\ + 16;
						if \WritesDone\ = true then                       
							Member_WriteEna <= false;                   
							state_SM_Member <= ST003_Member;                                    
						end if;  
						
					when ST011_Member =>
						--This format works in Vivado and iSim, but not in Altera-Modelsim, however Quartus can synthesize it. Using the function's content instead of it in the following lines
						---------------                                                                                                                                                         
						--SimpleMemoryWriteBoolean(\result\, Member_DataOut((3 + \num_incr\) * 32 - 1 downto (2 + \num_incr\) * 32));                                                     
							Member_DataOut((1 + \num_incr\) * 32 - 1 downto (\num_incr\) * 32) <= x"33333333";                                                                            
						--------------                                                                                                                                                          
						\num_incr\      <= \num_incr\ + 1;                                                                                                                             
						Member_WriteEna <= false;                   
						state_SM_Member <= ST004_Member; 
						
					when ST012_Member =>
						Member_DataOut(511 downto (16-(16 - \num_incr\)) * 32) <= \DataIn\(511 downto (16-(16 - \num_incr\)) * 32);
						Member_WriteEna  <= true;  
						Member_WriteAddr <= Member_WriteAddr + 64;
						--if \WritesDone\ = true then                       
						--	Member_WriteEna <= false;                   
							state_SM_Member <= ST013_Member;                                    
						--end if; 
						
					when ST013_Member =>
						--Member_DataOut(511 downto (16-(16 - \num_incr\)) * 32) <= \DataIn\(511 downto (16-(16 - \num_incr\)) * 32);
						--Member_WriteEna <= true;  
						--Member_WriteAddr <= Member_WriteAddr + 64;
						if \WritesDone\ = true then                       
							Member_WriteEna <= false;                   
							state_SM_Member <= ST014_Member;                                    
						end if;   
						
					when ST014_Member =>
						Member_Finish   <= true;
						if \Started\ = false then -- Wait for Started to be pulled back to 0
							state_SM_Member <= ST000_Member;
							Member_Finish   <= false;
						end if;
						   
					when others => null;   
					                                    
				end case; 
			end if;    
		end if;                                          
	end process;                                                      
		
		
	\number.param\  <= Member_number_param when \MemberId\ = 1 else 0;
	\ReadEnable\    <= Member_ReadEna      when \MemberId\ = 1 else false; 
	\WriteEnable\   <= Member_WriteEna     when \MemberId\ = 1 else false;
	\CellIndex\     <= Member_ReadAddr     when \MemberId\ = 1 and Member_ReadEna  = true else
					   Member_WriteAddr    when \MemberId\ = 1 and Member_WriteEna = true; 
	\DataOut\       <= Member_DataOut      when \MemberId\ = 1 else (others =>'0');
	\Finished\      <= Member_Finish       when \MemberId\ = 1 else false;
		  
end Imp;                                                      
                                                                                      
                                                              
                          