
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

prop_button_class := class<concrete>:
    @editable
    Button : button_device = button_device{}
    @editable
    ButtonIndex : int = 0

    var IsPressed : logic = false


HandlerButtonPressed := class():
    Device : prop_button_sequence
    SelectedButtonClass : prop_button_class

    PropButtonHandler(Agent : agent):void=
        Device.ButtonPressedEvent(Agent, SelectedButtonClass)

# A Verse-authored creative device that can be placed in a level
prop_button_sequence := class(creative_device):
    @editable
    ButtonsClass : []prop_button_class = array{}
    @editable
    Tracker : tracker_device = tracker_device{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for(ButtonClassIns : ButtonsClass):
            spawn {PrepareButton(ButtonClassIns)}

    PrepareButton(ButtonIns : prop_button_class)<suspends>:void=
        ButtonIns.Button.InteractedWithEvent.Subscribe(HandlerButtonPressed{Device:=Self, SelectedButtonClass:=ButtonIns}.PropButtonHandler)

    ButtonPressedEvent(Agent : agent, SelectedButtonClass : prop_button_class):void=
        if(SelectedButtonClass.ButtonIndex <> 0):
            if(ButtonsClass[SelectedButtonClass.ButtonIndex - 1].IsPressed = true):
                #Print("Prev Button is On")
                set SelectedButtonClass.IsPressed = true
                Tracker.Increment(Agent)
            else:
                #Print("Error Sequence Resetting all buttons")
                for(BIns : ButtonsClass):
                    set BIns.IsPressed = false
                Tracker.Reset(Agent)
        else:
            set SelectedButtonClass.IsPressed = true
            Tracker.Increment(Agent)

        Print("Button Pressed, Index: {SelectedButtonClass.ButtonIndex}")
        
        

        
