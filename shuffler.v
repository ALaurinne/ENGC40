module shuffler
(
    input start, // Recebe da FSM
    input [3:0] memData, // Recebe da memoria Ram
    input [5:0] addrsS, // Recebe do contador
    input clock,

    output reg [5:0] nextA, // Envia para a memoria
    output reg [5:0] addrsF, // Envia para o contador
    output reg [3:0] newData, // Envia para a memoria
    output reg wren, // Habilita escrever na memoria
    output reg memClock, 
    output reg finish // Envia para a FSM

)

reg [3:0] memF; // Salva a memoria do primeiro
reg [3:0] memS; // Salva a memoria do segundo
reg [5:0] addrsSeilá; // Valor do próximo endereço de memoria 
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
                    addrsSeilá <= addrsSeilá - 2;
                
                Incrementa_S:
                    addrsSeilá <= addrsSeilá + 4;
            endcase
        end
    else
        begin
            stateA <= Begin; // Caso esteja desativado, deve retornar ao estado inicial.
            addrsF <= 0; // Limpa a variavel do endereço
            addrsSeilá = 36;
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
        Begin:
            begin
            stateF = Read_Ram_F;
            nextA = addrsF;
            end

        Read_Ram_F:
            begin
            stateF = Save_Ram_F;
            nextA = addrsF;
            memClock = 1;
            end
        
        Save_Ram_F:
            begin
            stateF = Next_Addrs;
            memF = memData;
            end

        Next_Addrs:
            begin
            stateF = Read_Ram_S;
            nextA = addrsSeilá;
            end

        Read_Ram_S:
            begin
            state F = Save_Ram_S;
            nextA = addrsSeilá;
            memS = memData;
            end

        Save_Ram_S:
            begin
            stateF = Write_S;
            nextA = addrsSeilá;
            memClock = 1;
            memS = memData;
            end

        Write_S:
            begin
            stateF = Return_Addrs;
            memClock = 1;
            wren = 1;
            newData = memF;
            end

        Return_Addrs:
            begin
            stateF = Write_F;
            nextA = addrsF;
            end

        Write_F:
            begin
            stateF = Controler;
            memClock = 1
            wren = 1
            newData = memS;
            end

        Controler:
            begin
                if(addrsF<51)
                stateF = Incrementa_F;
                else 
                stateF = Shuffled;
            end

        Incrementa_F:
            begin
                if(addrsSeilá<3)
                stateF = Incrementa_S;
                else if (addrsSeilá>49)
                stateF = Decrementa_S;
            end

        Incrementa_S:
            stateF = Change_Addrs;

        Decrementa_S:
            stateF = Change_Addrs;

        Change_Addrs:
            begin
            stateF = Read_Ram_F;
            nextA = addrsF;
            end

        Shuffled:
            begin
            finish = 1;
            stateF = Shuffled;
            end
end

