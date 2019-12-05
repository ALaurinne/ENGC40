module Adder(Clock, Reset, Sum, Card_Value, i_Ace, i_Face, Initial_Hand, i_New_Memory_Adress, Final_Hand, o_Ace, o_Face, wren, o_Memory_Adress, memClock);

input Clock, Reset, Sum, i_Ace, i_Face;
input [3:0] Card_Value;
input [4:0] Initial_Hand;
input [5:0] i_New_Memory_Adress;

output reg [4:0] Final_Hand;
output reg [5:0] o_Memory_Adress;
output reg o_Ace, o_Face;
output reg wren;
output reg memClock;

reg [1:0] var_Ace, var_Face;
reg [5:0] var_Result;
reg [2:0] EstadoAtual, EstadoFuturo;

    parameter
        Begin       	= 3'b000,
		  Get_Card		= 3'b001,
        Chercker    	= 3'b010,
        Ace         	= 3'b011,
        Pending     	= 3'b100,
        Face        	= 3'b101,
        Final       	= 3'b110,
        FSM         	= 3'b111;

    initial
        begin
            //Inicia em Begin
            EstadoFuturo = Begin;

            //Variaveis Internas
            var_Face    = 1'b0;
            var_Ace     = 1'b0;
            var_Result  = 5'b00000;

            //Saidas
            Final_Hand = 5'b00000;
            o_Face     = 1'b0;
            o_Ace      = 1'b0;
        end

    //Bloco para Decodificador de proximo Estado (DPE)
    always @ (Sum or EstadoAtual)    
        begin
				wren = 0;
				memClock =0;
				
            case(EstadoAtual)
                Begin: case({Sum})
                            1'b0:
                                EstadoFuturo = Begin;
                            
                            1'b1:
                                EstadoFuturo = Chercker;
								endcase
					Get_Card:
							begin
								
							end

               Chercker:
								begin
									if(Card_Value == 1)
										EstadoFuturo = Ace;
										
									else if((Card_Value > 1) && (Card_Value <= 10))
										begin
											EstadoFuturo = Final;
											var_Result = Initial_Hand + Card_Value;
										end
										
									else if((Card_Value > 10) && (i_Ace == 1))
											EstadoFuturo = Pending;
											
									else if((Card_Value > 10) && (i_Ace == 0))
											EstadoFuturo = Face;
											
								end	
					
                Ace: 
						begin
                    EstadoFuturo = Final;

                    if(i_Face == 0)
                        begin
                            var_Result = Initial_Hand + Card_Value;
                            var_Ace = 1'b1;
                        end
                    else
                        var_Result = Initial_Hand + 1011; // Adiciona + 11
						end

                Pending:
							begin
							  EstadoFuturo = Final;
							  var_Face = 1'b0;
							  var_Result = Initial_Hand + 10100; // Adiciona + 20
							end

                Face:
							begin
								EstadoFuturo = Final;
								var_Face = 1'b1;
								var_Result = Initial_Hand + 1010; // Adiciona + 10
							end
                
                Final:
                    EstadoFuturo = FSM;
				endcase
			end
			
			//Bloco de memoria
    //always @ (posedge Clock, negedge Reset)
    //    begin
            
    //    end

	 
    //Bloco para Decodificador de Saida (DS)
    always @ (Sum or EstadoAtual)
        begin
            //Default
            Final_Hand  = 5'b00000;
            o_Face      = 1'b0;
            o_Ace       = 1'b0;

            case(EstadoAtual)
                Final:
					 begin
                    if(var_Face == 1)
                        o_Face = 1;

                    else if(var_Ace == 1)
								begin
									o_Ace = 1;
									Final_Hand = var_Result;
								end
					end
				endcase
	end
endmodule