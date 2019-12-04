module Adder(Clock, Reset, Sum, Card_Value, i_Ace, i_Face, Initial_Hand, Final_Hand, o_Ace, o_Face);

input Clock, Reset, Sum, Card_Value, i_Ace, i_Face, Initial_Hand;
output reg Final_Hand, o_Ace, o_Face;

reg[3:0]  Card_Value;
reg[4:0] Initial_Hand, Final_Hand, var_Result;
reg [2:0] EstadoAtual, EstadoFuturo;

    parameter
        Begin       = 3'b000;
        Chercker    = 3'b001;
        Ace         = 3'b010;
        Pending     = 3'b011;
        Face        = 3'b100;
        Final       = 3'b101;
        FSM         = 3'b110;

    initial
        begin
            //Inicia em Begin
            EstadoFuturo = Begin;

            //Variaveis Internar
            var_Face    = 1'b0;
            var_Ace     = 1'b0;
            var_Result  = 5'b00000;   

            //Saidas
            Final_Hand = 5'b00000;
            o_Face     = 1'b0;
            o_Ace      = 1'b0;
        end

    //Bloco para Decodificador de proximo Estado (DPE)
    always @ (Sum, EstadoAtual)    
        begin
            case(EstadoAtual)
                Begin: case({Sum})
                            1'b0:
                                EstadoFuturo = Begin;
                            
                            1'b1:
                                EstadoFuturo = Chercker;

                Chercker: case({Card_Value})

                Ace: 
                    EstadoFuturo = Final

                    if(i_Face == 0)
                        begin
                            var_Result = Initial_Hand + Card_Value;
                            var_Ace = 1'b1;
                        end
                    else
                        var_Result = Initial_Hand + 1011 // Adiciona + 11;

                Pending:
                    EstadoFuturo = Final;
                    var_Face = 1'b0;
                    var_Result = Initial_Hand + 10100 // Adiciona + 20;

                Face:
                    EstadoFuturo = Final;
                    var_Face = 1'b1;
                    var_Result = Initial_Hand + 1010 // Adiciona + 10;
                
                Final:
                    EstadoFuturo = FSM;
        end
    
    //Bloco de memoria
    always @ (posedge Clock, negedge Reset)
        begin
            
        end

    //Bloco para Decodificador de Saida (DS)
    always @ (Sum, EstadoAtual)
        begin
            //Default
            Final_Hand  = 5'b00000;
            o_Face      = 1'b0;
            o_Ace       = 1'b0;

            case(EstadoAtual)
                Final:
                    if(var_Face == 1)
                        o_Face = 1;

                    if(var_Ace = 1)
                        o_Ace = 1;
                    Final_Hand = var_Result;
        end

endmodule