
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
prop_sliding_cdoor := class(creative_device):

    @editable
    PropsDoor : creative_prop = creative_prop{}
    @editable
    OpenButton : button_device = button_device{}
    @editable
    CloseButton : button_device = button_device{}
    @editable
    RotationDegree : float = -360.0
    @editable
    SE_PlayerOpen : audio_player_device = audio_player_device{}
    @editable
    SE_PlayerClose : audio_player_device = audio_player_device{}
    @editable
    LocX : float = 0.0
    @editable
    LocY : float = 0.0
    @editable
    LocZ : float = 0.0
    @editable
    TimeSpeed : float = 1.2

    var isOpen : logic = false

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        OpenButton.InteractedWithEvent.Subscribe(OpenDoor)
        CloseButton.InteractedWithEvent.Subscribe(CloseDoor)

    OpenDoor(Agent : agent):void=
        if(isOpen = false):
            set isOpen = true
            OpenAndClose(1.0)
            
    CloseDoor(Agent : agent):void=
        if(isOpen = true):
            set isOpen = false
            OpenAndClose(-1.0)

    OpenAndClose(doorOpen : float):void=

        PropTransform := PropsDoor.GetTransform()
        PropLocation := PropTransform.Translation
        PropRotation := PropTransform.Rotation

        NewLocation := vector3 {
            X:= PropTransform.Translation.X + LocX * doorOpen,
            Y:= PropTransform.Translation.Y + LocY * doorOpen,
            Z:= PropTransform.Translation.Z + LocZ * doorOpen
        }

        NewRotation := PropRotation.ApplyPitch(RotationDegree * doorOpen)

        SE_PlayerOpen.Play()

        spawn{PropsDoor.MoveTo(NewLocation, NewRotation, TimeSpeed)}
