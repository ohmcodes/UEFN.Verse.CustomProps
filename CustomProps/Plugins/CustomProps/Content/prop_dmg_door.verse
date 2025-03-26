
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

prop_door_class :=  class<concrete>:
    @editable
    PropDoor : damage_volume_device = damage_volume_device{}
    @editable
    OpenButton : button_device = button_device{}
    @editable
    SE_Player_Tick : audio_player_device = audio_player_device{}
    @editable
    SE_Player_Open : audio_player_device = audio_player_device{}
    @editable
    SE_Player_Close : audio_player_device = audio_player_device{}
    @editable 
    LocX : float = 0.0
    @editable 
    LocY : float = 0.0
    @editable 
    LocZ : float = 0.0
    @editable
    DelayBeforeOpen : float = 0.0
    @editable
    DelayBeforeClose : float = 0.0
    @editable
    TimeSpeedOpen : float = 1.2
    @editable
    TimeSpeedClose : float = 0.3

    var isStillMoving : logic = false

HandlerButtonOpen := class():
    Device : prop_dmg_door
    SelectedPropClass : prop_door_class

    PropButtonHandler(Agent : agent):void=
        Device.ButtonOpenEvent(Agent, SelectedPropClass)


# A Verse-authored creative device that can be placed in a level
prop_dmg_door := class(creative_device):

    @editable
    PropClass : []prop_door_class = array{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for (PClassInstance : PropClass):
            spawn {PrepareProp(PClassInstance)}

    PrepareProp(PropIns : prop_door_class)<suspends>:void=
        PropIns.OpenButton.InteractedWithEvent.Subscribe(HandlerButtonOpen{Device:=Self, SelectedPropClass:=PropIns}.PropButtonHandler)

    ButtonOpenEvent(Agent : agent, SelectedPropClass : prop_door_class):void=
        spawn{OpenDoor(SelectedPropClass)}

    OpenDoor(PropIns : prop_door_class)<suspends>:void=
        if(PropIns.isStillMoving = true):
            return

        set PropIns.isStillMoving = true

        PropTransform := PropIns.PropDoor.GetTransform()
        PropLocation := PropTransform.Translation
        PropRotation := PropTransform.Rotation

        NewLocation := vector3 {
            X:= PropTransform.Translation.X + PropIns.LocX,
            Y:= PropTransform.Translation.Y + PropIns.LocY,
            Z:= PropTransform.Translation.Z + PropIns.LocZ
        }
        
        Sleep(PropIns.DelayBeforeOpen)
        
        PropIns.SE_Player_Open.Play()
        PropIns.PropDoor.MoveTo(NewLocation, PropRotation, PropIns.TimeSpeedOpen)

        # Indictor for door closing
        SoundLooper(PropIns, PropLocation, PropRotation)
    
    SoundLooper(PropIns : prop_door_class, PropLocation : vector3, PropRotation : rotation)<suspends>:void=
        var Count : float = 0.0
        loop:
            if(Count = PropIns.DelayBeforeClose):
                PropIns.SE_Player_Tick.Stop()
                PropIns.SE_Player_Close.Play()
                PropIns.PropDoor.MoveTo(PropLocation, PropRotation, PropIns.TimeSpeedClose)
                set PropIns.isStillMoving = false
                break

            PropIns.SE_Player_Tick.Play()
            Sleep(1.0)
            set Count += 1.0
            Print("Current Count: {Count}")