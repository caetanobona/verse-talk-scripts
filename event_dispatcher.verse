using { /Verse.org }
using { /Verse.org/Assets }
using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }


# ----------------------------------------------------------------------------
# Generic cancelable
# ----------------------------------------------------------------------------
base_cancelable<public> := class(cancelable):
    var HasBeenCanceled<public>: logic = false

    Cancel<override>()<transacts>: void =
        set HasBeenCanceled = true

    IsCanceled<public>()<transacts>: logic =
        return HasBeenCanceled

generic_cancelable<public>(Payload:type) := class(cancelable):
    Callback<public>: type {_(:Payload): void}
    Token<public>: base_cancelable = base_cancelable{}

    Cancel<override>()<transacts>: void =
        Token.Cancel()

    IsCanceled<public>()<transacts>: logic =
        return Token.IsCanceled()

# ----------------------------------------------------------------------------
# Generic subscriptions (interface + concrete store)
# ----------------------------------------------------------------------------
generic_subscriptions<public>(Payload:type) := interface():
    GetSubscriptions<public>()<transacts>: []generic_cancelable(Payload)
    SetSubscriptions<public>(NewSubs: []generic_cancelable(Payload))<transacts>: void

# ----------------------------------------------------------------------------
# Generic event
# ----------------------------------------------------------------------------
generic_event<public>(Payload:type) := class:
    Subscriptions<public>: generic_subscriptions(Payload)

    Subscribe<public>(Callback: type {_(:Payload): void})<transacts>: cancelable =
        var Current: []generic_cancelable(Payload) = Subscriptions.GetSubscriptions()
        NewSub := generic_cancelable(Payload){ Callback := Callback }
        set Current = Current + array{NewSub}
        Subscriptions.SetSubscriptions(Current)
        return NewSub

    Signal<public>(PayloadValue: Payload): void =
        var Active: []generic_cancelable(Payload) = array{}
        for (Entry : Subscriptions.GetSubscriptions()):
            if (not Entry.IsCanceled()?):
                Entry.Callback(PayloadValue)
                set Active = Active + array{Entry}
        Subscriptions.SetSubscriptions(Active)

    SignalSequenced<public>(PayloadValue: Payload, StepDelay: float)<suspends>: void =
        var Active: []generic_cancelable(Payload) = array{}
        for (Entry : Subscriptions.GetSubscriptions()):
            if (not Entry.IsCanceled()?):
                Entry.Callback(PayloadValue)
                set Active = Active + array{Entry}
                if (StepDelay > 0.0):
                    Sleep(StepDelay)
                else:
                    Sleep(0.0)
        Subscriptions.SetSubscriptions(Active)

    Clear(): void =
        Subscriptions.SetSubscriptions(array{})

# ----------------------------------------------------------------------------
# Concrete specializations
# ----------------------------------------------------------------------------

int_event_subscriptions<public> := class(generic_subscriptions(int)):
    var Entries<public> : []generic_cancelable(int) = array{}

    GetSubscriptions<override>()<transacts>:[]generic_cancelable(int) =
        Entries

    SetSubscriptions<override>(NewSubs:[]generic_cancelable(int))<transacts>:void =
        set Entries = NewSubs

int_changed_event<public> := class(generic_event(int)):
    Subscriptions<override> : generic_subscriptions(int) = int_event_subscriptions{}
    
entity_event_subscriptions<public> := class(generic_subscriptions(entity)):
    var Entries<public>: []generic_cancelable(entity) = array{}

    GetSubscriptions<override>()<transacts>: []generic_cancelable(entity) =
        return Entries

    SetSubscriptions<override>(NewSubs: []generic_cancelable(entity))<transacts>: void =
        set Entries = NewSubs

entity_event<public> := class(generic_event(entity)):
    Subscriptions<override>: generic_subscriptions(entity) = entity_event_subscriptions{}

player_event_subscriptions<public> := class(generic_subscriptions(tuple(player, component))):
    var Entries<public>: []generic_cancelable(tuple(player, component)) = array{}

    GetSubscriptions<override>()<transacts>: []generic_cancelable(tuple(player, component)) =
        return Entries

    SetSubscriptions<override>(NewSubs: []generic_cancelable(tuple(player, component)))<transacts>: void =
        set Entries = NewSubs

player_event<public> := class(generic_event(tuple(player, component))):
    Subscriptions<override>: generic_subscriptions(tuple(player, component)) = player_event_subscriptions{}

agent_event_subscriptions<public> := class(generic_subscriptions(agent)):
    var Entries<public>: []generic_cancelable(agent) = array{}

    GetSubscriptions<override>()<transacts>: []generic_cancelable(agent) =
        return Entries

    SetSubscriptions<override>(NewSubs: []generic_cancelable(agent))<transacts>: void =
        set Entries = NewSubs

agent_event<public> := class(generic_event(agent)):
    Subscriptions<override>: generic_subscriptions(agent) = agent_event_subscriptions{}

void_event_subscriptions<public> := class(generic_subscriptions(tuple())):
    var Entries<public>: []generic_cancelable(tuple()) = array{}

    GetSubscriptions<override>()<transacts>: []generic_cancelable(tuple()) =
        return Entries

    SetSubscriptions<override>(NewSubs: []generic_cancelable(tuple()))<transacts>: void =
        set Entries = NewSubs

void_event<public> := class(generic_event(tuple())):
    Subscriptions<override>: generic_subscriptions(tuple()) = void_event_subscriptions{}


