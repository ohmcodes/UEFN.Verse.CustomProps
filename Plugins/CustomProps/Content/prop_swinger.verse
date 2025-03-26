
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
prop_swinger := class(creative_device):

    @editable
    PropsToSwing : []damage_volume_device = array{}
    @editable 
    TriggerButtonOn : trigger_device = trigger_device{}
    @editable 
    TriggerButtonOff : trigger_device = trigger_device{}

    @editable
    DelayInSeconds : float = 1.0

    @editable
    RotationDegree : float = 45.0
    @editable
    TimeRotation: float = 1.5

    CurrentAngle : float = 0.0
    var RotatingForward : logic = true
    var CurrentRotation : float = 0.0
    var LoopDegree : float = 0.0
    var StopSwing : logic  = false
    var isRotation : logic = false

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        TriggerButtonOn.TriggeredEvent.Subscribe(OnTriggeredEvent)
        TriggerButtonOff.TriggeredEvent.Subscribe(OffTriggeredEvent)

    OnTriggeredEvent(InAgent: ?agent):void=
        set StopSwing = true
        set CurrentRotation = RotationDegree
        set LoopDegree = CurrentRotation * 2

        for(PropInstance : PropsToSwing):
            spawn {SwingProp(PropInstance)}

    OffTriggeredEvent(InAgent: ?agent):void=
        set StopSwing = false

        for (PropInstance : PropsToSwing):
            PropInstance.Disable()
    
    SwingProp(Prop: damage_volume_device)<suspends>:void=
        loop:
            if(StopSwing = false):
                break

            PropTransform := Prop.GetTransform()
            PropLocation := PropTransform.Translation
            PropRotation := PropTransform.Rotation
        

            if(RotatingForward = true):
                NewRotation := PropRotation.ApplyLocalRotationY(CurrentRotation)
                Prop.MoveTo(PropLocation, NewRotation, TimeRotation)
                set RotatingForward = false
                set CurrentRotation = LoopDegree * -1
                Sleep(DelayInSeconds)

            else:
                NewRotation := PropRotation.ApplyLocalRotationY(CurrentRotation)
                Prop.MoveTo(PropLocation, NewRotation, TimeRotation)
                set RotatingForward = true
                set CurrentRotation = LoopDegree * 1
                Sleep(DelayInSeconds)