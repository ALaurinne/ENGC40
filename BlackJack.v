module BlackJack(Clock, Reset, Hit, Pas, Player_H, Player_P, Dealer_H, Dealer_P, Winner, Tied, Loser);

input Clock, Reset, Hit, Pas;
output reg Player_H, Player_P, Dealer_H, Dealer_P, Winner, Tied, Loser;



reg[3:0] EstadoAtual, EstadoFuturo;

    parameter 
        Begin       =   4'b0000,
        Shuffle     =   4'b0001,
        Card_Palyer =   4'b0010,
        Card_Dealer =   4'b0011,
        Blackjack   =   4'b0100,
        Player_turn =   4'b0101,
        Dealer_turn =   4'b0110,
        Hit         =   4'b0111,
        Measure     =   4'b1000,
        Win         =   4'b1001,
        Tie         =   4'b1010,
        Lose        =   4'b1011;
    
    initial
        begin
            //Maquina se inicia em Begin
            EstadoFuturo = Begin;

            //Variaveis internas
            Hand_P = 5'b00000;
            Hand_D = 5'b00000;
            var_P_2_Cards = 1'b0;
            var_Turn_2 = 1'b0; 
            var_Time = 1'b0;
            var_Shuffle = 1'b0;
            var_Dealer_Play = 1'b0;
            var_Bj_Dealer = 1'b0;

            //Saidas
            Player_H = 1'b0;
            Player_P = 1'b0;
            Dealer_H = 1'b0;
            Dealer_P = 1'b0;
            Winner = 1'b0;
            Tied = 1'b0;
            Loser = 1'b0;
        end

    //Bloco para o Decodificador de Proximo Estado (DPE)
    always @ (Hit, Pas, EstadoAtual)
        begin
            case(EstadoAtual)
                Begin: 
                        EstadoFuturo = Shuffle;

                Shuffle: 
                        if(var_Shuffle = 1'b1)
                             begin
                                EstadoFuturo = Card_Player;
                            end
                        else
                            begin
                                EstadoFuturo = Shuffle;
                            end

                Card_Player:
                             if(var_P_2_Cards = 1'b0)
                                begin
                                    EstadoFuturo = Card_Dealer;    
                                    var_P_2_Cards = 1'b1;
                                end
                            else
                                begin
                                    EstadoFuturo = Card_Dealer;
                                end    

                Card_Dealer:
                            if(var_P_2_Cards == 1'b0)
                                begin
                                    EstadoFuturo = Card_Player
                                end
                            else
                                begin
                                    if(Hand_D = 5'b10101) // Avalia se o dealer fez Blackjack
                                        begin
                                            var_Bj_Dealer = 1'b1;
                                        end

                                    if(Hand_P < 5'b10101)
                                        begin
                                            EstadoFuturo = Player_Turn;
                                        end
                                    else
                                        begin
                                            EstadoFuturo = Blackjack;
                                        end
                                end

                Blackjack:
                            if(Hand_P == Hand_D)
                                EstadoFuturo = Tie;
                            else
                                EstadoFuturo = Win;

                Player_Turn: case({Hit, Pas})
                                2'b00:
                                    EstadoFuturo = Player_Turn; 
                                
                                2'b11:
                                    EstadoFuturo = Hit;

                                2'b10:
                                    EstadoFuturo = Hit;

                                2'b01:  begin
                                    if(var_Turn_2 == 1'b0)
                                        begin
                                            EstadoFuturo = Dealer_Turn;
                                            var_Dealer_Play = 1'b1;
                                        end
                                    else
                                        EstadoFuturo = Measure;
                                end
                endcase

                Dealer_Turn: 
                        if(Hand_D < 10000)
                                EstadoFuturo = Hit;
                        else
                            begin
                                EstadoFuturo = Player_Turn;
                                var_Turn_2 = 1'b1;
                                var_Dealer_Play = 1'b0;
                            end

                Hit:
                    if((Hand_D > 5'b10101) && (var_Dealer_Play == 1'b1))
                            EstadoFuturo = Win;
                    
                    if((Hand_P > 5'b10101) && (var_Dealer_Play == 1'b0))
                            EstadoFuturo = Lose;

                    if(var_Time == 1'b0)
                            EstadoFuturo = Hit;
                    else
                        begin
                            if(var_Dealer_Play == 1'b1)
                                EstadoFuturo = Dealer_Turn;
                            else
                                EstadoFuturo = Player_Turn;
                        end

                Measure: 
                    if((Hand_P == Hand_D) && (var_Bj_Dealer == 1'b0))
                        EstadoFuturo = Tie;
                    
                    if((Hand_D > Hand_P) || (var_Bj_Dealer == 1'b1))
                        EstadoFuturo = Lose;

                    if(Hand_P > Hand_D)
                        EstadoFuturo = Win;

                Tie: 
                    if(var_Time == 1'b0)
                        EstadoFuturo = Tie;

                Lose: 
                    if(var_Time == 1'b0)
                        EstadoFuturo = Lose;

                Win: 
                    if(var_Time == 1'b0)
                        EstadoFuturo = Win;
    end

    //Bloco para o elemento de memoria
    always @ (posedge Clock , negedge Reset)
        begin
            if(Reset)
                EstadoAtual <= Begin;
            else    
               EstadoAtual <= EstadoFuturo;
    end

    //Bloco para o Decodificador de Saida (DS)
    always @ (Hit, Pas, EstadoAtual)
        begin
            //Default
            EstadoFuturo = Begin;
            Player_H = 1'b0;
            Player_P = 1'b0;
            Dealer_H = 1'b0;
            Dealer_P = 1'b0;
            Winner = 1'b0;
            Tied = 1'b0;
            Loser = 1'b0;

            case(EstadoAtual)
                Blackjack:
                            if(Hand_P == Hand_D)
                                    Tied = 1'b1;
                            else
                                begin
                                    Winner = 1'b1;

                Player_Turn: case({Hit, Pas})
                                2'b11:  begin
                                    Player_H = 1'b1;

                                2'b10:  begin
                                    Player_H = 1'b1;

                                2'b01:  begin
                                    if(var_Turn_2 == 1'b0)
                                        Player_P = 1'b1;
                                    else
                                        Player_P = 1'b1;
                                end
                endcase

                Dealer_Turn: 
                        if(Hand_D < 10000)
                            Dealer_H = 1'b1;
                        else
                            Dealer_P = 1'b1;

                Measure: 
                    if((Hand_P == Hand_D) && (var_Bj_Dealer == 1'b0))
                        Tied = 1'b1;
                    
                    if((Hand_D > Hand_P) || (var_Bj_Dealer == 1'b1))
                        Loser = 1'b1;

                    if(Hand_P > Hand_D)
                        Winner = 1'b1;

                Tie: 
                    if(var_Time == 1'b0)
                        Tied = 1'b1;

                Lose: 
                    if(var_Time == 1'b0)
                        Loser = 1'b1;

                Win: 
                    if(var_Time == 1'b0)
                        Winner = 1'b1;
        end
end module