using { /Fortnite.com/Devices }
using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }

mutator_zone_message_manager := class(creative_device):

    # Referência para o dispositivo da mutator zone do mundo
    @editable
    MutatorZoneDevice : mutator_zone_device = mutator_zone_device{}

    # Referência para a entidade da nossa mutator zone
    @editable
    MutatorZoneComponentEntity : entity = entity{}

    # Referência para o dispositivo de mensagem
    @editable
    HudMessage : hud_message_device = hud_message_device{}

    # Mensagem para quando o jogador entra na mutator zone do dispositivo
    @editable
    DeviceEnterMessage<localizes>: message = "Entrou pela mutator_zone_device"

    # Mensagem para quando o jogador sai da mutator zone do dispositivo
    @editable
    DeviceExitMessage<localizes>: message ="Saiu pela mutator_zone_device"

    # Mensagem para quando o jogador entra na mutator zone do componente
    @editable
    ComponentEnterMessage<localizes>: message ="Entrou pela mutator_zone_component"

    # Mensagem para quando o jogador sai da mutator zone do componente
    @editable
    ComponentExitMessage<localizes>: message ="Saiu pela mutator_zone_component"

    # Boas práticas de programação de jogos: 
    # Sempre que você se inscrever em um evento 
    # você deve se desinscrever dele quando não precisar mais.

    # Isso libera espaço na memória e evita que o evento continue 
    # chamando funções que não existem mais, o que pode causar erros.
    var DeviceEnterSubscription : ?cancelable = false
    var DeviceExitSubscription : ?cancelable = false
    var ComponentEnterSubscription : ?cancelable = false
    var ComponentExitSubscription : ?cancelable = false

    OnBegin<override>()<suspends>:void =
        # FuncaoExemplo()

        # Salvamos as inscrições nas variáveis para podermos cancelar depois
        set DeviceEnterSubscription = option{ MutatorZoneDevice.AgentEntersEvent.Subscribe(OnMutatorZoneDeviceEnter) }
        set DeviceExitSubscription = option{ MutatorZoneDevice.AgentExitsEvent.Subscribe(OnMutatorZoneDeviceExit) }

        if (MutatorZoneComponent := MutatorZoneComponentEntity.GetComponent[mutator_zone_component]):
            set ComponentEnterSubscription = option{ MutatorZoneComponent.AgentEnterEvent.Subscribe(OnMutatorZoneComponentEnter) }
            set ComponentExitSubscription = option{ MutatorZoneComponent.AgentExitEvent.Subscribe(OnMutatorZoneComponentExit) }

    FuncaoExemplo<internal>()<suspends>:void =
        var SegundosQuePassaram : int = 0
        loop:
            Sleep(1.0)
            Print("Passou um segundo")
            set SegundosQuePassaram = SegundosQuePassaram + 1
            if(SegundosQuePassaram >= 5):
                Print("Passaram 5 segundos")
                break

    OnEnd<override>():void =
        # Cancelando as inscrições nos eventos
        if (Subscription := DeviceEnterSubscription?):
            Subscription.Cancel()
        if (Subscription := DeviceExitSubscription?):
            Subscription.Cancel()
        if (Subscription := ComponentEnterSubscription?):
            Subscription.Cancel()
        if (Subscription := ComponentExitSubscription?):
            Subscription.Cancel()

    OnMutatorZoneDeviceEnter(Agent:agent):void =
        ShowMessage(Agent, DeviceEnterMessage)

    OnMutatorZoneDeviceExit(Agent:agent):void =
        ShowMessage(Agent, DeviceExitMessage)

    OnMutatorZoneComponentEnter(Agent:agent):void =
        ShowMessage(Agent, ComponentEnterMessage)

    OnMutatorZoneComponentExit(Agent:agent):void =
        ShowMessage(Agent, ComponentExitMessage)

    # Função padrão para chamar o dispositivo de mensagem
    ShowMessage(Agent:agent, Text:message):void =
        spawn { FuncaoExemplo() }
        HudMessage.SetText(Text)
        # Exibindo a mensagem para o agente
        HudMessage.Show(Agent)
