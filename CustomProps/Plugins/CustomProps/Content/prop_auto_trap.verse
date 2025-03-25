
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

prop_auto_trap_class := class<concrete>:
    @editable
    PropTraps : damage_volume_device = damage_volume_device{}
    @editable 
    LocX : float = 0.0
    @editable 
    LocY : float = 0.0
    @editable 
    LocZ : float = 0.0
    @editable 
    BeforeDelayInSeconds : float = 1.0
    @editable 
    AfterDelayInSeconds : float = 1.0
    @editable 
    TimeSpeed: float = 0.2

    var isStillMoving : logic = false

# A Verse-authored creative device that can be placed in a level
prop_auto_trap := class(creative_device):

    @editable
    PropClass : []prop_auto_trap_class = array{}
    @editable
    TriggerButtonOn : trigger_device = trigger_device{}
    @editable
    TriggerButtonOff : trigger_device = trigger_device{}

    var isEnabled : logic = false

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        TriggerButtonOn.TriggeredEvent.Subscribe(OnTriggeredEvent)
        TriggerButtonOff.TriggeredEvent.Subscribe(OffTriggeredEvent)

    OnTriggeredEvent(InAgent: ?agent):void=
        if(isEnabled = false):
            set isEnabled = true

            for (PClassInstance : PropClass):
                spawn {PrepareProp(PClassInstance)}

    OffTriggeredEvent(InAgent: ?agent):void=
        set isEnabled = false

    PrepareProp(PropIns : prop_auto_trap_class)<suspends>:void=
        loop:
            if(isEnabled = false):
                break

            MoveLoop(PropIns)

    
    MoveLoop(PropIns : prop_auto_trap_class)<suspends>:void=
        PropTransform := PropIns.PropTraps.GetTransform()
        PropLocation := PropTransform.Translation
        PropRotation := PropTransform.Rotation

        NewLocation := vector3 {
            X:= PropTransform.Translation.X + PropIns.LocX,
            Y:= PropTransform.Translation.Y + PropIns.LocY,
            Z:= PropTransform.Translation.Z + PropIns.LocZ
        }

        set PropIns.isStillMoving = true
        
        # move forward
        PropIns.PropTraps.MoveTo(NewLocation, PropRotation, PropIns.TimeSpeed)
        Sleep(PropIns.BeforeDelayInSeconds)

        # return
        PropIns.PropTraps.MoveTo(PropLocation, PropRotation, PropIns.TimeSpeed)
        Sleep(PropIns.AfterDelayInSeconds)

        set PropIns.isStillMoving = false