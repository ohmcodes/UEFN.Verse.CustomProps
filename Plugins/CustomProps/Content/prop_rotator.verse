
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
prop_rotator := class(creative_device):

    @editable
    PropsToRotate : creative_prop = creative_prop{}
    @editable
    PropsToRotateAuto : []creative_prop = array{}
    @editable
    StartButton:button_device = button_device{}
    @editable
    TriggerButtonOn : trigger_device = trigger_device{}
    @editable
    TriggerButtonOff : trigger_device = trigger_device{}
    @editable
    TriggerAutoButtonOn : trigger_device = trigger_device{}
    @editable
    TriggerAutoButtonOff : trigger_device = trigger_device{}


    @editable
    RotationTime : float = 2.0
    @editable
    RotationDegree : float = 180.0
    
    var isEnabled : logic = false
    var isAutoEnabled : logic = false

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        StartButton.InteractedWithEvent.Subscribe(OnButtonPressed)
        TriggerButtonOn.TriggeredEvent.Subscribe(OnTriggeredEvent)
        TriggerButtonOff.TriggeredEvent.Subscribe(OffTriggeredEvent)
        TriggerAutoButtonOn.TriggeredEvent.Subscribe(OnAutoTriggeredEvent)
        TriggerAutoButtonOff.TriggeredEvent.Subscribe(OffAutoTriggeredEvent)

    OnButtonPressed(Agent:agent):void=

        if(isEnabled=false):
            return

        PropTransform := PropsToRotate.GetTransform()
        PropLocation := PropTransform.Translation
        PropRotation := PropTransform.Rotation

        NewRotation := PropRotation.ApplyYaw(RotationDegree)

        spawn {PropsToRotate.MoveTo(PropLocation, NewRotation, RotationTime)}

    OnTriggeredEvent(InAgent: ?agent):void=
        set isEnabled = true

    OffTriggeredEvent(InAgent: ?agent):void=
        set isEnabled = false

    OnAutoTriggeredEvent(InAgent: ?agent):void=
        set isAutoEnabled = true
        
        for(PropInstance : PropsToRotateAuto):
            spawn{ AutomaticRotator(PropInstance) }

    OffAutoTriggeredEvent(InAgent: ?agent):void=
        set isAutoEnabled = false

    AutomaticRotator(Prop : creative_prop)<suspends>:void=
        loop:
            if(isAutoEnabled=false):
                break
            
            PropTransform := Prop.GetTransform()
            PropLocation := PropTransform.Translation
            PropRotation := PropTransform.Rotation
    
            NewRotation := PropRotation.ApplyYaw(RotationDegree)
    
            Prop.MoveTo(PropLocation, NewRotation, RotationTime)
            #Sleep(1.0)










