
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Simulation/Tags }

moving_platform_x_axis := class(tag) {}
moving_platform_y_axis := class(tag) {}
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
item_rotator := class(creative_device):

    @editable var EndGameDevice : end_game_device = end_game_device{}
    @editable var CaptureDevice : capture_area_device = capture_area_device{}
    
    @editable var MoveDistanceX : float = 900.0 # Controls the travel distance in the x-axis
    @editable var MoveSpeedX : float = 3.0

    @editable var MoveDistanceY : float = 500.00 # Controls the travel distance in the y-axis
    @editable var MoveSpeedY : float = 2.0
    

    # Tags to be added to moving platforms - separated based on the axis movement
    var PlatformX : []creative_object_interface = array{}
    var PlatformY : []creative_object_interface = array{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        
        CaptureDevice.AgentEntersEvent.Subscribe(OnCaptureEvent)
        set PlatformX = GetCreativeObjectsWithTag(moving_platform_x_axis{})
        set PlatformY = GetCreativeObjectsWithTag(moving_platform_y_axis{})
        
        # Apply MovePlatform functions to all props with their respective tags

        for (Obj : PlatformX):
            if(Prop := creative_prop[Obj]):
                spawn:
                    MovePlatformX(Prop)
            
        for (Obj : PlatformY):
            if(Prop := creative_prop[Obj]):
                spawn:
                    MovePlatformY(Prop)
        
        
    MovePlatformX<private>(Prop: creative_prop)<suspends> : void=
        
        Transform := Prop.GetTransform()
        InitialPosition := Transform.Translation
        InitialRotation := Transform.Rotation
        
        NewPosition := vector3{X := InitialPosition.X + MoveDistanceX, Y := InitialPosition.Y, Z := InitialPosition.Z}
        MoveResult := Prop.MoveTo(NewPosition,InitialRotation, MoveSpeedX)
        
        # Looping the movement
        if(MoveResult = move_to_result.DestinationReached):
            
            MoveResult2 := Prop.MoveTo(InitialPosition,InitialRotation, MoveSpeedX)
            if(MoveResult2 = move_to_result.DestinationReached):
                MovePlatformX(Prop)

    
    MovePlatformY<private>(Prop: creative_prop)<suspends> : void=
        
        Transform := Prop.GetTransform()
        InitialPosition := Transform.Translation
        InitialRotation := Transform.Rotation
        
        NewPosition := vector3{X := InitialPosition.X , Y := InitialPosition.Y + MoveDistanceY, Z := InitialPosition.Z}
        MoveResult := Prop.MoveTo(NewPosition,InitialRotation, MoveSpeedY)
        
        # Looping the movement
        if(MoveResult = move_to_result.DestinationReached):
            
            MoveResult2 := Prop.MoveTo(InitialPosition,InitialRotation, MoveSpeedY)
            if(MoveResult2 = move_to_result.DestinationReached):
                MovePlatformY(Prop)
    
                
    OnCaptureEvent(Agent: agent): void=
        EndGameDevice.Activate(Agent) 