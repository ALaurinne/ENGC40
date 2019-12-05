module shuffler
(
    input start, // Recebe da FSM
    input [3:0] memData, // Recebe da memoria Ram
    input clock,

    output reg [5:0] nextA, // Envia para a memoria
    output reg [3:0] newData, // Envia para a memoria
    output reg wren, // Habilita escrever na memoria
    output reg memClock, 
    output reg finish // Envia para a FSM

);

reg [3:0] memF; // Salva a memoria do primeiro
reg [3:0] memS; // Salva a memoria do segundo
reg [5:0] addrsF; // Valor do primeiro endereço de memoria 
reg [5:0] addrsS; // Valor do segundo endereço de memoria
reg [3:0] stateA, stateF; // Estados Atual e Futuro

parameter   Begin           = 4'b 0000,
            Read_Ram_F      = 4'b 0001,
            Save_Ram_F      = 4'b 0010,
            Next_Addrs      = 4'b 0011,
            Read_Ram_S      = 4'b 0100,
            Save_Ram_S      = 4'b 0101,
            Write_S         = 4'b 0110,
            Return_Addrs    = 4'b 0111,
            Write_F         = 4'b 1000,
            Controler       = 4'b 1001,
            Incrementa_F    = 4'b 1010,
            Incrementa_S    = 4'b 1011,
            Decrementa_S    = 4'b 1100,
            Change_Addrs    = 4'b 1101,
            Shuffled        = 4'b 1111;

//Atualizando o estado
always @(posedge clock)
begin
    if (start)
        begin
            stateA <= stateF;

            case(stateF)
                Read_Ram_F:
                    memF <= memData; // É armazenada a memoria do primeiro local
                
                Read_Ram_S:
                    memS <= memData; // É armazenada a memoria do segundo local
                
                Incrementa_F:
                    addrsF <= addrsF + 1; // Aumenta o valor do primeiro local

                Decrementa_S:
                    addrsS <= addrsS - 2; // Decrementa o valor do próximo local
                
                Incrementa_S:
                    addrsS <= addrsS + 4; // Incrementa o valor do próximo local
            endcase
        end
    else
        begin
            stateA <= Begin; // Caso esteja desativado, deve retornar ao estado inicial.
            addrsF <= 0; // Limpa a variavel do endereço
            addrsS <= 36; // Retorna ao meio da memoria 
        end
end

//DPE E DPS
always @(*)
begin
    // Default
    wren = 0;
    memClock = 0;
    finish = 0;
    
    case(stateA)
        Begin: // Inicia o embaralhador
            begin
                stateF = Read_Ram_F;
                nextA = addrsF;
            end

        Read_Ram_F: // Lê o valor no primeiro local
            begin
                stateF = Save_Ram_F;
                nextA = addrsF;
                memClock = 1;
            end
        
        Save_Ram_F: // Armazena o valor do primeiro local
            begin
                stateF = Next_Addrs;
                memF = memData;
            end

        Next_Addrs: // Pega o próximo endereço de memoria
            begin
                stateF = Read_Ram_S;
                nextA = addrsS;
            end

        Read_Ram_S: // Lê o valor no segundo local
            begin
                stateF = Save_Ram_S;
                nextA = addrsS;
                memS = memData;
            end

        Save_Ram_S: // Armazena o valor do segundo local
            begin
                stateF = Write_S;
                nextA = addrsS;
                memClock = 1;
                memS = memData;
            end

        Write_S: // Sobrescreve o valor do segundo local com a primeira data
            begin
                stateF = Return_Addrs;
                memClock = 1;
                wren = 1;
                newData = memF;
            end

        Return_Addrs: // Retorna ao endereço do primeiro local 
            begin
                stateF = Write_F;
                nextA = addrsF;
            end

        Write_F: // Sobrescreve o valor do primeiro local com a segunda data
            begin
                stateF = Controler;
                memClock = 1;
                wren = 1;
                newData = memS;
            end

        Controler: // Verifica se o Embaralhador já pode ser encerrado ou não
            begin
                if(addrsF<51)
                stateF = Incrementa_F;
                else 
                stateF = Shuffled;
            end

        Incrementa_F: // Incrementa um valor no endereço F e verifica para qual estado o endereço S deve ir 
            begin
                if(addrsS<3)
                stateF = Incrementa_S;
                else if (addrsS>49)
                stateF = Decrementa_S;
            end

        Incrementa_S: // Incrementa um valor no endereço S
            stateF = Change_Addrs;

        Decrementa_S: // Decrementa um valor no endereço S
            stateF = Change_Addrs;

        Change_Addrs: // Muda para o endereço com o novo addrsF ( endereço F ) e retorna a Read_Ram_F
            begin
                stateF = Read_Ram_F;
                nextA = addrsF;
            end

        Shuffled: // O baralho foi embaralhado e está pronto.
            begin
                finish = 1;
                stateF = Shuffled;
            end
    endcase
end

endmodule
