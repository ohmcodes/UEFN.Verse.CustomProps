
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.


prop_pickup_class := class<concrete>:
    @editable
    PropPickup : creative_prop = creative_prop {}
    @editable
    ButtonPickup : button_device = button_device{}
    @editable
    SE_player : audio_player_device = audio_player_device{}

    var ToggleVisibility : logic = true

HandlerButton := class():
    Device : prop_pickup
    SelectedPropClass : prop_pickup_class

    PropButtonHandler(Agent : agent):void=
        Device.ButtonOnEvent(Agent, SelectedPropClass)

# A Verse-authored creative device that can be placed in a level
prop_pickup := class(creative_device):
    @editable
    PropClass : []prop_pickup_class = array{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for (PClassInstance : PropClass):
            spawn {PrepareProp(PClassInstance)}

    PrepareProp(PropIns : prop_pickup_class)<suspends>:void=
        PropIns.ButtonPickup.InteractedWithEvent.Subscribe(HandlerButton{Device:=Self, SelectedPropClass:=PropIns}.PropButtonHandler)

    ButtonOnEvent(Agent : agent, SelectedPropClass : prop_pickup_class):void=
        spawn{HideProp(SelectedPropClass)}

    HideProp(PropIns : prop_pickup_class)<suspends>:void=
        if(PropIns.ToggleVisibility = true):
            PropIns.PropPickup.Hide()
            PropIns.SE_player.Play()
            set PropIns.ToggleVisibility = false
        else:
            PropIns.PropPickup.Show()
            PropIns.SE_player.Stop()
            set PropIns.ToggleVisibility = true

        


    