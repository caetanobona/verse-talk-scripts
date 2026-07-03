using { /Verse.org }
using { /Verse.org/Native }
using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }

mutator_zone_component<public> := class<final_super>(component):
    var AgentEnterEvent<public> : agent_event = agent_event{}
    var AgentExitEvent<public> : agent_event = agent_event{}

    OnSimulate<override>()<suspends>:void =
        Initialize()

    Initialize<public>():void=
        # Pegando componente de Mesh da entidade
        if (EntityMesh := Entity.GetComponent[mesh_component]):
            # Subscribe nos eventos de colisão da mesh (implementados pelo motor do jogo)
            EntityMesh.EntityEnteredEvent.Subscribe(CheckColisionEnter)
            EntityMesh.EntityExitedEvent.Subscribe(CheckColisionExit)

    CheckColisionEnter<public>(EntityHit:entity):?agent=
        Print("Alguem entrou na mesh")

        # Pegando o agente que entrou na mesh (se houver)
        AgentHit := GetAgentInEntity(EntityHit)

        # Verificando se o agente é válido
        # Pois o retorno da função é do tipo option ( ?agent )
        if(Agent := AgentHit?):
            # Disparando o evento de entrada
            AgentEnterEvent.Signal(Agent)

        return AgentHit

    # Mesma lógica da função acima, apenas muda o evento sinalizado
    CheckColisionExit<public>(EntityHit:entity):?agent=
        AgentHit :=  GetAgentInEntity(EntityHit)
        if(Agent := AgentHit?):
            AgentExitEvent.Signal(Agent)
        return AgentHit

    GetAgentInEntity<public>(CheckEntity:entity):?agent=
        # A CheckEntity é a entidade que entrou na mesh
        # Aqui pegamos os componentes dela com GetComponents()
        for(Component : CheckEntity.GetComponents()):
            # O componente de jogador se chama 'fort_character'
            # Então procuramos por ele na lista de componentes da entidade
            if(FortChar:=fort_character[Component],Agent:=FortChar.GetAgent[]):
                return option { Agent }
        return false