
local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 81) then
			local FlatIdent_7126A = 0;
			while true do
				if (FlatIdent_7126A == 0) then
					repeatNext = StrToNumber(Sub(byte, 1, 1));
					return "";
				end
			end
		else
			local FlatIdent_12703 = 0;
			local a;
			while true do
				if (FlatIdent_12703 == 0) then
					a = Char(StrToNumber(byte, 16));
					if repeatNext then
						local FlatIdent_2BD95 = 0;
						local b;
						while true do
							if (FlatIdent_2BD95 == 1) then
								return b;
							end
							if (FlatIdent_2BD95 == 0) then
								b = Rep(a, repeatNext);
								repeatNext = nil;
								FlatIdent_2BD95 = 1;
							end
						end
					else
						return a;
					end
					break;
				end
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
			return Res - (Res % 1);
		else
			local Plc = 2 ^ (Start - 1);
			return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
		end
	end
	local function gBits8()
		local FlatIdent_96598 = 0;
		local a;
		while true do
			if (FlatIdent_96598 == 1) then
				return a;
			end
			if (0 == FlatIdent_96598) then
				a = Byte(ByteString, DIP, DIP);
				DIP = DIP + 1;
				FlatIdent_96598 = 1;
			end
		end
	end
	local function gBits16()
		local FlatIdent_60EA1 = 0;
		local a;
		local b;
		while true do
			if (FlatIdent_60EA1 == 1) then
				return (b * 256) + a;
			end
			if (FlatIdent_60EA1 == 0) then
				a, b = Byte(ByteString, DIP, DIP + 2);
				DIP = DIP + 2;
				FlatIdent_60EA1 = 1;
			end
		end
	end
	local function gBits32()
		local a, b, c, d = Byte(ByteString, DIP, DIP + 3);
		DIP = DIP + 4;
		return (d * 16777216) + (c * 65536) + (b * 256) + a;
	end
	local function gFloat()
		local FlatIdent_2C2F3 = 0;
		local Left;
		local Right;
		local IsNormal;
		local Mantissa;
		local Exponent;
		local Sign;
		while true do
			if (3 == FlatIdent_2C2F3) then
				if (Exponent == 0) then
					if (Mantissa == 0) then
						return Sign * 0;
					else
						local FlatIdent_8F047 = 0;
						while true do
							if (FlatIdent_8F047 == 0) then
								Exponent = 1;
								IsNormal = 0;
								break;
							end
						end
					end
				elseif (Exponent == 2047) then
					return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
				end
				return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
			end
			if (FlatIdent_2C2F3 == 0) then
				Left = gBits32();
				Right = gBits32();
				FlatIdent_2C2F3 = 1;
			end
			if (FlatIdent_2C2F3 == 1) then
				IsNormal = 1;
				Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
				FlatIdent_2C2F3 = 2;
			end
			if (FlatIdent_2C2F3 == 2) then
				Exponent = gBit(Right, 21, 31);
				Sign = ((gBit(Right, 32) == 1) and -1) or 1;
				FlatIdent_2C2F3 = 3;
			end
		end
	end
	local function gString(Len)
		local FlatIdent_31905 = 0;
		local Str;
		local FStr;
		while true do
			if (FlatIdent_31905 == 1) then
				Str = Sub(ByteString, DIP, (DIP + Len) - 1);
				DIP = DIP + Len;
				FlatIdent_31905 = 2;
			end
			if (0 == FlatIdent_31905) then
				Str = nil;
				if not Len then
					local FlatIdent_A9A3 = 0;
					while true do
						if (FlatIdent_A9A3 == 0) then
							Len = gBits32();
							if (Len == 0) then
								return "";
							end
							break;
						end
					end
				end
				FlatIdent_31905 = 1;
			end
			if (FlatIdent_31905 == 2) then
				FStr = {};
				for Idx = 1, #Str do
					FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
				end
				FlatIdent_31905 = 3;
			end
			if (FlatIdent_31905 == 3) then
				return Concat(FStr);
			end
		end
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local FlatIdent_45D0C = 0;
		local Instrs;
		local Functions;
		local Lines;
		local Chunk;
		local ConstCount;
		local Consts;
		while true do
			if (FlatIdent_45D0C == 0) then
				Instrs = {};
				Functions = {};
				Lines = {};
				Chunk = {Instrs,Functions,nil,Lines};
				FlatIdent_45D0C = 1;
			end
			if (FlatIdent_45D0C == 2) then
				for Idx = 1, gBits32() do
					local FlatIdent_74EA4 = 0;
					local Descriptor;
					while true do
						if (FlatIdent_74EA4 == 0) then
							Descriptor = gBits8();
							if (gBit(Descriptor, 1, 1) == 0) then
								local Type = gBit(Descriptor, 2, 3);
								local Mask = gBit(Descriptor, 4, 6);
								local Inst = {gBits16(),gBits16(),nil,nil};
								if (Type == 0) then
									local FlatIdent_40CF = 0;
									while true do
										if (FlatIdent_40CF == 0) then
											Inst[3] = gBits16();
											Inst[4] = gBits16();
											break;
										end
									end
								elseif (Type == 1) then
									Inst[3] = gBits32();
								elseif (Type == 2) then
									Inst[3] = gBits32() - (2 ^ 16);
								elseif (Type == 3) then
									Inst[3] = gBits32() - (2 ^ 16);
									Inst[4] = gBits16();
								end
								if (gBit(Mask, 1, 1) == 1) then
									Inst[2] = Consts[Inst[2]];
								end
								if (gBit(Mask, 2, 2) == 1) then
									Inst[3] = Consts[Inst[3]];
								end
								if (gBit(Mask, 3, 3) == 1) then
									Inst[4] = Consts[Inst[4]];
								end
								Instrs[Idx] = Inst;
							end
							break;
						end
					end
				end
				for Idx = 1, gBits32() do
					Functions[Idx - 1] = Deserialize();
				end
				return Chunk;
			end
			if (FlatIdent_45D0C == 1) then
				ConstCount = gBits32();
				Consts = {};
				for Idx = 1, ConstCount do
					local FlatIdent_65A72 = 0;
					local Type;
					local Cons;
					while true do
						if (FlatIdent_65A72 == 0) then
							Type = gBits8();
							Cons = nil;
							FlatIdent_65A72 = 1;
						end
						if (FlatIdent_65A72 == 1) then
							if (Type == 1) then
								Cons = gBits8() ~= 0;
							elseif (Type == 2) then
								Cons = gFloat();
							elseif (Type == 3) then
								Cons = gString();
							end
							Consts[Idx] = Cons;
							break;
						end
					end
				end
				Chunk[3] = gBits8();
				FlatIdent_45D0C = 2;
			end
		end
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				local FlatIdent_8CEDF = 0;
				while true do
					if (FlatIdent_8CEDF == 1) then
						if (Enum <= 27) then
							if (Enum <= 13) then
								if (Enum <= 6) then
									if (Enum <= 2) then
										if (Enum <= 0) then
											Upvalues[Inst[3]] = Stk[Inst[2]];
										elseif (Enum == 1) then
											Stk[Inst[2]] = Upvalues[Inst[3]];
										else
											local FlatIdent_1B1BA = 0;
											local A;
											while true do
												if (FlatIdent_1B1BA == 0) then
													A = nil;
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_1B1BA = 1;
												end
												if (FlatIdent_1B1BA == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_1B1BA = 3;
												end
												if (FlatIdent_1B1BA == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													VIP = Inst[3];
													break;
												end
												if (FlatIdent_1B1BA == 3) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													FlatIdent_1B1BA = 4;
												end
												if (FlatIdent_1B1BA == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_1B1BA = 2;
												end
											end
										end
									elseif (Enum <= 4) then
										if (Enum > 3) then
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										else
											local FlatIdent_324DE = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_324DE == 5) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_324DE = 6;
												end
												if (8 == FlatIdent_324DE) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_324DE = 9;
												end
												if (FlatIdent_324DE == 4) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_324DE = 5;
												end
												if (FlatIdent_324DE == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_324DE = 4;
												end
												if (FlatIdent_324DE == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_324DE = 3;
												end
												if (FlatIdent_324DE == 6) then
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Upvalues[Inst[3]] = Stk[Inst[2]];
													VIP = VIP + 1;
													FlatIdent_324DE = 7;
												end
												if (FlatIdent_324DE == 9) then
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													VIP = Inst[3];
													break;
												end
												if (FlatIdent_324DE == 0) then
													B = nil;
													A = nil;
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													FlatIdent_324DE = 1;
												end
												if (FlatIdent_324DE == 1) then
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_324DE = 2;
												end
												if (7 == FlatIdent_324DE) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_324DE = 8;
												end
											end
										end
									elseif (Enum == 5) then
										local FlatIdent_28F3E = 0;
										local A;
										while true do
											if (FlatIdent_28F3E == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_28F3E = 3;
											end
											if (FlatIdent_28F3E == 4) then
												Inst = Instr[VIP];
												if not Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
											if (FlatIdent_28F3E == 3) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_28F3E = 4;
											end
											if (FlatIdent_28F3E == 1) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_28F3E = 2;
											end
											if (0 == FlatIdent_28F3E) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_28F3E = 1;
											end
										end
									else
										VIP = Inst[3];
									end
								elseif (Enum <= 9) then
									if (Enum <= 7) then
										local K;
										local B;
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										B = Inst[3];
										K = Stk[B];
										for Idx = B + 1, Inst[4] do
											K = K .. Stk[Idx];
										end
										Stk[Inst[2]] = K;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if not Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									elseif (Enum == 8) then
										local FlatIdent_466B2 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_466B2 == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_466B2 = 1;
											end
											if (FlatIdent_466B2 == 6) then
												if Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
											if (FlatIdent_466B2 == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_466B2 = 2;
											end
											if (FlatIdent_466B2 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_466B2 = 4;
											end
											if (5 == FlatIdent_466B2) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_466B2 = 6;
											end
											if (FlatIdent_466B2 == 2) then
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_466B2 = 3;
											end
											if (FlatIdent_466B2 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_466B2 = 5;
											end
										end
									else
										local FlatIdent_28014 = 0;
										local A;
										local Results;
										local Limit;
										local Edx;
										while true do
											if (FlatIdent_28014 == 0) then
												A = Inst[2];
												Results, Limit = _R(Stk[A](Stk[A + 1]));
												FlatIdent_28014 = 1;
											end
											if (FlatIdent_28014 == 1) then
												Top = (Limit + A) - 1;
												Edx = 0;
												FlatIdent_28014 = 2;
											end
											if (FlatIdent_28014 == 2) then
												for Idx = A, Top do
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
												end
												break;
											end
										end
									end
								elseif (Enum <= 11) then
									if (Enum > 10) then
										local Edx;
										local Results, Limit;
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Stk[A + 1]));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											local FlatIdent_691EB = 0;
											while true do
												if (FlatIdent_691EB == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if (Stk[Inst[2]] < Stk[Inst[4]]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									else
										Stk[Inst[2]] = Stk[Inst[3]] * Inst[4];
									end
								elseif (Enum == 12) then
									do
										return;
									end
								else
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								end
							elseif (Enum <= 20) then
								if (Enum <= 16) then
									if (Enum <= 14) then
										local FlatIdent_6C277 = 0;
										local NewProto;
										local NewUvals;
										local Indexes;
										while true do
											if (FlatIdent_6C277 == 0) then
												NewProto = Proto[Inst[3]];
												NewUvals = nil;
												FlatIdent_6C277 = 1;
											end
											if (FlatIdent_6C277 == 1) then
												Indexes = {};
												NewUvals = Setmetatable({}, {__index=function(_, Key)
													local FlatIdent_3B7E2 = 0;
													local Val;
													while true do
														if (FlatIdent_3B7E2 == 0) then
															Val = Indexes[Key];
															return Val[1][Val[2]];
														end
													end
												end,__newindex=function(_, Key, Value)
													local FlatIdent_18D84 = 0;
													local Val;
													while true do
														if (FlatIdent_18D84 == 0) then
															Val = Indexes[Key];
															Val[1][Val[2]] = Value;
															break;
														end
													end
												end});
												FlatIdent_6C277 = 2;
											end
											if (FlatIdent_6C277 == 2) then
												for Idx = 1, Inst[4] do
													VIP = VIP + 1;
													local Mvm = Instr[VIP];
													if (Mvm[1] == 44) then
														Indexes[Idx - 1] = {Stk,Mvm[3]};
													else
														Indexes[Idx - 1] = {Upvalues,Mvm[3]};
													end
													Lupvals[#Lupvals + 1] = Indexes;
												end
												Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
												break;
											end
										end
									elseif (Enum == 15) then
										local A = Inst[2];
										Stk[A](Stk[A + 1]);
									else
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									end
								elseif (Enum <= 18) then
									if (Enum == 17) then
										local FlatIdent_1013A = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_1013A == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1013A = 5;
											end
											if (FlatIdent_1013A == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_1013A = 2;
											end
											if (FlatIdent_1013A == 6) then
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_1013A == 0) then
												B = nil;
												A = nil;
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_1013A = 1;
											end
											if (FlatIdent_1013A == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_1013A = 4;
											end
											if (FlatIdent_1013A == 5) then
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Upvalues[Inst[3]] = Stk[Inst[2]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1013A = 6;
											end
											if (FlatIdent_1013A == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												FlatIdent_1013A = 3;
											end
										end
									else
										Stk[Inst[2]] = not Stk[Inst[3]];
									end
								elseif (Enum == 19) then
									local FlatIdent_6D09C = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_6D09C == 4) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_6D09C = 5;
										end
										if (FlatIdent_6D09C == 0) then
											B = nil;
											A = nil;
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_6D09C = 1;
										end
										if (3 == FlatIdent_6D09C) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_6D09C = 4;
										end
										if (FlatIdent_6D09C == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_6D09C = 3;
										end
										if (FlatIdent_6D09C == 5) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_6D09C = 6;
										end
										if (FlatIdent_6D09C == 6) then
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Upvalues[Inst[3]] = Stk[Inst[2]];
											break;
										end
										if (FlatIdent_6D09C == 1) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_6D09C = 2;
										end
									end
								else
									Stk[Inst[2]] = Inst[3] + Stk[Inst[4]];
								end
							elseif (Enum <= 23) then
								if (Enum <= 21) then
									Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
								elseif (Enum > 22) then
									local FlatIdent_21811 = 0;
									local B;
									local A;
									while true do
										if (5 == FlatIdent_21811) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_21811 = 6;
										end
										if (FlatIdent_21811 == 10) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_21811 = 11;
										end
										if (FlatIdent_21811 == 11) then
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_21811 == 1) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_21811 = 2;
										end
										if (FlatIdent_21811 == 7) then
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_21811 = 8;
										end
										if (2 == FlatIdent_21811) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_21811 = 3;
										end
										if (FlatIdent_21811 == 8) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_21811 = 9;
										end
										if (FlatIdent_21811 == 9) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_21811 = 10;
										end
										if (FlatIdent_21811 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_21811 = 4;
										end
										if (FlatIdent_21811 == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_21811 = 5;
										end
										if (FlatIdent_21811 == 6) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_21811 = 7;
										end
										if (FlatIdent_21811 == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_21811 = 1;
										end
									end
								else
									Stk[Inst[2]][Inst[3]] = Inst[4];
								end
							elseif (Enum <= 25) then
								if (Enum > 24) then
									if not Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									local FlatIdent_91608 = 0;
									local A;
									while true do
										if (FlatIdent_91608 == 0) then
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											break;
										end
									end
								end
							elseif (Enum > 26) then
								local FlatIdent_44265 = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_44265 == 8) then
										Inst = Instr[VIP];
										Upvalues[Inst[3]] = Stk[Inst[2]];
										break;
									end
									if (FlatIdent_44265 == 1) then
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_44265 = 2;
									end
									if (FlatIdent_44265 == 0) then
										B = nil;
										A = nil;
										A = Inst[2];
										B = Stk[Inst[3]];
										FlatIdent_44265 = 1;
									end
									if (FlatIdent_44265 == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_44265 = 7;
									end
									if (FlatIdent_44265 == 2) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_44265 = 3;
									end
									if (7 == FlatIdent_44265) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										FlatIdent_44265 = 8;
									end
									if (FlatIdent_44265 == 5) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_44265 = 6;
									end
									if (FlatIdent_44265 == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_44265 = 5;
									end
									if (FlatIdent_44265 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_44265 = 4;
									end
								end
							else
								local FlatIdent_2593F = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_2593F == 20) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_2593F = 21;
									end
									if (FlatIdent_2593F == 4) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_2593F = 5;
									end
									if (FlatIdent_2593F == 10) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_2593F = 11;
									end
									if (11 == FlatIdent_2593F) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_2593F = 12;
									end
									if (19 == FlatIdent_2593F) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_2593F = 20;
									end
									if (FlatIdent_2593F == 14) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_2593F = 15;
									end
									if (FlatIdent_2593F == 17) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_2593F = 18;
									end
									if (5 == FlatIdent_2593F) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_2593F = 6;
									end
									if (13 == FlatIdent_2593F) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_2593F = 14;
									end
									if (FlatIdent_2593F == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_2593F = 7;
									end
									if (FlatIdent_2593F == 21) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_2593F = 22;
									end
									if (FlatIdent_2593F == 12) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_2593F = 13;
									end
									if (FlatIdent_2593F == 24) then
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										break;
									end
									if (FlatIdent_2593F == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_2593F = 2;
									end
									if (FlatIdent_2593F == 8) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_2593F = 9;
									end
									if (FlatIdent_2593F == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_2593F = 1;
									end
									if (FlatIdent_2593F == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_2593F = 3;
									end
									if (FlatIdent_2593F == 9) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_2593F = 10;
									end
									if (FlatIdent_2593F == 22) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_2593F = 23;
									end
									if (FlatIdent_2593F == 3) then
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_2593F = 4;
									end
									if (18 == FlatIdent_2593F) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_2593F = 19;
									end
									if (23 == FlatIdent_2593F) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_2593F = 24;
									end
									if (FlatIdent_2593F == 7) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										FlatIdent_2593F = 8;
									end
									if (FlatIdent_2593F == 15) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_2593F = 16;
									end
									if (FlatIdent_2593F == 16) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_2593F = 17;
									end
								end
							end
						elseif (Enum <= 41) then
							if (Enum <= 34) then
								if (Enum <= 30) then
									if (Enum <= 28) then
										local FlatIdent_92514 = 0;
										local A;
										while true do
											if (FlatIdent_92514 == 0) then
												A = Inst[2];
												Stk[A] = Stk[A]();
												break;
											end
										end
									elseif (Enum == 29) then
										local FlatIdent_13B77 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_13B77 == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_13B77 = 1;
											end
											if (11 == FlatIdent_13B77) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_13B77 = 12;
											end
											if (FlatIdent_13B77 == 5) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												FlatIdent_13B77 = 6;
											end
											if (23 == FlatIdent_13B77) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_13B77 = 24;
											end
											if (27 == FlatIdent_13B77) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_13B77 = 28;
											end
											if (FlatIdent_13B77 == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_13B77 = 2;
											end
											if (FlatIdent_13B77 == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_13B77 = 8;
											end
											if (FlatIdent_13B77 == 17) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_13B77 = 18;
											end
											if (FlatIdent_13B77 == 10) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_13B77 = 11;
											end
											if (FlatIdent_13B77 == 26) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_13B77 = 27;
											end
											if (FlatIdent_13B77 == 18) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												FlatIdent_13B77 = 19;
											end
											if (FlatIdent_13B77 == 21) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_13B77 = 22;
											end
											if (4 == FlatIdent_13B77) then
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_13B77 = 5;
											end
											if (FlatIdent_13B77 == 2) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_13B77 = 3;
											end
											if (FlatIdent_13B77 == 3) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_13B77 = 4;
											end
											if (FlatIdent_13B77 == 8) then
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_13B77 = 9;
											end
											if (24 == FlatIdent_13B77) then
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_13B77 = 25;
											end
											if (19 == FlatIdent_13B77) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_13B77 = 20;
											end
											if (FlatIdent_13B77 == 25) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_13B77 = 26;
											end
											if (FlatIdent_13B77 == 13) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_13B77 = 14;
											end
											if (28 == FlatIdent_13B77) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												break;
											end
											if (FlatIdent_13B77 == 9) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_13B77 = 10;
											end
											if (FlatIdent_13B77 == 15) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_13B77 = 16;
											end
											if (FlatIdent_13B77 == 20) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_13B77 = 21;
											end
											if (FlatIdent_13B77 == 12) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_13B77 = 13;
											end
											if (FlatIdent_13B77 == 22) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_13B77 = 23;
											end
											if (FlatIdent_13B77 == 16) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_13B77 = 17;
											end
											if (FlatIdent_13B77 == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_13B77 = 7;
											end
											if (FlatIdent_13B77 == 14) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_13B77 = 15;
											end
										end
									else
										local FlatIdent_661EB = 0;
										local A;
										local B;
										while true do
											if (FlatIdent_661EB == 1) then
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												break;
											end
											if (FlatIdent_661EB == 0) then
												A = Inst[2];
												B = Stk[Inst[3]];
												FlatIdent_661EB = 1;
											end
										end
									end
								elseif (Enum <= 32) then
									if (Enum == 31) then
										Stk[Inst[2]] = Env[Inst[3]];
									else
										Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
									end
								elseif (Enum == 33) then
									local K;
									local B;
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									B = Inst[3];
									K = Stk[B];
									for Idx = B + 1, Inst[4] do
										K = K .. Stk[Idx];
									end
									Stk[Inst[2]] = K;
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									local FlatIdent_4058F = 0;
									local A;
									while true do
										if (FlatIdent_4058F == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if not Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
										if (0 == FlatIdent_4058F) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_4058F = 1;
										end
										if (FlatIdent_4058F == 1) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_4058F = 2;
										end
										if (FlatIdent_4058F == 2) then
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											FlatIdent_4058F = 3;
										end
									end
								end
							elseif (Enum <= 37) then
								if (Enum <= 35) then
									if (Stk[Inst[2]] < Inst[4]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Enum > 36) then
									local B;
									local A;
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3] ~= 0;
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3] ~= 0;
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Upvalues[Inst[3]] = Stk[Inst[2]];
								else
									local FlatIdent_47EEF = 0;
									while true do
										if (FlatIdent_47EEF == 3) then
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_47EEF = 4;
										end
										if (FlatIdent_47EEF == 0) then
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_47EEF = 1;
										end
										if (FlatIdent_47EEF == 1) then
											Stk[Inst[2]] = not Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_47EEF = 2;
										end
										if (4 == FlatIdent_47EEF) then
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_47EEF = 5;
										end
										if (5 == FlatIdent_47EEF) then
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
										if (FlatIdent_47EEF == 2) then
											Upvalues[Inst[3]] = Stk[Inst[2]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_47EEF = 3;
										end
									end
								end
							elseif (Enum <= 39) then
								if (Enum == 38) then
									local FlatIdent_2C453 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_2C453 == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_2C453 = 2;
										end
										if (FlatIdent_2C453 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											FlatIdent_2C453 = 3;
										end
										if (4 == FlatIdent_2C453) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2C453 = 5;
										end
										if (0 == FlatIdent_2C453) then
											B = nil;
											A = nil;
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_2C453 = 1;
										end
										if (FlatIdent_2C453 == 5) then
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Upvalues[Inst[3]] = Stk[Inst[2]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2C453 = 6;
										end
										if (FlatIdent_2C453 == 6) then
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_2C453 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_2C453 = 4;
										end
									end
								else
									local FlatIdent_5013F = 0;
									local B;
									local A;
									while true do
										if (1 == FlatIdent_5013F) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5013F = 2;
										end
										if (FlatIdent_5013F == 2) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_5013F = 3;
										end
										if (5 == FlatIdent_5013F) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_5013F = 6;
										end
										if (0 == FlatIdent_5013F) then
											B = nil;
											A = nil;
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_5013F = 1;
										end
										if (FlatIdent_5013F == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5013F = 5;
										end
										if (FlatIdent_5013F == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_5013F = 4;
										end
										if (FlatIdent_5013F == 8) then
											Inst = Instr[VIP];
											Upvalues[Inst[3]] = Stk[Inst[2]];
											break;
										end
										if (FlatIdent_5013F == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_5013F = 7;
										end
										if (FlatIdent_5013F == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											FlatIdent_5013F = 8;
										end
									end
								end
							elseif (Enum == 40) then
								local FlatIdent_62CB4 = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_62CB4 == 4) then
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_62CB4 = 5;
									end
									if (FlatIdent_62CB4 == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_62CB4 = 2;
									end
									if (FlatIdent_62CB4 == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]] = Inst[3];
										FlatIdent_62CB4 = 1;
									end
									if (FlatIdent_62CB4 == 7) then
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
										break;
									end
									if (FlatIdent_62CB4 == 6) then
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										FlatIdent_62CB4 = 7;
									end
									if (FlatIdent_62CB4 == 5) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_62CB4 = 6;
									end
									if (FlatIdent_62CB4 == 2) then
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_62CB4 = 3;
									end
									if (3 == FlatIdent_62CB4) then
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										FlatIdent_62CB4 = 4;
									end
								end
							else
								local FlatIdent_69486 = 0;
								local A;
								while true do
									if (FlatIdent_69486 == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_69486 = 2;
									end
									if (FlatIdent_69486 == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_69486 = 3;
									end
									if (FlatIdent_69486 == 4) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										break;
									end
									if (FlatIdent_69486 == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_69486 = 1;
									end
									if (FlatIdent_69486 == 3) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_69486 = 4;
									end
								end
							end
						elseif (Enum <= 48) then
							if (Enum <= 44) then
								if (Enum <= 42) then
									local A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
								elseif (Enum > 43) then
									Stk[Inst[2]] = Stk[Inst[3]];
								else
									Stk[Inst[2]] = Stk[Inst[3]] % Inst[4];
								end
							elseif (Enum <= 46) then
								if (Enum == 45) then
									local FlatIdent_2861D = 0;
									local A;
									while true do
										if (FlatIdent_2861D == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] * Inst[4];
											VIP = VIP + 1;
											FlatIdent_2861D = 4;
										end
										if (4 == FlatIdent_2861D) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] + Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2861D = 5;
										end
										if (FlatIdent_2861D == 1) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_2861D = 2;
										end
										if (0 == FlatIdent_2861D) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2861D = 1;
										end
										if (FlatIdent_2861D == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A]();
											FlatIdent_2861D = 3;
										end
										if (FlatIdent_2861D == 6) then
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_2861D == 5) then
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2861D = 6;
										end
									end
								else
									local A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
								end
							elseif (Enum == 47) then
								Stk[Inst[2]] = Inst[3] ~= 0;
							elseif (Stk[Inst[2]] < Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 51) then
							if (Enum <= 49) then
								local B;
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							elseif (Enum > 50) then
								local FlatIdent_14E41 = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_14E41 == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_14E41 = 5;
									end
									if (FlatIdent_14E41 == 15) then
										Stk[Inst[2]] = Stk[Inst[3]] * Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] + Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_14E41 = 16;
									end
									if (FlatIdent_14E41 == 11) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_14E41 = 12;
									end
									if (FlatIdent_14E41 == 14) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A]();
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_14E41 = 15;
									end
									if (FlatIdent_14E41 == 5) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_14E41 = 6;
									end
									if (FlatIdent_14E41 == 7) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										FlatIdent_14E41 = 8;
									end
									if (FlatIdent_14E41 == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										FlatIdent_14E41 = 3;
									end
									if (FlatIdent_14E41 == 0) then
										B = nil;
										A = nil;
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										FlatIdent_14E41 = 1;
									end
									if (FlatIdent_14E41 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_14E41 = 4;
									end
									if (FlatIdent_14E41 == 9) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_14E41 = 10;
									end
									if (FlatIdent_14E41 == 16) then
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										break;
									end
									if (FlatIdent_14E41 == 12) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_14E41 = 13;
									end
									if (FlatIdent_14E41 == 10) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_14E41 = 11;
									end
									if (FlatIdent_14E41 == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_14E41 = 2;
									end
									if (FlatIdent_14E41 == 13) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_14E41 = 14;
									end
									if (FlatIdent_14E41 == 6) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										FlatIdent_14E41 = 7;
									end
									if (FlatIdent_14E41 == 8) then
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_14E41 = 9;
									end
								end
							else
								local FlatIdent_2B407 = 0;
								local A;
								while true do
									if (FlatIdent_2B407 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] * Inst[4];
										VIP = VIP + 1;
										FlatIdent_2B407 = 4;
									end
									if (FlatIdent_2B407 == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A]();
										FlatIdent_2B407 = 3;
									end
									if (FlatIdent_2B407 == 5) then
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_2B407 = 6;
									end
									if (FlatIdent_2B407 == 6) then
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_2B407 == 1) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_2B407 = 2;
									end
									if (FlatIdent_2B407 == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_2B407 = 1;
									end
									if (FlatIdent_2B407 == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] + Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_2B407 = 5;
									end
								end
							end
						elseif (Enum <= 53) then
							if (Enum > 52) then
								local FlatIdent_28E8A = 0;
								local B;
								local K;
								while true do
									if (1 == FlatIdent_28E8A) then
										for Idx = B + 1, Inst[4] do
											K = K .. Stk[Idx];
										end
										Stk[Inst[2]] = K;
										break;
									end
									if (FlatIdent_28E8A == 0) then
										B = Inst[3];
										K = Stk[B];
										FlatIdent_28E8A = 1;
									end
								end
							else
								local FlatIdent_1E39B = 0;
								local A;
								while true do
									if (FlatIdent_1E39B == 0) then
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										break;
									end
								end
							end
						elseif (Enum > 54) then
							local FlatIdent_14BE1 = 0;
							local K;
							local B;
							while true do
								if (3 == FlatIdent_14BE1) then
									K = Stk[B];
									for Idx = B + 1, Inst[4] do
										K = K .. Stk[Idx];
									end
									Stk[Inst[2]] = K;
									VIP = VIP + 1;
									FlatIdent_14BE1 = 4;
								end
								if (FlatIdent_14BE1 == 1) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_14BE1 = 2;
								end
								if (FlatIdent_14BE1 == 4) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_14BE1 = 5;
								end
								if (FlatIdent_14BE1 == 2) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									B = Inst[3];
									FlatIdent_14BE1 = 3;
								end
								if (FlatIdent_14BE1 == 0) then
									K = nil;
									B = nil;
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									FlatIdent_14BE1 = 1;
								end
								if (FlatIdent_14BE1 == 5) then
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
									break;
								end
							end
						else
							Stk[Inst[2]] = Inst[3];
						end
						VIP = VIP + 1;
						break;
					end
					if (FlatIdent_8CEDF == 0) then
						Inst = Instr[VIP];
						Enum = Inst[1];
						FlatIdent_8CEDF = 1;
					end
				end
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!3E3Q0003043Q0067616D65030A3Q004765745365727669636503073Q00506C6179657273030B3Q004C6F63616C506C61796572030C3Q0057616974466F724368696C6403093Q00506C6179657247756903133Q005669727475616C496E7075744D616E6167657203083Q00496E7374616E63652Q033Q006E657703093Q005363722Q656E47756903043Q004E616D65030C3Q00466973686572546F2Q676C65030C3Q0052657365744F6E537061776E010003063Q00506172656E7403053Q004672616D6503043Q0053697A6503053Q005544696D32028Q00025Q00806640025Q0040504003083Q00506F736974696F6E026Q00F03F025Q00C067C0026Q00244003103Q004261636B67726F756E64436F6C6F723303063Q00436F6C6F723303073Q0066726F6D524742026Q003E40030F3Q00426F7264657253697A65506978656C027Q004003063Q004163746976652Q0103093Q004472612Q6761626C6503093Q00546578744C6162656C026Q00364003163Q004261636B67726F756E645472616E73706172656E637903043Q0054657874030B3Q00466973686572204175746F030A3Q0054657874436F6C6F723303043Q00466F6E7403043Q00456E756D030E3Q00536F7572636553616E73426F6C6403083Q005465787453697A65026Q003040030A3Q005465787442752Q746F6E02CD5QCCEC3F026Q003C40029A5Q99A93F029A5Q99D93F03023Q004F4E026Q003240026Q0036C0030A3Q0057616974696E673Q2E025Q00E06F40030A3Q00536F7572636553616E73026Q002A40030A3Q00546578745363616C656403113Q004D6F75736542752Q746F6E31436C69636B03073Q00436F2Q6E65637403043Q007461736B03053Q00737061776E00AE3Q00121D3Q00013Q00206Q000200122Q000200038Q0002000200202Q00013Q000400202Q00020001000500122Q000400066Q00020004000200122Q000300013Q00202Q00030003000200122Q000500076Q0003000500024Q000400016Q00055Q00122Q000600083Q00202Q00060006000900122Q0007000A6Q00060002000200302Q0006000B000C00302Q0006000D000E00102Q0006000F000200122Q000700083Q00202Q00070007000900122Q000800106Q000900066Q00070009000200122Q000800123Q00202Q00080008000900122Q000900133Q00122Q000A00143Q00122Q000B00133Q00122Q000C00156Q0008000C000200102Q00070011000800122Q000800123Q00202Q00080008000900122Q000900173Q00122Q000A00183Q00122Q000B00133Q00122Q000C00196Q0008000C000200102Q00070016000800122Q0008001B3Q00202Q00080008001C00122Q0009001D3Q00122Q000A001D3Q00122Q000B001D6Q0008000B000200102Q0007001A000800302Q0007001E001F00302Q00070020002100302Q00070022002100122Q000800083Q00202Q00080008000900122Q000900236Q000A00076Q0008000A000200122Q000900123Q00202Q00090009000900122Q000A00173Q00122Q000B00133Q00122Q000C00133Q00122Q000D00246Q0009000D000200102Q00080011000900302Q00080025001700302Q00080026002700122Q0009001B3Q00202Q00090009000900122Q000A00173Q00122Q000B00173Q00122Q000C00176Q0009000C000200102Q00080028000900122Q0009002A3Q00202Q00090009002900202Q00090009002B00102Q00080029000900302Q0008002C002D00122Q000900083Q00201000090009000900121A000A002E6Q000B00076Q0009000B000200122Q000A00123Q00202Q000A000A000900122Q000B002F3Q00122Q000C00133Q00122Q000D00133Q00122Q000E00306Q000A000E000200102Q00090011000A00122Q000A00123Q00202Q000A000A000900122Q000B00313Q00122Q000C00133Q00122Q000D00323Q00122Q000E00136Q000A000E000200102Q00090016000A00122Q000A001B3Q00202Q000A000A001C00122Q000B00133Q00122Q000C00143Q00122Q000D00136Q000A000D000200102Q0009001A000A00302Q00090026003300122Q000A001B3Q00202Q000A000A000900122Q000B00173Q00122Q000C00173Q00122Q000D00176Q000A000D000200102Q00090028000A00122Q000A002A3Q00202Q000A000A002900202Q000A000A002B00102Q00090029000A00302Q0009002C003400122Q000A00083Q00202Q000A000A000900122Q000B00236Q000C00076Q000A000C000200122Q000B00123Q00202Q000B000B000900122Q000C00173Q00122Q000D00133Q00122Q000E00133Q00122Q000F00246Q000B000F000200102Q000A0011000B00122Q000B00123Q00202Q000B000B000900122Q000C00133Q00122Q000D00133Q00122Q000E00173Q00122Q000F00356Q000B000F000200102Q000A0016000B00302Q000A0025001700302Q000A0026003600122Q000B001B3Q00202Q000B000B001C00122Q000C00143Q00122Q000D00373Q00122Q000E00146Q000B000E000200102Q000A0028000B00122Q000B002A3Q00202Q000B000B002900202Q000B000B003800102Q000A0029000B00302Q000A002C003900302Q000A003A002100202Q000B0009003B00202Q000B000B003C00060E000D3Q000100042Q002C3Q00044Q002C3Q00094Q002C3Q00054Q002C3Q00034Q002E000B000D000100121F000B003D3Q002010000B000B003E00060E000C0001000100052Q002C3Q00044Q002C3Q000A4Q002C3Q00054Q002C3Q00034Q002C3Q00024Q000F000B000200012Q000C3Q00013Q00023Q000A3Q0003103Q004261636B67726F756E64436F6C6F723303063Q00436F6C6F723303073Q0066726F6D524742028Q00025Q0080664003043Q005465787403023Q004F4E2Q033Q004F2Q4603143Q0053656E644D6F75736542752Q746F6E4576656E7403043Q0067616D6500314Q00249Q009Q009Q003Q00016Q00015Q00062Q0001000F00013Q0004063Q000F000100121F000100023Q00202900010001000300122Q000200043Q00122Q000300053Q00122Q000400046Q00010004000200061900010015000100010004063Q0015000100121F000100023Q00202900010001000300122Q000200053Q00122Q000300043Q00122Q000400046Q00010004000200100D3Q000100012Q00013Q00014Q000100015Q0006040001001D00013Q0004063Q001D0001001236000100073Q0006190001001E000100010004063Q001E0001001236000100083Q00100D3Q000600012Q00017Q0006193Q0030000100010004063Q003000012Q00013Q00023Q0006043Q003000013Q0004063Q003000012Q00013Q00033Q00201B5Q000900122Q000200043Q00122Q000300043Q00122Q000400046Q00055Q00122Q0006000A3Q00122Q000700048Q000700019Q006Q00024Q000C3Q00017Q002A3Q0003043Q007461736B03043Q007761697402FCA9F1D24D62803F03043Q00546578742Q033Q004F2Q4603143Q0053656E644D6F75736542752Q746F6E4576656E74028Q0003043Q0067616D65030E3Q0046696E6446697273744368696C6403123Q00416374696F6E4261725363722Q656E47756903093Q00416374696F6E42617203123Q0046697368696E674D696E6967616D65412Q7003073Q0056697369626C6503013Q003303083Q004D696E6967616D6503063Q004D61726B657203083Q00466973685A6F6E6503013Q003103193Q00456C656D656E7473206D692Q73696E6720E28692207370616D023BDF4F8D976E923F03103Q004162736F6C757465506F736974696F6E03013Q0058030C3Q004162736F6C75746553697A65027Q004003063Q00737472696E6703063Q00666F726D6174031A3Q004C696E653A2025643Q205A6F6E653A20256420E2809320256403043Q006D61746803053Q00666C2Q6F72030B3Q003Q20E2869020484F4C4403063Q0072616E646F6D02B81E85EB51B89E3F020AD7A3703D0AB73F030E3Q003Q20E286922052454C45415345027B14AE47E17AA43F02EC51B81E85EBC13F03133Q003Q20494E5349444520E2869220434C49434B02B81E85EB51B88E3F02EC51B81E85EBA13F03043Q007469636B029A5Q99E93F029A5Q99A93F001A012Q00121F3Q00013Q0020225Q000200122Q000100038Q000200019Q0000064Q0018000100010004063Q001800012Q00013Q00013Q0030163Q000400052Q00013Q00023Q0006045Q00013Q0004065Q00012Q00013Q00033Q00201B5Q000600122Q000200073Q00122Q000300073Q00122Q000400076Q00055Q00122Q000600083Q00122Q000700078Q000700019Q006Q00023Q0004065Q00012Q00013Q00043Q00201E5Q00090012360002000A4Q00343Q000200020006043Q002B00013Q0004063Q002B00012Q00013Q00043Q0020085Q000A00206Q000900122Q0002000B8Q0002000200064Q002B00013Q0004063Q002B00012Q00013Q00043Q0020315Q000A00206Q000B00206Q000900122Q0002000C8Q000200020006043Q003000013Q0004063Q0030000100201000013Q000D0006190001003F000100010004063Q003F00012Q0001000100023Q00060400013Q00013Q0004065Q00012Q0001000100033Q00201B00010001000600122Q000300073Q00122Q000400073Q00122Q000500076Q00065Q00122Q000700083Q00122Q000800076Q0001000800014Q00018Q000100023Q0004065Q000100201E00013Q00090012360003000E4Q003400010003000200061900010045000100010004063Q004500010004065Q000100201E0002000100090012360004000F4Q00340002000400020006190002004B000100010004063Q004B00010004065Q000100201E000300020009001228000500106Q00030005000200202Q00040002000900122Q000600116Q00040006000200062Q0004005700013Q0004063Q0057000100201000040002001100201E000400040009001236000600124Q00340004000600020006040003005B00013Q0004063Q005B000100061900040074000100010004063Q007400012Q0001000500013Q0030170005000400134Q000500033Q00202Q00050005000600122Q000700073Q00122Q000800073Q00122Q000900076Q000A00013Q00122Q000B00083Q00122Q000C00076Q0005000C000100122Q000500013Q00202Q00050005000200122Q000600146Q0005000200014Q000500033Q00202Q00050005000600122Q000700073Q00122Q000800073Q00122Q000900076Q000A5Q00122Q000B00083Q00122Q000C00076Q0005000C000100046Q000100201000050003001500200B00050005001600202Q00060003001700202Q00060006001600202Q0006000600184Q00050005000600202Q00060004001500202Q00060006001600202Q00070004001700202Q0007000700164Q0007000600074Q000800013Q00122Q000900193Q00202Q00090009001A00122Q000A001B3Q00122Q000B001C3Q00202Q000B000B001D4Q000C00056Q000B0002000200122Q000C001C3Q00202Q000C000C001D4Q000D00066Q000C0002000200122Q000D001C3Q00202Q000D000D001D4Q000E00076Q000D000E6Q00093Q000200102Q00080004000900062Q000500B0000100060004063Q00B000012Q0001000800014Q0007000900013Q00202Q00090009000400122Q000A001E6Q00090009000A00102Q0008000400094Q000800023Q00062Q000800A7000100010004063Q00A700012Q0001000800033Q00201B00080008000600122Q000A00073Q00122Q000B00073Q00122Q000C00076Q000D00013Q00122Q000E00083Q00122Q000F00076Q0008000F00014Q000800016Q000800023Q00121F000800013Q00202D00080008000200122Q0009001C3Q00202Q00090009001F4Q00090001000200202Q00090009002000102Q0009002100094Q00080002000100044Q003Q01000630000700CF000100050004063Q00CF00012Q0001000800014Q0021000900013Q00202Q00090009000400122Q000A00226Q00090009000A00102Q0008000400094Q000800023Q00062Q000800C600013Q0004063Q00C600012Q0001000800033Q00201B00080008000600122Q000A00073Q00122Q000B00073Q00122Q000C00076Q000D5Q00122Q000E00083Q00122Q000F00076Q0008000F00014Q00088Q000800023Q00121F000800013Q00202D00080008000200122Q0009001C3Q00202Q00090009001F4Q00090001000200202Q00090009002300102Q0009002400094Q00080002000100044Q003Q012Q0001000800014Q0021000900013Q00202Q00090009000400122Q000A00256Q00090009000A00102Q0008000400094Q000800023Q00062Q000800E300013Q0004063Q00E300012Q0001000800033Q00201B00080008000600122Q000A00073Q00122Q000B00073Q00122Q000C00076Q000D5Q00122Q000E00083Q00122Q000F00076Q0008000F00014Q00088Q000800024Q0001000800033Q00203300080008000600122Q000A00073Q00122Q000B00073Q00122Q000C00076Q000D00013Q00122Q000E00083Q00122Q000F00076Q0008000F000100122Q000800013Q00202Q00080008000200122Q000900036Q0008000200014Q000800033Q00202Q00080008000600122Q000A00073Q00122Q000B00073Q00122Q000C00076Q000D5Q00122Q000E00083Q00122Q000F00076Q0008000F000100122Q000800013Q00202Q00080008000200122Q0009001C3Q00202Q00090009001F4Q00090001000200202Q00090009002600102Q0009002700094Q0008000200012Q0001000800023Q00060400083Q00013Q0004065Q000100121F000800284Q001C00080001000200202B00080008002900262300083Q0001002A0004065Q00012Q0001000800033Q00201B00080008000600122Q000A00073Q00122Q000B00073Q00122Q000C00076Q000D5Q00122Q000E00083Q00122Q000F00076Q0008000F00014Q00088Q000800023Q001202000800013Q00202Q00080008000200122Q0009002A6Q00080002000100046Q00012Q000C3Q00017Q00", GetFEnv(), ...);
