using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }

                                # Usamos a classe basic_interactable_component
                                # como base para criar um componente interativo
                                # Como o Fortnite é um jogo pronto, muitas das lógicas
                                # básicas já estão prontas, apenas precisamos estender
                                # as funcionalidades para criar a lógica que desejamos
light_switch_component<public> := class(basic_interactable_component):

    # Mensagem que aparece quando o jogador interage com a luz
    @editable
    CustomInteractMessage<localizes>: message = "On/Off"

    # Variável que vai controlar o estado da luz
    var IsLightOn : logic = true

    OnBeginSimulation<override>():void =
        # OnBeginSimulation é chamado quando o jogo inicia
        # É a função que dá início a tudo
        # Quem chama ela é o próprio motor do jogo, que fica fora do nosso controle
        
        # Nesse caso, precisamos garantir que o estado do componente de luz (que já está no mundo)
        # esteja sincronizado com a nossa variavel IsLightOn, que é a que vamos usar para controlar a luz
        SyncLightState()

        # Programação de jogos, em sua maioria, é baseada em eventos:
        # Quando algo acontece, um evento é disparado e podemos reagir a ele

        # Aqui definimos que quando o evento 'SucceededEvent' for disparado
        # a função 'OnInteractionSucceeded' será chamada (Subscription)
        SucceededEvent.Subscribe(OnInteractionSucceeded)

    # Função que é chamada quando o jogador interage com o componente
    OnInteractionSucceeded(Agent:agent):void =
        ToggleLight()

    # Função principal que vai controlar a luz, ligando e desligando
    ToggleLight<public>():void =
        # Aqui pegamos o componente de luz (light_component)
        # Que fica na mesma entidade que o nosso componente interativo (light_switch_component)
        # Por isso usamos a propriedade Entity 
        if (LightComponent := Entity.GetComponent[light_component]):
            Print("Alterando o estado da luz")
            # Se a luz estiver ligada, desligamos, se estiver desligada, ligamos
            if (IsLightOn?):
                SetLightOff(LightComponent)
            else:
                SetLightOn(LightComponent)

    SetLightOn<public>(LightComponent : light_component):void =
        Print("Ligando a luz")
        # Método do proprio componente de luz (Enable) que liga a luz
        LightComponent.Enable()
        # Atualizamos a nossa variável de estado para refletir que a luz está ligada
        set IsLightOn = true

    SetLightOff<public>(LightComponent : light_component):void =
        Print("Desligando a luz")
        # Método do proprio componente de luz (Disable) que desliga a luz
        LightComponent.Disable()
        # Atualizamos a nossa variável de estado para refletir que a luz está desligada
        set IsLightOn = false

    SyncLightState<public>():void =
        if (LightComponent := Entity.GetComponent[light_component]):
            if (LightComponent.IsEnabled[]):
                set IsLightOn = true
            else:
                set IsLightOn = false

    # Função herdada do basic_interactable_component que define a mensagem
    # que aparece quando o jogador interage com o componente
    InteractMessage<override>(Agent:agent)<reads><decides>:message =
        return CustomInteractMessage